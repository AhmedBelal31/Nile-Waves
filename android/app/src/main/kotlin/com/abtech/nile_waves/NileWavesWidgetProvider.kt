package com.abtech.nile_waves

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews

class NileWavesWidgetProvider : AppWidgetProvider() {

    companion object {
        const val PREFS_NAME = "FlutterSharedPreferences"
        const val ACTION_PLAY = "com.abtech.nile_waves.ACTION_PLAY"
        const val ACTION_PAUSE = "com.abtech.nile_waves.ACTION_PAUSE"
        const val KEY_STATION_NAME = "flutter.last_station_name"
        const val KEY_STATION_URL = "flutter.last_station_url"
        const val KEY_IS_PLAYING = "flutter.is_playing"

        fun updateAllWidgets(context: Context) {
            val intent = Intent(context, NileWavesWidgetProvider::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            }
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, NileWavesWidgetProvider::class.java)
            )
            intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            context.sendBroadcast(intent)
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        when (intent.action) {
            ACTION_PLAY -> {
                // Update state to playing
                val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                prefs.edit().putBoolean(KEY_IS_PLAYING, true).apply()

                // Send command to Flutter via launching the app with an action
                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    action = ACTION_PLAY
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                }
                context.startActivity(launchIntent)

                // Update all widgets
                updateAllWidgets(context)
            }
            ACTION_PAUSE -> {
                val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                prefs.edit().putBoolean(KEY_IS_PLAYING, false).apply()

                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    action = ACTION_PAUSE
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                }
                context.startActivity(launchIntent)

                updateAllWidgets(context)
            }
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val prefs: SharedPreferences =
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        val stationName = prefs.getString(KEY_STATION_NAME, "Nile Waves") ?: "Nile Waves"
        val isPlaying = prefs.getBoolean(KEY_IS_PLAYING, false)

        // Determine which layout to use based on widget size
        val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
        val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 250)

        if (minWidth >= 200) {
            // Medium layout
            val views = RemoteViews(context.packageName, R.layout.widget_layout)
            configMediumWidget(context, views, stationName, isPlaying)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        } else {
            // Small layout
            val views = RemoteViews(context.packageName, R.layout.widget_layout_small)
            configSmallWidget(context, views, stationName, isPlaying)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun configMediumWidget(
        context: Context,
        views: RemoteViews,
        stationName: String,
        isPlaying: Boolean
    ) {
        // Station name
        views.setTextViewText(R.id.widget_station_name, stationName)

        // Now playing label
        views.setTextViewText(
            R.id.widget_now_playing_label,
            if (isPlaying) "NOW PLAYING" else "PAUSED"
        )

        // Play/Pause icon
        views.setImageViewResource(
            R.id.widget_play_pause_button,
            if (isPlaying) R.drawable.ic_pause else R.drawable.ic_play
        )

        // Waveform bars visibility
        views.setViewVisibility(
            R.id.widget_waveform,
            if (isPlaying) View.VISIBLE else View.GONE
        )

        // Play/Pause click action
        val actionIntent = Intent(context, NileWavesWidgetProvider::class.java).apply {
            action = if (isPlaying) ACTION_PAUSE else ACTION_PLAY
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context, 0, actionIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_play_pause_button, pendingIntent)

        // Click on widget body opens the app
        val openIntent = Intent(context, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        val openPendingIntent = PendingIntent.getActivity(
            context, 1, openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_root, openPendingIntent)
    }

    private fun configSmallWidget(
        context: Context,
        views: RemoteViews,
        stationName: String,
        isPlaying: Boolean
    ) {
        // Station name
        views.setTextViewText(R.id.widget_station_name_small, stationName)

        // Play/Pause icon
        views.setImageViewResource(
            R.id.widget_play_pause_button_small,
            if (isPlaying) R.drawable.ic_pause else R.drawable.ic_play
        )

        // Play/Pause click action
        val actionIntent = Intent(context, NileWavesWidgetProvider::class.java).apply {
            action = if (isPlaying) ACTION_PAUSE else ACTION_PLAY
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context, 2, actionIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_play_pause_button_small, pendingIntent)

        // Click on widget body opens the app
        val openIntent = Intent(context, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        val openPendingIntent = PendingIntent.getActivity(
            context, 3, openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_root_small, openPendingIntent)
    }
}
