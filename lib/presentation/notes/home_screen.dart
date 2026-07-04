import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../data/models/note_model.dart';
import '../auth/auth_provider.dart';
import '../profile/profile_screen.dart';
import '../tasks/tasks_screen.dart';
import 'notes_provider.dart';
import 'widgets/bento_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _NotesTab(),
          TasksScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _selectedIndex == 0 ? _buildFAB() : null,
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        elevation: 0,
        backgroundColor: Colors.transparent,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_rounded),
            label: 'Tasks',
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, AppRoutes.addNote),
      child: const Icon(Icons.add_rounded, size: 28),
    );
  }
}

// ── Notes Tab ─────────────────────────────────────────────────────────────────

/// The Notes grid tab.
///
/// [StatefulWidget] so the Firestore stream is created once and stored in
/// state — creating a new stream on every rebuild would reset [StreamBuilder]
/// back to [ConnectionState.waiting] and prevent notes from displaying.
class _NotesTab extends StatefulWidget {
  const _NotesTab();

  @override
  State<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<_NotesTab> {
  Stream<List<NoteModel>>? _stream;
  String? _cachedUid;

  @override
  Widget build(BuildContext context) {
    // Only watch auth — NOT NotesProvider — so provider rebuilds don't
    // recreate the stream and reset the StreamBuilder.
    final user = context.watch<AuthProvider>().user;

    if (user == null) return const SizedBox.shrink();

    // Create the stream once per user; reuse across rebuilds.
    if (user.uid != _cachedUid) {
      _cachedUid = user.uid;
      _stream = context.read<NotesProvider>().notesStream(user.uid);
    }

    return SafeArea(
      child: Column(
        children: [
          _NotesHeader(user: user),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<NoteModel>>(
              stream: _stream,
              builder: (context, snapshot) {
                debugPrint(
                  '[NotesTab] state=${snapshot.connectionState} '
                  'hasData=${snapshot.hasData} '
                  'count=${snapshot.data?.length} '
                  'error=${snapshot.error}',
                );
                if (snapshot.hasError) {
                  debugPrint('Notes stream error: ${snapshot.error}');
                  return AppErrorWidget(
                    message: snapshot.error.toString(),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const BentoLoadingIndicator();
                }
                final notes = snapshot.data ?? [];
                if (notes.isEmpty) return const _EmptyState();
                return BentoGrid(
                  notes: notes,
                  onNoteTap: (note) => Navigator.pushNamed(
                    context,
                    AppRoutes.noteDetail,
                    arguments: note,
                  ),
                  onNoteDelete: (note) async {
                    final notesP = context.read<NotesProvider>();
                    final error = await notesP.deleteNote(note.id);
                    if (error != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                    }
                  },
                  onReorder: (reorderedNotes) {
                    context.read<NotesProvider>().reorderNotes(reorderedNotes);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _NotesHeader extends StatelessWidget {
  final dynamic user;
  const _NotesHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM').format(now);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: greeting + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${user?.firstName ?? 'there'} 👋',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          // Right: profile button
          Tooltip(
            message: 'Profile',
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.cardBlue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('📝', style: TextStyle(fontSize: 48)),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No notes yet.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap + to start capturing\nyour thoughts.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
