import 'package:flutter/material.dart';
import 'auth_service.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _textController = TextEditingController();
  final _api = ApiService();
  bool _isLoading = false;

  void _post() async {
    if (_textController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    final success = await _api.createPost(_textController.text);
    setState(() => _isLoading = false);
    
    if (success) {
      Navigator.pop(context, true); // Return success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to post')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share what\'s new'),
        backgroundColor: const Color(0xFFDD4B39),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isLoading ? null : _post,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'What\'s on your mind?',
                border: InputBorder.none,
              ),
              maxLines: 10,
              autofocus: true,
            ),
            if (_isLoading) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
