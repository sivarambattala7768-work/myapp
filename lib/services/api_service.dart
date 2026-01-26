import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../screens/posts/models/post.dart';

class ApiService {
  final String _baseUrl = 'http://jsonplaceholder.typicode.com';

  Future<List<PostsListModel>> getPosts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/posts'),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36',
        },
      );
      if (response.statusCode == 200) {
        return postsListModelFromJson(response.body);
      } else {
        log('Failed to load posts. Status code: ${response.statusCode}');
        log('Response body: ${response.body}');
        throw Exception(
          'Failed to load posts. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      log('An error occurred in getPosts: $e');
      throw Exception('Failed to load posts. Check your network connection.');
    }
  }

  Future<PostsListModel?> getPost(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/posts/$id'),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36',
        },
      );
      if (response.statusCode == 200) {
        return PostsListModel.fromJson(json.decode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      log('An error occurred in getPost: $e');
      throw Exception('Failed to load post. Check your network connection.');
    }
  }

  Future<PostsListModel> createPost(PostsListModel post) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/posts'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(post.toJson()),
    );
    if (response.statusCode == 201) {
      return PostsListModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create post');
    }
  }

  Future<PostsListModel> updatePost(PostsListModel post) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/posts/${post.id}'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(post.toJson()),
    );
    if (response.statusCode == 200) {
      return PostsListModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update post');
    }
  }

  Future<void> deletePost(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/posts/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete post');
    }
  }
}
