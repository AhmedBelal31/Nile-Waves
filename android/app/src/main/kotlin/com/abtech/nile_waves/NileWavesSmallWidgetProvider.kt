package com.abtech.nile_waves

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context

/**
 * Small widget variant (2x1) — reuses the same logic as the main provider.
 */
class NileWavesSmallWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // Delegate to the main provider's static updater
        NileWavesWidgetProvider.updateAllWidgets(context)
    }

    override fun onReceive(context: Context, intent: android.content.Intent) {
        super.onReceive(context, intent)
        // Forward play/pause actions to the main provider
        NileWavesWidgetProvider.updateAllWidgets(context)
    }
}
