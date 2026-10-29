import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showSubtitle;

  const AppLogo({
    super.key,
    this.size = 64,
    this.showSubtitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.2),
      child: Image.asset(
        'assets/images/logo.jpg',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppTheme.navyBlue,
            borderRadius: BorderRadius.circular(size * 0.2),
          ),
          child: const Center(
            child: Icon(Icons.school, color: AppTheme.skyBlue),
          ),
        ),
      ),
    );
  }
}
