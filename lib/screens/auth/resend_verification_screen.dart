import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/validators.dart';

class ResendVerificationScreen extends StatefulWidget {
  const ResendVerificationScreen({super.key});

  @override
  State<ResendVerificationScreen> createState() => _ResendVerificationScreenState();
}

class _ResendVerificationScreenState extends State<ResendVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;
  String? _message;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _message = null;
    });

    final url = Uri.parse("http://10.0.2.2:5000/api/auth/resend-verification");

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({'email': _emailController.text.trim()}),
      );

      final data = json.decode(res.body);

      if (res.statusCode == 200) {
        setState(() => _message = "Verification email resent successfully!");
      } else {
        setState(() => _message = data['message'] ?? "Error resending email.");
      }
    } catch (_) {
      setState(() => _message = "Network error. Try again.");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Resend Verification Email")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Enter your email to resend the verification link.",
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
                  child: const Text("Resend Email"),
                ),
              if (_message != null) ...[
                const SizedBox(height: 20),
                Text(
                  _message!,
                  style: TextStyle(
                    color: _message!.contains("success") ? Colors.green : Colors.red,
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
