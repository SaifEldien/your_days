// ignore_for_file: use_build_context_synchronously
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/components/smart_image.dart';
import '../../../core/components/widgets.dart';
import '../../../core/const/functions.dart';
import '../../data/logic/bloC/app_theme_bloc/app_theme_cubit.dart';
import '../../data/logic/bloC/user_bloc/user_cubit.dart';
import '../../data/models/user.dart';


class EditUserScreen extends StatefulWidget {
  final UserClass user;
  const EditUserScreen({super.key, required this.user});
  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  late TextEditingController _contName;
  late TextEditingController _contEmail;
  final _formKey = GlobalKey<FormState>();
  String image = '';

  @override
  void initState() {
    _contName = TextEditingController(text: widget.user.name);
    _contEmail = TextEditingController(text: widget.user.email);
    super.initState();
  }

  @override
  void dispose() {
    _contName.dispose();
    _contEmail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<AppThemeCubit>();
    final accentColor = themeCubit.color == const Color(0xff000000)
        ? Colors.white
        : themeCubit.color;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(themeCubit.wallpaper),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text(
            "Profile Settings",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  // 1. Profile Image with Edit Badge
                  _buildProfileImage(accentColor),
                  const SizedBox(height: 30),

                  // 2. Glass Form Card
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
                              CustomFormField(
                                icon: Icons.person_outline,
                                hintText: "Full Name",
                                cont: _contName,
                                valid: (v) =>
                                    v!.length > 20 ? "Name too long" : null,
                              ),
                              const SizedBox(height: 15),
                              CustomFormField(
                                readOnly: true,
                                icon: Icons.email_outlined,
                                hintText: "Email Address",
                                cont: _contEmail,
                                valid: (v) => null,
                              ),
                              const SizedBox(height: 25),

                              // Submit Button
                              _buildActionButton(
                                label: "Save Changes",
                                color: accentColor,
                                textColor:
                                    themeCubit.color == const Color(0xff000000)
                                    ? Colors.black
                                    : Colors.white,
                                onTap: _handleUpdate,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 3. Danger Zone Actions
                  _buildSecondaryActions(accentColor),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(Color accentColor) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: accentColor, width: 2),
          ),
          child: SmartImageWidget(
            imagePath: image == '' ? widget.user.image! : image,
            size: 130,
          ),
        ),
        GestureDetector(
          onTap: _handlePickImage,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: accentColor,
            child: Icon(
              Icons.camera_alt,
              size: 18,
              color: accentColor == Colors.white ? Colors.black : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        minimumSize: const Size(double.infinity, 55),
        elevation: 0,
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSecondaryActions(Color accentColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          onPressed: _handlePasswordReset,
          icon: Icon(
            Icons.lock_reset,
            color: Colors.white.withValues(alpha: .7),
          ),
          label: Text(
            "Reset Password",
            style: TextStyle(color: Colors.white.withValues(alpha: .7)),
          ),
        ),
      ],
    );
  }

  // --- Handlers ---

  Future<void> _handlePickImage() async {
    String? picked = await pickImage(context: context);
    if (picked != null) {
      setState(() => image = picked);
    }
  }

  void _handleUpdate() {
    if (!_formKey.currentState!.validate()) return;
    UserClass updatedUser = UserClass(
      widget.user.email,
      _contName.text,
      image == '' ? widget.user.image : image,
      widget.user.registerDate,
      widget.user.days,
    );
    showAlert(context, "Update your profile information?", () async {
      showLoading(context, true);
      await context.read<UserCubit>().updateUser(updatedUser);
      showLoading(context, false);
      Navigator.pop(context);
    });
  }

  void _handlePasswordReset() async {
    if (!await checkConnection()) return;
    showAlert(context, "Send a password reset link to your email?", () async {
      showLoading(context, true);
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _contEmail.text.trim(),
      );
      showLoading(context, false);
      showToast("Reset link sent successfully!");
    });
  }
}
