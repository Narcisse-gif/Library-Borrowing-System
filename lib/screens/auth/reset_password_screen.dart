import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/validators.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _message;
  bool _obscure = true;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _message = null;
    });

    final url = Uri.parse(
      "http://<your-backend-url>/api/auth/reset-password/${widget.token}",
    );

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({'password': _passwordController.text.trim()}),
      );

      final data = json.decode(res.body);

      if (res.statusCode == 200) {
        setState(() {
          _message = "Password reset successful! You can now log in.";
        });
      } else {
        setState(() {
          _message = data['message'] ?? "Reset failed.";
        });
      }
    } catch (_) {
      setState(() => _message = "Something went wrong. Try again.");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Enter your new password below.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                validator: validatePassword,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: "New Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_loading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _resetPassword,
                  child: const Text("Reset Password"),
                ),
              if (_message != null) ...[
                const SizedBox(height: 20),
                Text(
                  _message!,
                  style: TextStyle(
                    color: _message!.contains("successful") ? Colors.green : Colors.red,
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
