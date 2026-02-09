import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String defaultBaseUrl = 'http://37.46.128.100';
  
  Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('base_url') ?? defaultBaseUrl;
  }

  // --- AUTH ---

  // Returns error message or null if success
  Future<String?> login(String email, String password) async {
    final baseUrl = await getBaseUrl();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', data['token']);
        await prefs.setString('user_id', data['user']['id'].toString());
        await prefs.setString('user_name', data['user']['name']);
        await prefs.setString('user_email', data['user']['email'] ?? '');
        return null; // Success
      }
      return 'Server error: ${response.statusCode}';
    } catch (e) {
      print('Login error: $e');
      return 'App error: $e';
    }
  }

  Future<bool> register(String name, String email, String password) async {
    final baseUrl = await getBaseUrl();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  
  Future<Map<String, String>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
        'id': prefs.getString('user_id') ?? '',
        'name': prefs.getString('user_name') ?? 'Guest',
        'email': prefs.getString('user_email') ?? ''
    };
  }

  // --- POSTS ---

  Future<List<dynamic>> getPosts() async {
    final baseUrl = await getBaseUrl();
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/posts'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {}
    return [];
  }
  
  Future<bool> createPost(String content) async {
    final baseUrl = await getBaseUrl();
    final user = await getUser();
    if (user['id']!.isEmpty) return false;
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'content': content, 'authorId': user['id']}),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
