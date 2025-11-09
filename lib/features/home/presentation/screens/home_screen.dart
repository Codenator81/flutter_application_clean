import 'package:flutter/material.dart';
import 'package:flutter_application_clean/features/todo/presentation/screens/todo_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.architecture, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              Text(
                'Clean Architecture Demo',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'A TODO app demonstrating:\n• Domain, Data, Presentation layers\n• Riverpod state management\n• Freezed immutable models',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TodoListScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.checklist),
                label: const Text('Open TODO App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
