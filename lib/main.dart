import 'package:flutter/material.dart';
import 'package:flutter_application_clean/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_application_clean/features/todo/data/models/todo_model.dart';
import 'package:flutter_application_clean/features/todo/presentation/providers/todo_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(TodoModelAdapter());

  // Create provider container
  final container = ProviderContainer();

  // Warm up the Hive box (open it before app starts)
  await container.read(todoBoxProvider.future);

  runApp(
    UncontrolledProviderScope(container: container, child: const MainApp()),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Flutter Clean Architecture',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
