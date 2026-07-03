import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/note_model.dart';
import 'bento_card.dart';

/// Bento-style 2-column drag-and-drop grid for notes.
///
/// Notes are distributed alternately: even indices → left column,
/// odd indices → right column. Long-press initiates a drag; dropping
/// onto another card reorders the list.
///
/// Pinned notes can only be swapped with other pinned notes, and unpinned
/// with unpinned — so the "pinned first" invariant is always preserved.
class BentoGrid extends StatefulWidget {
  final List<NoteModel> notes;
  final void Function(NoteModel note) onNoteTap;
  final void Function(NoteModel note) onNoteDelete;

  /// Called after a completed drag with the fully reordered note list
  /// (each note's [NoteModel.order] already updated to its new position).
  /// Use this to persist the order to Firestore.
  final void Function(List<NoteModel> reorderedNotes) onReorder;

  const BentoGrid({
    super.key,
    required this.notes,
    required this.onNoteTap,
    required this.onNoteDelete,
    required this.onReorder,
  });

  @override
  State<BentoGrid> createState() => _BentoGridState();
}

class _BentoGridState extends State<BentoGrid> {
  /// Local optimistic copy of the notes list, manipulated on drag.
  late List<NoteModel> _localNotes;

  /// Index of the note currently being dragged, or null.
  int? _draggingIndex;

  @override
  void initState() {
    super.initState();
    _localNotes = List.from(widget.notes);
  }

  @override
  void didUpdateWidget(BentoGrid old) {
    super.didUpdateWidget(old);
    // Sync from stream only when no drag is active, to avoid
    // disrupting the optimistic reorder the user just performed.
    if (_draggingIndex == null) {
      _localNotes = List.from(widget.notes);
    }
  }

  // ── Reorder logic ──────────────────────────────────────────────────────────

  void _handleReorder(int fromIndex, int toIndex) {
    if (fromIndex == toIndex) return;

    final movedNote = _localNotes[fromIndex];
    final targetNote = _localNotes[toIndex];

    // Enforce pinned-first invariant:
    // - pinned cannot be dragged into the unpinned zone
    // - unpinned cannot be dragged into the pinned zone
    if (movedNote.isPinned && !targetNote.isPinned) return;
    if (!movedNote.isPinned && targetNote.isPinned) return;

    setState(() {
      final note = _localNotes.removeAt(fromIndex);
      _localNotes.insert(toIndex, note);
      // Re-assign contiguous order values so Firestore sorts correctly.
      for (int i = 0; i < _localNotes.length; i++) {
        _localNotes[i] = _localNotes[i].copyWith(order: i);
      }
      _draggingIndex = null;
    });

    // Background Firestore batch write — non-blocking.
    widget.onReorder(List.from(_localNotes));
  }

  // ── Card builder ───────────────────────────────────────────────────────────

  double _minHeight(String cardType) => switch (cardType) {
        'tall' => 220.0,
        'wide' => 110.0,
        _ => 140.0,
      };

  Widget _buildCard(int index, double cardWidth) {
    final note = _localNotes[index];
    final minH = _minHeight(note.cardType);

    // The card shown in place while dragging (faded placeholder).
    final placeholder = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minH),
      child: Opacity(
        opacity: 0.25,
        child: BentoCard(note: note),
      ),
    );

    // The card dragged under the user's finger.
    final dragFeedback = SizedBox(
      width: cardWidth,
      child: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minH),
          child: Transform.scale(
            scale: 1.04,
            child: BentoCard(note: note),
          ),
        ),
      ),
    );

    // The fully interactive card shown at rest.
    final interactiveCard = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minH),
      child: BentoCard(
        note: note,
        onTap: () => widget.onNoteTap(note),
        onDelete: () => widget.onNoteDelete(note),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DragTarget<int>(
        onWillAcceptWithDetails: (details) =>
            details.data != index && _draggingIndex != null,
        onAcceptWithDetails: (details) => _handleReorder(details.data, index),
        builder: (context, candidates, _) {
          final isDropTarget = candidates.isNotEmpty;

          return LongPressDraggable<int>(
            data: index,
            delay: const Duration(milliseconds: 350),
            feedback: dragFeedback,
            childWhenDragging: placeholder,
            onDragStarted: () => setState(() => _draggingIndex = index),
            onDragEnd: (_) => setState(() => _draggingIndex = null),
            onDraggableCanceled: (_, __) =>
                setState(() => _draggingIndex = null),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: isDropTarget
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppColors.textBlue,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cardBlue.withValues(alpha: 0.5),
                          blurRadius: 12,
                        ),
                      ],
                    )
                  : const BoxDecoration(),
              child: interactiveCard,
            ),
          );
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    // 16px left pad + 16px right pad + 12px column gap = 44px total inset.
    final cardWidth = (screenWidth - 44) / 2;

    final leftIndices = [
      for (int i = 0; i < _localNotes.length; i += 2) i,
    ];
    final rightIndices = [
      for (int i = 1; i < _localNotes.length; i += 2) i,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column — even indices (0, 2, 4 …)
          Expanded(
            child: Column(
              children: leftIndices
                  .map((i) => _buildCard(i, cardWidth))
                  .toList(),
            ),
          ),
          const SizedBox(width: 12),
          // Right column — odd indices (1, 3, 5 …)
          Expanded(
            child: Column(
              children: [
                // Slight top-offset for the classic bento stagger feel.
                const SizedBox(height: 28),
                ...rightIndices.map((i) => _buildCard(i, cardWidth)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
