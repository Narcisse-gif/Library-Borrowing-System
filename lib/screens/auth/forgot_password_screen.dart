import 'package:flutter/material.dart';
import '../../utils/validators.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool _loading = false;
  String? _message;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _message = null;
    });

    final url = Uri.parse("http://10.0.2.2:5000/api/auth/forgot-password");

    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': _emailController.text.trim()}),
      );

      final data = json.decode(res.body);

      if (res.statusCode == 200) {
        setState(() {
          _message = "Password reset email sent!";
        });
      } else {
        setState(() {
          _message = data['message'] ?? "Something went wrong.";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Network error.";
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Enter your email to receive password reset instructions.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                validator: validateEmail,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              if (_loading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text("Send reset link"),
                ),
              if (_message != null) ...[
                const SizedBox(height: 20),
                Text(
                  _message!,
                  style: TextStyle(
                    color: _message!.contains("sent") ? Colors.green : Colors.red,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
