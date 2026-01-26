
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/screens/posts/models/post.dart';
import 'package:myapp/screens/posts/providers/posts_provider.dart';

class PostDetailScreen extends ConsumerWidget {
  final int? postId;
  final bool isEditing;

  const PostDetailScreen({super.key, this.postId, this.isEditing = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsyncValue = postId != null ? ref.watch(postProvider(postId!)) : null;

    if (isEditing) {
      return _buildEditScreen(context, ref, postAsyncValue?.asData?.value);
    } else {
      return _buildDetailScreen(context, ref, postAsyncValue);
    }
  }

  Widget _buildDetailScreen(BuildContext context, WidgetRef ref, AsyncValue<PostsListModel?>? postAsyncValue) {
    return Scaffold(
      appBar: AppBar(
        title: postAsyncValue?.when(
              data: (post) => Text(post?.title ?? 'Post Details', maxLines: 1, overflow: TextOverflow.ellipsis),
              loading: () => const Text('Loading...'),
              error: (e, s) => const Text('Error'),
            ) ??
            const Text('Post Details'),
        actions: [
          if (postId != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.go('/edit/$postId'),
              tooltip: 'Edit Post',
            )
        ],
      ),
      body: postAsyncValue?.when(
            data: (post) {
              if (post == null) {
                return const Center(child: Text('Post not found.'));
              }
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title ?? '',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        post.body ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18, height: 1.5),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load post: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(postProvider(postId!)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ) ??
          const Center(
            child: Text('Select a post to see the details.'),
          ),
    );
  }

  Widget _buildEditScreen(BuildContext context, WidgetRef ref, PostsListModel? post) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post == null ? 'Create Post' : 'Edit Post'),
      ),
      body: post == null && postId != null
          ? const Center(child: CircularProgressIndicator())
          : _PostForm(post: post),
    );
  }
}

class _PostForm extends ConsumerStatefulWidget {
  final PostsListModel? post;

  const _PostForm({this.post});

  @override
  __PostFormState createState() => __PostFormState();
}

class __PostFormState extends ConsumerState<_PostForm> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _body;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _title = widget.post?.title ?? '';
    _body = widget.post?.body ?? '';
  }

  Future<void> _savePost() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        final apiService = ref.read(apiServiceProvider);
        if (widget.post == null) {
          final newPost = PostsListModel(userId: 1, title: _title, body: _body);
          await apiService.createPost(newPost);
        } else {
          final updatedPost = PostsListModel(
            id: widget.post!.id,
            userId: widget.post!.userId,
            title: _title,
            body: _body,
          );
          await apiService.updatePost(updatedPost);
        }
        ref.invalidate(postsProvider);
        context.go('/');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save post: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    initialValue: _title,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Please enter a title' : null,
                    onSaved: (value) => _title = value!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _body,
                    decoration: const InputDecoration(
                      labelText: 'Body',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Please enter a body' : null,
                    onSaved: (value) => _body = value!,
                    maxLines: 10,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _savePost,
                    child: const Text('Save Post'),
                  ),
                ],
              ),
            ),
          );
  }
}
