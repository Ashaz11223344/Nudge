package com.nudgeapp.nudge

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetProvider

class NudgeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetInfo = appWidgetManager.getAppWidgetInfo(appWidgetId)
            val layoutId = when {
                widgetInfo.minWidth >= 250 && widgetInfo.minHeight >= 200 -> R.layout.widget_large
                widgetInfo.minWidth >= 200 -> R.layout.widget_medium
                else -> R.layout.widget_small
            }

            val views = RemoteViews(context.packageName, layoutId).apply {
                // Get data from SharedPreferences (synced via HomeWidget)
                val quote = widgetData.getString("widget_quote", "Stay strong, stay focused.")
                val streak = widgetData.getInt("widget_streak", 0)
                val mood = widgetData.getString("widget_mood", "Feeling Good")

                setTextViewText(R.id.widget_quote_text, quote)
                
                // Medium/Large widget fields
                if (layoutId == R.layout.widget_medium || layoutId == R.layout.widget_large) {
                    setTextViewText(R.id.widget_streak_text, streak.toString())
                }
                
                // Large widget fields
                if (layoutId == R.layout.widget_large) {
                    setTextViewText(R.id.widget_mood_text, mood)
                }

                // Refresh Button Setup
                val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("nudge://refresh")
                )
                setOnClickPendingIntent(R.id.widget_refresh_button, backgroundIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
