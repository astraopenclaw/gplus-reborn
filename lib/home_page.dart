import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _posts = [];
  bool _isLoading = true;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final baseUrl = await _authService.getBaseUrl();
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/posts'));
      if (response.statusCode == 200) {
        setState(() {
          _posts = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading posts: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5), // Classic grey
      appBar: AppBar(
        backgroundColor: const Color(0xFFDD4B39),
        title: Image.asset('assets/icons/gplus_logo.png', height: 32),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPosts),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPosts,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            child: Text(post['author'][0]),
                          ),
                          title: Text(post['author'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(post['date'] ?? 'Just now'),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(post['content'], style: const TextStyle(fontSize: 16)),
                        ),
                        // Actions
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('1'),
                              onPressed: () {},
                              style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.comment, size: 18),
                              label: const Text('Comment'),
                              onPressed: () {},
                              style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.share, size: 18),
                              label: const Text('Share'),
                              onPressed: () {},
                              style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFDD4B39),
        child: const Icon(Icons.edit),
        onPressed: () {
          // TODO: Open Create Post
        },
      ),
    );
  }
}
