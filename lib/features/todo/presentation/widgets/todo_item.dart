import 'package:flutter/material.dart';
import 'package:flutter_application_clean/core/errors/failures.dart';
import 'package:flutter_application_clean/features/todo/domain/entities/todo.dart';
import 'package:flutter_application_clean/features/todo/presentation/providers/todo_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TodoItem extends ConsumerWidget {
  final Todo todo;

  const TodoItem({super.key, required this.todo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Checkbox(
        value: todo.isCompleted,
        onChanged: (_) async {
          try {
            await ref.read(todoListProvider.notifier).toggleTodo(todo.id);
          } catch (e) {
            if (context.mounted) {
              _showErrorSnackBar(context, e);
            }
          }
        },
      ),
      title: InkWell(
        onTap: () => _showEditDialog(context, ref),
        child: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () async {
          try {
            await ref.read(todoListProvider.notifier).deleteTodo(todo.id);
          } catch (e) {
            if (context.mounted) {
              _showErrorSnackBar(context, e);
            }
          }
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: todo.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Todo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter new title'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await ref
                    .read(todoListProvider.notifier)
                    .updateTodo(todo.id, controller.text);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  _showErrorSnackBar(context, e);
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_getErrorMessage(error)),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  String _getErrorMessage(Object error) {
    if (error is Failure) {
      return error.when(
        server: (msg) => 'Server error: $msg',
        network: () => 'No internet connection',
        cache: () => 'Failed to access local storage',
        validation: (msg) => msg,
        unexpected: (msg) => 'Unexpected error: $msg',
      );
    }
    return 'An error occurred';
  }
}
