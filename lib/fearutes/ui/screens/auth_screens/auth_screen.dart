import 'package:flutter/material.dart';
import 'package:my_days/fearutes/ui/screens/auth_screens/signup_screen.dart';

import 'login_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: isLogin
              ? const LoginScreen(key: ValueKey('login'))
              : const SignUpScreen(key: ValueKey('signup')),
        ),
        Positioned(
          bottom: 90,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () {
                isLogin = !isLogin;
                setState(() {});
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: RichText(
                  key: ValueKey(isLogin),
                  text: TextSpan(
                    text: isLogin ? "New User? " : "Already have an account? ",
                    style: const TextStyle(color: Colors.white60, fontSize: 16),
                    children: [
                      TextSpan(
                        text: isLogin ? "Create Account" : "Login",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
