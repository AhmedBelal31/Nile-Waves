package com.abtech.nile_waves

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.abtech.nile_waves/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidget" -> {
                    val stationName = call.argument<String>("stationName") ?: "Nile Waves"
                    val isPlaying = call.argument<Boolean>("isPlaying") ?: false

                    // Save to SharedPreferences so the widget can read it
                    val prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
                    prefs.edit()
                        .putString("flutter.last_station_name", stationName)
                        .putBoolean("flutter.is_playing", isPlaying)
                        .apply()

                    // Update all widgets
                    NileWavesWidgetProvider.updateAllWidgets(this)

                    result.success(true)
                }
                "saveLastStation" -> {
                    val stationName = call.argument<String>("stationName") ?: ""
                    val stationUrl = call.argument<String>("stationUrl") ?: ""

                    val prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
                    prefs.edit()
                        .putString("flutter.last_station_name", stationName)
                        .putString("flutter.last_station_url", stationUrl)
                        .apply()

                    NileWavesWidgetProvider.updateAllWidgets(this)

                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleWidgetIntent(intent)
    }

    override fun onResume() {
        super.onResume()
        intent?.let { handleWidgetIntent(it) }
    }

    private fun handleWidgetIntent(intent: Intent) {
        when (intent.action) {
            NileWavesWidgetProvider.ACTION_PLAY -> {
                flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                    MethodChannel(messenger, CHANNEL).invokeMethod("widgetPlay", null)
                }
                // Clear the action so it doesn't fire again
                intent.action = null
            }
            NileWavesWidgetProvider.ACTION_PAUSE -> {
                flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                    MethodChannel(messenger, CHANNEL).invokeMethod("widgetPause", null)
                }
                intent.action = null
            }
        }
    }
}
