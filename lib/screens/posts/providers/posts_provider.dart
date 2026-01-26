
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import '../../../services/api_service.dart';

// A Provider is the most basic type of provider. It creates and exposes a single, read-only object.
// Here, it provides an instance of ApiService. Other providers can then use this service.
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// FutureProvider is used for asynchronous operations that return a single value.
// It automatically handles loading and error states for you.
// The `ref.watch(apiServiceProvider)` part makes this provider depend on `apiServiceProvider`.
// If `apiServiceProvider` changes, this provider will automatically re-run.
final postsProvider = FutureProvider<List<PostsListModel>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getPosts();
});

// The `.family` modifier allows you to create a provider that takes an argument.
// This is useful when you need to fetch data based on a specific ID or parameter.
// Here, `postProvider` takes an integer `postId` to fetch a single post.
// You would use it in the UI like `ref.watch(postProvider(123))`.
final postProvider = FutureProvider.family<PostsListModel?, int>((ref, postId) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getPost(postId);
});
