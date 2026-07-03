import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/note_repository.dart';
import 'data/repositories/task_repository.dart';
import 'firebase_options.dart';
import 'presentation/auth/auth_provider.dart';
import 'presentation/notes/notes_provider.dart';
import 'presentation/tasks/tasks_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            repository: AuthRepository(),
          ),
        ),
        ChangeNotifierProvider<NotesProvider>(
          create: (_) => NotesProvider(
            repository: NoteRepository(),
          ),
        ),
        ChangeNotifierProvider<TasksProvider>(
          create: (_) => TasksProvider(
            repository: TaskRepository(),
          ),
        ),
      ],
      child: const App(),
    ),
  );
}
