// prompt_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prompt_model.dart';
import '../providers/user_provider.dart';

class PromptCard extends StatelessWidget {
  final Prompt prompt;
  final VoidCallback onDelete;
  final Function(String title, String content) onEdit;

  const PromptCard({
    Key? key,
    required this.prompt,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  Future<void> _showEditDialog(BuildContext context) async {
    TextEditingController titleController = TextEditingController(text: prompt.title);
    TextEditingController contentController = TextEditingController(text: prompt.content);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Post'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Title:'),
              TextField(controller: titleController),
              const SizedBox(height: 16),
              const Text('Content:'),
              TextField(controller: contentController),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                onEdit(titleController.text, contentController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUserLoggedIn = Provider.of<UserProvider>(context).isLoggedIn;
    final currentUserAuthorId = Provider.of<UserProvider>(context).authorId;
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  prompt.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    if (isUserLoggedIn && currentUserAuthorId == prompt.authorId)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed:  () => _showEditDialog(context),
                    color: Colors.blue,
                  ),
                   if (isUserLoggedIn && currentUserAuthorId == prompt.authorId)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: onDelete,
                    color: Colors.red,
                  ),
                  ]
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Posted by: ${prompt.authorName}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(prompt.content),
            const SizedBox(height: 8),
            Row(
              children: [
                for (String tag in prompt.tags) Text('#$tag  ', style: TextStyle(color: Colors.blue)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
