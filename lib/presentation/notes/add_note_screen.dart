import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../auth/auth_provider.dart';
import 'notes_provider.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _selectedCategory = 'Personal';
  String _selectedColor = 'blue';
  String _selectedType = 'normal';
  bool _isPinned = false;

  static const _categories = ['Personal', 'Study', 'Work', 'Idea'];
  static const _categoryLabels = {
    'personal': '👤 Personal',
    'study': '🎓 Study',
    'work': '💼 Work',
    'idea': '💡 Idea',
  };
  static const _typeLabels = {
    'normal': 'Normal',
    'wide': 'Wide',
    'tall': 'Tall',
  };
  static const _typeIcons = {
    'normal': Icons.crop_square_rounded,
    'wide': Icons.crop_landscape_rounded,
    'tall': Icons.crop_portrait_rounded,
  };

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final notes = context.read<NotesProvider>();
    final uid = auth.user?.uid ?? '';

    final error = await notes.createNote(
      userId: uid,
      title: _titleController.text,
      content: _contentController.text,
      category: _selectedCategory,
      cardColor: _selectedColor,
      cardType: _selectedType,
      isPinned: _isPinned,
    );

    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NotesProvider>();
    final previewBg = AppColors.cardBgFromKey(_selectedColor);
    final previewText = AppColors.cardTextFromKey(_selectedColor);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: notes.isLoading ? null : _handleSave,
              child: notes.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live preview card
              _buildPreviewCard(previewBg, previewText),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title field
                    _sectionLabel('Title'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Note title...',
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Title cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Content field
                    _sectionLabel('Content'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _contentController,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Write your note here...',
                        alignLabelWithHint: true,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 24),
                    // Category
                    _sectionLabel('Category'),
                    const SizedBox(height: 10),
                    _buildCategoryPicker(),
                    const SizedBox(height: 24),
                    // Card Color
                    _sectionLabel('Card Color'),
                    const SizedBox(height: 10),
                    _buildColorPicker(),
                    const SizedBox(height: 24),
                    // Card Type
                    _sectionLabel('Card Size'),
                    const SizedBox(height: 10),
                    _buildTypePicker(),
                    const SizedBox(height: 24),
                    // Pin toggle
                    _buildPinToggle(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(Color bg, Color textColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bg.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: TextStyle(
              color: textColor.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _titleController.text.isEmpty ? 'Your title' : _titleController.text,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (_contentController.text.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _contentController.text,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((cat) {
        final isSelected = _selectedCategory == cat;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4A7090) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? const Color(0xFF4A7090) : AppColors.divider,
              ),
            ),
            child: Text(
              _categoryLabels[cat] ?? cat,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorPicker() {
    return Row(
      children: AppColors.colorKeys.map((key) {
        final isSelected = _selectedColor == key;
        final color = AppColors.cardBgFromKey(key);
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 12),
            width: isSelected ? 44 : 36,
            height: isSelected ? 44 : 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: AppColors.cardTextFromKey(key),
                      width: 2.5,
                    )
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : null,
            ),
            child: isSelected
                ? Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppColors.cardTextFromKey(key),
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypePicker() {
    return Row(
      children: ['normal', 'wide', 'tall'].map((type) {
        final isSelected = _selectedType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4A7090) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF4A7090) : AppColors.divider,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _typeIcons[type]!,
                  size: 16,
                  color: isSelected ? Colors.white : AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  _typeLabels[type]!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPinToggle() {
    return GestureDetector(
      onTap: () => setState(() => _isPinned = !_isPinned),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isPinned ? AppColors.cardAmber : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isPinned ? AppColors.fabAmber : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              color: _isPinned ? AppColors.textAmber : AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pin Note',
                  style: TextStyle(
                    color: _isPinned ? AppColors.textAmber : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Pinned notes appear at the top',
                  style: TextStyle(
                    color: _isPinned
                        ? AppColors.textAmber.withValues(alpha: 0.7)
                        : AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isPinned
                  ? Container(
                      key: const ValueKey('on'),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.fabAmber,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'ON',
                        style: TextStyle(
                          color: AppColors.textAmber,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : const SizedBox(key: ValueKey('off')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
