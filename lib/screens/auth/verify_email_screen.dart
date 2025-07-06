import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerifyEmailScreen extends StatefulWidget {
  final String token;
  const VerifyEmailScreen({super.key, required this.token});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _loading = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _verifyEmail();
  }

  Future<void> _verifyEmail() async {
    final url = Uri.parse("http://10.0.2.2:5000/api/auth/verify-email/${widget.token}");

    try {
      final res = await http.get(url);
      final data = json.decode(res.body);

      if (res.statusCode == 200) {
        setState(() => _message = "Email verified successfully. You can now log in.");
      } else {
        setState(() => _message = data['message'] ?? "Verification failed.");
      }
    } catch (_) {
      setState(() => _message = "An error occurred.");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Email Verification")),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _message!.contains("successfully") ? Icons.check_circle : Icons.error,
                color: _message!.contains("successfully") ? Colors.green : Colors.red,
                size: 60,
              ),
              const SizedBox(height: 20),
              Text(
                _message!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: const Text("Go to Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
