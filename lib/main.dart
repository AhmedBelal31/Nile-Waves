import 'dart:ui';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/localization/presentation/cubit/localization_cubit.dart';
import 'features/stations/data/models/station_model.dart';
import 'main_screen.dart';
import 'features/stations/presentation/cubit/stations_cubit.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'features/player/presentation/cubit/player_cubit.dart';
import 'generated/l10n.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set window boundaries for desktop platforms
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1000, 800),
      minimumSize: Size(400, 700),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(StationModelAdapter());
  await Hive.openBox('settings');

  // Init DI
  await di.init();

  runApp(const NileWavesApp());
}

class NileWavesApp extends StatelessWidget {
  const NileWavesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<StationsCubit>()),
        BlocProvider(create: (_) => di.sl<FavoritesCubit>()..loadFavorites()),
        BlocProvider(create: (_) => di.sl<PlayerCubit>()),
        BlocProvider(create: (_) => LocalizationCubit()),
      ],
      child: Builder(
        builder: (appContext) {
          return BlocBuilder<LocalizationCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp(
                title: 'Nile Waves',
                debugShowCheckedModeBanner: false,
                locale: locale,
                theme: AppTheme.darkTheme,
                scrollBehavior: const MaterialScrollBehavior().copyWith(
                  dragDevices: {
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.touch,
                    PointerDeviceKind.stylus,
                    PointerDeviceKind.trackpad,
                  },
                ),
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // Supports English and Arabic
            supportedLocales: S.delegate.supportedLocales,
            // Fallback locale if needed
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              if (deviceLocale != null) {
                for (var locale in supportedLocales) {
                  if (locale.languageCode == deviceLocale.languageCode) {
                    return deviceLocale;
                  }
                }
              }
              return supportedLocales.first; // Default is English
            },
            home: const MainScreen(),
          );
        },
      );
    },
  ),
);
  }
}
