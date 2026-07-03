import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/note_model.dart';
import 'notes_provider.dart';

class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({super.key});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late NoteModel _note;

  String _selectedCategory = 'Personal';
  String _selectedColor = 'blue';
  String _selectedType = 'normal';
  bool _isPinned = false;
  bool _initialized = false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _note = ModalRoute.of(context)!.settings.arguments as NoteModel;
      _titleController = TextEditingController(text: _note.title);
      _contentController = TextEditingController(text: _note.content);
      _selectedCategory = _note.category;
      _selectedColor = _note.cardColor;
      _selectedType = _note.cardType;
      _isPinned = _note.isPinned;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = _note.copyWith(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _selectedCategory,
      cardColor: _selectedColor,
      cardType: _selectedType,
      isPinned: _isPinned,
    );

    final error = await context.read<NotesProvider>().updateNote(updated);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _handleDelete() async {
    // Capture provider before any async gap
    final notesProvider = context.read<NotesProvider>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
          'Delete "${_note.title}"? This action cannot be undone.',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final error = await notesProvider.deleteNote(_note.id);
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
        title: const Text('Edit Note'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            tooltip: 'Delete note',
            onPressed: _handleDelete,
          ),
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
              // Live preview
              _buildPreviewCard(previewBg, previewText),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Title'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(hintText: 'Note title...'),
                      onChanged: (_) => setState(() {}),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Title cannot be empty'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _sectionLabel('Content'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _contentController,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Write your note here...',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 24),
                    _sectionLabel('Category'),
                    const SizedBox(height: 10),
                    _buildCategoryPicker(),
                    const SizedBox(height: 24),
                    _sectionLabel('Card Color'),
                    const SizedBox(height: 10),
                    _buildColorPicker(),
                    const SizedBox(height: 24),
                    _sectionLabel('Card Size'),
                    const SizedBox(height: 10),
                    _buildTypePicker(),
                    const SizedBox(height: 24),
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
          BoxShadow(color: bg.withValues(alpha: 0.5), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preview',
              style: TextStyle(
                  color: textColor.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            _titleController.text.isEmpty ? 'Your title' : _titleController.text,
            style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          if (_contentController.text.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _contentController.text,
              style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 13),
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
                  ? Border.all(color: AppColors.cardTextFromKey(key), width: 2.5)
                  : null,
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8, offset: const Offset(0, 3))]
                  : null,
            ),
            child: isSelected
                ? Icon(Icons.check_rounded, size: 18, color: AppColors.cardTextFromKey(key))
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
                Icon(_typeIcons[type]!, size: 16,
                    color: isSelected ? Colors.white : AppColors.textMuted),
                const SizedBox(width: 6),
                Text(_typeLabels[type]!,
                    style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
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
                Text('Pin Note',
                    style: TextStyle(
                        color: _isPinned ? AppColors.textAmber : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text('Pinned notes appear at the top',
                    style: TextStyle(
                        color: _isPinned
                            ? AppColors.textAmber.withValues(alpha: 0.7)
                            : AppColors.textMuted,
                        fontSize: 12)),
              ],
            ),
            const Spacer(),
            if (_isPinned)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.fabAmber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('ON',
                    style: TextStyle(
                        color: AppColors.textAmber,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700));
  }
}
