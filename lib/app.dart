import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'data/models/user_model.dart';
import 'presentation/auth/auth_provider.dart' as app_auth;
import 'presentation/auth/login_screen.dart';
import 'presentation/auth/register_screen.dart';
import 'presentation/notes/add_note_screen.dart';
import 'presentation/notes/home_screen.dart';
import 'presentation/notes/note_detail_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'noted!',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Can be extended with shared_preferences toggle
      // Root routing based on auth state
      home: _AuthGate(),
      // Named routes
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.addNote: (_) => const AddNoteScreen(),
        AppRoutes.noteDetail: (_) => const NoteDetailScreen(),
      },
    );
  }
}

/// Listens to [FirebaseAuth.instance.authStateChanges] and routes accordingly.
class _AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While waiting for auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        final firebaseUser = snapshot.data;

        if (firebaseUser != null) {
          // Sync user into AuthProvider
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<app_auth.AuthProvider>().setUser(
                  UserModel.fromFirebase(firebaseUser),
                );
          });
          return const HomeScreen();
        } else {
          // Not signed in
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<app_auth.AuthProvider>().setUser(null);
          });
          return const LoginScreen();
        }
      },
    );
  }
}

/// Minimal animated splash screen while auth state resolves.
class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/noted_logo.png',
                    width: 80,
                    height: 80,
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'noted',
                        style: GoogleFonts.caveat(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2A2A2A),
                        ),
                      ),
                      TextSpan(
                        text: '!',
                        style: GoogleFonts.caveat(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFE4A038),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
