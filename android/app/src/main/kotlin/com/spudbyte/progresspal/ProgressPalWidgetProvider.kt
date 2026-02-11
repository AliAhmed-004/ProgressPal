package com.spudbyte.progresspal

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class ProgressPalWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { appWidgetId ->
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val currentStreak = prefs.getInt("currentStreak", 0)
        val highestStreak = prefs.getInt("highestStreak", 0)
        val weekData = prefs.getString("weekData", "0000000") ?: "0000000"
        val isCompletedToday = prefs.getBoolean("isCompletedToday", false)




        val views = RemoteViews(context.packageName, R.layout.progresspal_widget)
        views.setTextViewText(R.id.widget_current_streak_text, "Current Streak: $currentStreak")
        views.setTextViewText(R.id.widget_highest_streak_text, "Highest Streak: $highestStreak")
        views.setTextViewText(R.id.widget_message_text, if(isCompletedToday) "Well Done!" else "Don't give up now!")

        val dotIds = listOf(
            R.id.widget_day_dot_0,
            R.id.widget_day_dot_1,
            R.id.widget_day_dot_2,
            R.id.widget_day_dot_3,
            R.id.widget_day_dot_4,
            R.id.widget_day_dot_5,
            R.id.widget_day_dot_6
        )

        dotIds.forEachIndexed { index, viewId ->
            val isComplete = weekData.getOrNull(index) == '1'
            views.setImageViewResource(viewId,
                if (weekData[index] == '1')
                    R.drawable.widget_day_active
                else
                    R.drawable.widget_day_inactive
            )

        }

        val intent = Intent(context, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
