
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/screens/chat/chat_screen.dart'; // Import the new chat screen
import 'package:myapp/screens/login/login_screen.dart';
import 'package:myapp/screens/login/register_screen.dart';
import 'package:myapp/screens/posts/post_detail_screen.dart';
import 'package:myapp/screens/posts/post_list_screen.dart';

// A custom Notifier that listens to a Stream and notifies listeners
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Make the router a final variable that can be imported and used.
final GoRouter router = GoRouter(
  refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn = FirebaseAuth.instance.currentUser != null;
    final bool loggingIn = state.matchedLocation == '/login';
    final bool registering = state.matchedLocation == '/register';

    if (!loggedIn) {
      return loggingIn || registering ? null : '/login';
    }

    if (loggingIn || registering) {
      return '/';
    }

    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const PostListScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'details/:id',
          builder: (BuildContext context, GoRouterState state) {
            final String id = state.pathParameters['id']!;
            return PostDetailScreen(postId: int.parse(id));
          },
        ),
        GoRoute(
          path: 'edit/:id',
          builder: (BuildContext context, GoRouterState state) {
            final String id = state.pathParameters['id']!;
            return PostDetailScreen(postId: int.parse(id), isEditing: true);
          },
        ),
        GoRoute(
          path: 'create',
          builder: (BuildContext context, GoRouterState state) {
            return const PostDetailScreen(isEditing: true);
          },
        ),
        // Add the new chat route as a sub-route of home
        GoRoute(
          path: 'chat',
          builder: (BuildContext context, GoRouterState state) {
            return const ChatScreen();
          },
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterScreen();
      },
    ),
  ],
);
