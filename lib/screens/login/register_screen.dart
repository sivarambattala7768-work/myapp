
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/database_service.dart';

// Add the missing providers back
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final databaseServiceProvider =
    Provider<DatabaseService>((ref) => DatabaseService());

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _register() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar('Please fill in all fields.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final dbService = ref.read(databaseServiceProvider);

      // --- Step 1: Authentication ---
      final user = await authService.createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted || user == null) {
        _showErrorSnackBar('Registration failed. Could not create user.');
        return;
      }

      // --- Step 2: Database record creation ---
      try {
        await dbService.createUser(user.uid, user.email!);
        if (mounted) {
          // Success! Navigate away.
          context.go('/login');
        }
      } catch (dbError) {
        // This catches the Firestore error
        if (mounted) {
          _showErrorSnackBar(
              'Account created, but failed to save user data. Please try logging in.');
          context.go('/login'); // Navigate to login since user exists
        }
      }
    } catch (authError) {
      // This catches the Firebase Auth error
      if (mounted) {
        _showErrorSnackBar(
            'Registration failed: The email might be taken or the password is too weak.');
      }
    } finally {
      // --- Final Step: Always turn off loader ---
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading, // Disable text field when loading
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                enabled: !_isLoading, // Disable text field when loading
              ),
              const SizedBox(height: 24),
              // --- IMPROVED BUTTON WIDGET ---
              ElevatedButton(
                onPressed: _isLoading ? null : _register, // Disable button when loading
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50), // Make button wider
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3.0,
                        ),
                      )
                    : const Text('Register'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _isLoading ? null : () => context.go('/login'), // Disable button when loading
                child: const Text('Already have an account? Login'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
