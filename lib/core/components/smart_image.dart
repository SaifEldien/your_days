import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../const/functions.dart';

class SmartImageWidget extends StatelessWidget {
  final String? imagePath;
  final double size;
  final Function? onTap;
  final bool isSquare;

  const SmartImageWidget({
    super.key,
    required this.imagePath,
    this.size = 50.0,
    this.onTap,
    this.isSquare = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else {
          _expandImage(context);
        }
      },
      child: Hero(
        tag: imagePath ?? "default_tag",
        child: _buildImageFrame(_buildImageContent(context: context)),
      ),
    );
  }

  Widget _buildImageFrame(Widget content) {
    if (isSquare) {
      return Container(
        width: size * 2,
        height: size * 2.2,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
        child: content,
      );
    }
    return CircleAvatar(
      radius: size,
      backgroundColor: Colors.transparent,
      child: ClipOval(child: content),
    );
  }

  Widget _buildImageContent({
    bool isFullScreen = false,
    required BuildContext context,
  }) {
    double? width = isFullScreen ? MediaQuery.of(context).size.width : size * 2;
    double? height = isFullScreen ? null : size * 2;

    if (imagePath == null || imagePath!.isEmpty || imagePath == "default") {
      return Image.asset(
        "assets/images/defaultProfilePicture.jpg",
        fit: isFullScreen ? BoxFit.contain : BoxFit.cover,
        width: width,
        height: height,
      );
    }
    if (imagePath!.startsWith('http')) {
      return Image.network(
        imagePath!,
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingSpinner();
        },
      );
    }
    try {
      Uint8List bytes = base64Decode(imagePath!);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
      );
    } catch (e) {
      return _buildErrorIcon();
    }
  }

  void _expandImage(BuildContext context) {
    goTo(
      context,
      Scaffold(
        backgroundColor: Colors.black38,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: CloseButton(color: Colors.white.withValues(alpha:.5)),
        ),
        body: Center(
          child: InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            child: _buildImageContent(isFullScreen: true, context: context),
          ),
        ),
      ),
      add: true,
    );
  }

  Widget _buildErrorIcon() {
    return Container(
      color: Colors.grey[200],
      child: Icon(Icons.broken_image, size: size, color: Colors.red),
    );
  }

  Widget _buildLoadingSpinner() {
    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
  }
}
