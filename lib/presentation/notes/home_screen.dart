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
          _HomeTab(),
          TasksScreen(),
          ProfileScreen(),
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
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_rounded),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
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
/// Converted to a [StatefulWidget] so the Firestore stream is created once
/// and stored in state. Previously, calling [NotesProvider.notesStream] inside
/// a [StreamBuilder] on every rebuild (triggered by context.watch<NotesProvider>)
/// was creating a new stream each time, causing the StreamBuilder to reset to
/// [ConnectionState.waiting] and never show the notes.
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
          _HomeHeader(user: user),
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

class _HomeHeader extends StatelessWidget {
  final dynamic user;
  const _HomeHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM').format(now);
    final timeStr = DateFormat('HH:mm').format(now);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Row(
            children: [
              _HeaderIconBtn(
                icon: Icons.access_time_rounded,
                tooltip: 'Time: $timeStr',
                onPressed: () {},
              ),
              const SizedBox(width: 4),
              _HeaderIconBtn(
                icon: Icons.settings_outlined,
                tooltip: 'Settings',
                onPressed: () => _showSettingsSheet(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _SettingsSheet(),
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _HeaderIconBtn({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
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
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

// ── Settings Bottom Sheet ─────────────────────────────────────────────────────

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.cardBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded,
                  color: AppColors.textBlue, size: 20),
            ),
            title: const Text('Sign Out',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Sign out of your account',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            onTap: () async {
              // Capture providers before async gap
              final auth = context.read<AuthProvider>();
              final notes = context.read<NotesProvider>();
              Navigator.pop(context);
              await auth.signOut();
              notes.clearNotes();
            },
          ),
          const SizedBox(height: 16),
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

// ── Home Tab ──────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HomeHeader(user: user),
            const SizedBox(height: 24),
            const _QuickStatsCard(),
            const SizedBox(height: 24),
            const Text(
              'Recent Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _RecentNotesPreview(userId: user?.uid ?? ''),
          ],
        ),
      ),
    );
  }
}

class _QuickStatsCard extends StatefulWidget {
  const _QuickStatsCard();

  @override
  State<_QuickStatsCard> createState() => _QuickStatsCardState();
}

class _QuickStatsCardState extends State<_QuickStatsCard> {
  Stream<List<NoteModel>>? _stream;
  String? _cachedUid;

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid ?? '';
    if (uid != _cachedUid) {
      _cachedUid = uid;
      _stream = uid.isEmpty ? null : context.read<NotesProvider>().notesStream(uid);
    }

    return StreamBuilder<List<NoteModel>>(
      stream: _stream,
      builder: (context, snapshot) {
        final notes = snapshot.data ?? [];
        final pinned = notes.where((n) => n.isPinned).length;
        final now = DateTime.now();
        final todayCount = notes
            .where((n) {
              final d = n.createdAt.toDate();
              return d.year == now.year &&
                  d.month == now.month &&
                  d.day == now.day;
            })
            .length;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              _StatItem(
                label: 'Total Notes',
                value: notes.length.toString(),
                color: AppColors.textBlue,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.textBlue.withValues(alpha: 0.2),
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              _StatItem(
                label: 'Pinned',
                value: pinned.toString(),
                color: AppColors.textBlue,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.textBlue.withValues(alpha: 0.2),
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              _StatItem(
                label: 'Today',
                value: todayCount.toString(),
                color: AppColors.textBlue,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RecentNotesPreview extends StatefulWidget {
  final String userId;
  const _RecentNotesPreview({required this.userId});

  @override
  State<_RecentNotesPreview> createState() => _RecentNotesPreviewState();
}

class _RecentNotesPreviewState extends State<_RecentNotesPreview> {
  Stream<List<NoteModel>>? _stream;
  String? _cachedUid;

  @override
  Widget build(BuildContext context) {
    if (widget.userId.isEmpty) return const SizedBox.shrink();
    if (widget.userId != _cachedUid) {
      _cachedUid = widget.userId;
      _stream = context.read<NotesProvider>().notesStream(widget.userId);
    }

    return StreamBuilder<List<NoteModel>>(
      stream: _stream,
      builder: (context, snapshot) {
        final notes = (snapshot.data ?? []).take(3).toList();
        if (notes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No recent notes.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          );
        }
        return Column(
          children: notes.map((note) {
            final bg = AppColors.cardBgFromKey(note.cardColor);
            final tc = AppColors.cardTextFromKey(note.cardColor);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: TextStyle(
                            color: tc,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (note.content.isNotEmpty)
                          Text(
                            note.content,
                            style: TextStyle(
                              color: tc.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: tc.withValues(alpha: 0.5),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// Tasks and Profile screens are imported from their respective files.
