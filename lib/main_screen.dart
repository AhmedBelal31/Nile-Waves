import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:miniplayer/miniplayer.dart';
import 'features/player/presentation/cubit/player_cubit.dart';
import 'features/player/presentation/widgets/mini_player_widget.dart';
import 'features/player/presentation/screens/full_player_screen.dart';
import 'features/stations/presentation/screens/home_screen.dart';
import 'features/player/presentation/widgets/desktop_player_panel.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/responsive.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        mobile: _buildMobileLayout(context),
        tablet: _buildMobileLayout(context), // Tablet retains bottom player
        desktop: _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: HomeScreen()),
        BlocBuilder<PlayerCubit, PlayerState>(
          builder: (context, state) {
            if (state.currentStation != null) {
              return const DesktopPlayerPanel();
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Stack(
      children: [
        // Main content
        const HomeScreen(),
        
        // Persistent MiniPlayer
        BlocBuilder<PlayerCubit, PlayerState>(
          builder: (context, state) {
            if (state.currentStation == null) {
              return const SizedBox.shrink();
            }
            return Align(
              alignment: Alignment.bottomCenter,
              child: Miniplayer(
                minHeight: 120,
                maxHeight: MediaQuery.of(context).size.height,
                builder: (height, percentage) {
                  if (percentage > 0.2) {
                    return const FullPlayerScreen();
                  }
                  return const MiniPlayerWidget();
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
