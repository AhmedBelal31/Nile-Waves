import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import '../screens/full_player_screen.dart';
import '../../../../core/theme/app_theme.dart';

class DesktopPlayerPanel extends StatelessWidget {
  const DesktopPlayerPanel({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Responsive.isDesktop(context)) return const SizedBox.shrink();

    return Container(
      width: 380,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border(
          left: BorderSide(
            color: AppTheme.textSecondary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(-5, 0),
          )
        ],
      ),
      child: const FullPlayerScreen(isDesktopPanel: true),
    );
  }
}
