import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/const/functions.dart';
import '../../../../core/const/vars.dart';
import '../../../data/logic/bloC/user_bloc/user_cubit.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _MyLoginState createState() => _MyLoginState();
}

class _MyLoginState extends State<LoginScreen> {
  final _contEmail = TextEditingController();
  final _contPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(mainWallpaper),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // 1. Header Section
            Positioned(
              top: 80,
              left: 35,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome\nBack",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 5,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Form Section with Glassmorphism
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.2),

                    // Glass Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: .2),
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildModernField(
                                  controller: _contEmail,
                                  hint: 'Email Address',
                                  icon: Icons.email_outlined,
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      return "Email is required";
                                    }
                                    if (!isValidEmail(val.trim())) {
                                      return "Invalid Email";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                _buildModernField(
                                  controller: _contPassword,
                                  hint: 'Password',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      return "Password is required";
                                    }
                                    if (val.length < 8) {
                                      return "Min 8 characters";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 30),

                                // Login & Google Row
                                Row(
                                  children: [
                                    Expanded(child: _buildLoginButton()),
                                    const SizedBox(width: 15),
                                    _buildGoogleButton(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Footer Buttons
                    TextButton(
                      onPressed: _handleForgotPassword,
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withValues(alpha: .05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white),
        ),
        errorStyle: const TextStyle(color: Colors.orangeAccent),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [mainColor, mainColor.withValues(alpha: .7)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: mainColor.withValues(alpha: .3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextButton(
        onPressed: () async {
          if (!_formKey.currentState!.validate()) return;
          await context.read<UserCubit>().login(
            _contEmail.text.toLowerCase().trim(),
            _contPassword.text,
          );
        },
        child: const Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return InkWell(
      onTap: () async {
        if (!await checkConnection()) return;
        await context.read<UserCubit>().loginWithGoogle();
      },
      child: Container(
        height: 55,
        width: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(12),
        child: Image.asset('assets/images/googleLogo.png'),
      ),
    );
  }

  void _handleForgotPassword() async {
    if (!isValidEmail(_contEmail.text) || _contEmail.text.isEmpty) {
      showToast("Please enter a valid email first");
      return;
    }
    if (!await checkConnection()) return;

    showAlert(context, "Send reset link to ${_contEmail.text}?", () async {
      showLoading(context, true);
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _contEmail.text.trim().toLowerCase(),
        );
        showToast("Reset link sent!");
      } catch (e) {
        showToast(firebaseErrors(e.toString()));
      }
      showLoading(context, false);
    });
  }
}
