import 'package:flutter/material.dart';
import 'auth_service.dart';

class PostDetailPage extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final _commentController = TextEditingController();
  final _api = ApiService();
  late Map<String, dynamic> _post;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  void _addComment() async {
    if (_commentController.text.isEmpty) return;
    setState(() => _isLoading = true);
    final success = await _api.addComment(_post['id'], _commentController.text);
    
    if (success) {
      // Add locally to update UI instantly
      final user = await _api.getSessionUser();
      setState(() {
        if (_post['comments'] == null) _post['comments'] = [];
        (_post['comments'] as List).add({
            'author': user['name'],
            'content': _commentController.text,
            'date': 'Just now'
        });
      });
      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comment added!')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final comments = _post['comments'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Post'), backgroundColor: const Color(0xFFDD4B39)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Original Post
                Text(_post['author'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(_post['content'], style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text(_post['date'], style: TextStyle(color: Colors.grey[600])),
                const Divider(height: 30),
                
                // Comments
                const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold)),
                ...comments.map((c) => ListTile(
                  leading: CircleAvatar(child: Text(c['author'][0])),
                  title: Text(c['author']),
                  subtitle: Text(c['content']),
                )),
              ],
            ),
          ),
          // Input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(hintText: 'Add a comment...'),
                  ),
                ),
                IconButton(
                  icon: _isLoading ? const CircularProgressIndicator() : const Icon(Icons.send),
                  onPressed: _addComment,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
