import 'package:flutter/material.dart';
import 'database_service.dart';
import 'app_colors.dart';
import 'user_state.dart';
import 'login_page.dart';
import 'main.dart';

class RegisterPage extends StatefulWidget {
  final UserState credentials;
  const RegisterPage({super.key, required this.credentials});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      String email = _usernameController.text.trim();
      String password = _passwordController.text.trim();

      try {
        final userId = await _databaseService.addLogin(email, password);

        if (userId != null) {
          widget.credentials.userId = userId;
          widget.credentials.username = email;
          
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TaskListScreen(title: 'Task Manager', credentials: widget.credentials),
              ),
            );
          }
        }
      } on Exception catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create account')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter an email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent1,
                ),
                onPressed: _registerUser,
                child: const Text('Register',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.background,
                ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage(credentials: widget.credentials)),
                ),
                child: const Text('Already have an account? Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}