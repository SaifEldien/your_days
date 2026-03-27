import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomFAB extends StatefulWidget {
  final String text;
  final IconData icon;
  final Widget? form;
  final Color color;
  final Future<void> Function()? function;

  const CustomFAB({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    this.form,
    this.function,
  });

  @override
  State<CustomFAB> createState() => _CustomFABState();
}

class _CustomFABState extends State<CustomFAB>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  // التعامل مع لمسة اليد (Tactile Feedback)
  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.88); // ضغطة أعمق شوية للـ Premium feel
    HapticFeedback.mediumImpact(); // اهتزاز متوسط للإحساس بالزرار
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0.0;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: isKeyboardOpen ? 0.0 : 1.0,
      child: IgnorePointer(
        ignoring: isKeyboardOpen,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.text.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withValues(alpha: .7),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: () => setState(() => _scale = 1.0),
              child: AnimatedScale(
                scale: _scale,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOutBack,
                child: Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Shadow متقدم (Outer Glow)
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: .4),
                        blurRadius: 25,
                        spreadRadius: -2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // التلوين الـ Senior (Gradient Mesh Effect)
                          color: widget.color.withValues(alpha: .1),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .2),
                            width: 1.5,
                          ),
                        ),
                        child: FloatingActionButton(
                          heroTag: "main_custom_fab",
                          shape: const CircleBorder(),
                          elevation: 0,
                          backgroundColor:
                              Colors.transparent, // الشفافية هنا هي السر
                          onPressed: () => _handlePress(context),
                          child: Icon(
                            widget.icon,
                            size: 32,
                            color: Colors.white.withValues(alpha: .9),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePress(BuildContext context) async {
    if (widget.function != null) await widget.function!();

    if (!context.mounted) return;
    if (widget.form != null) {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Dismiss',
        barrierColor: Colors.black.withValues(alpha: .6),
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, anim1, anim2) => widget.form!,
        transitionBuilder: (context, anim1, anim2, child) {
          final curvedValue = const Cubic(
            0.175,
            0.885,
            0.32,
            1.275,
          ).transform(anim1.value);

          return Transform.scale(
            scale: curvedValue,
            child: Opacity(opacity: anim1.value, child: child),
          );
        },
      );
    }
  }
}
