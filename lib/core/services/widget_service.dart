import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

/// Service to communicate with the native Android home screen widget.
/// Uses MethodChannel to push playback state and receive widget commands.
class WidgetService {
  static const _channel = MethodChannel('com.abtech.nile_waves/widget');
  static Function()? _onWidgetPlay;
  static Function()? _onWidgetPause;

  /// Initialize the widget service and listen for commands from the native widget.
  static void init({
    required Function() onWidgetPlay,
    required Function() onWidgetPause,
  }) {
    if (kIsWeb || !Platform.isAndroid) return;

    _onWidgetPlay = onWidgetPlay;
    _onWidgetPause = onWidgetPause;

    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'widgetPlay':
          _onWidgetPlay?.call();
          break;
        case 'widgetPause':
          _onWidgetPause?.call();
          break;
      }
    });
  }

  /// Update the widget UI with the current station name and play state.
  static Future<void> updateWidget({
    required String stationName,
    required bool isPlaying,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      await _channel.invokeMethod('updateWidget', {
        'stationName': stationName,
        'isPlaying': isPlaying,
      });
    } on PlatformException catch (_) {
      // Widget may not be placed on home screen, silently ignore
    }
  }

  /// Save the last played station info so the widget can read it even after app restart.
  static Future<void> saveLastStation({
    required String stationName,
    required String stationUrl,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      await _channel.invokeMethod('saveLastStation', {
        'stationName': stationName,
        'stationUrl': stationUrl,
      });
    } on PlatformException catch (_) {
      // Silently ignore
    }
  }
}
