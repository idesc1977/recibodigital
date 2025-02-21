package com.ar.emicardigital.recibo_digital

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)

        // Crear el canal de notificación si la versión de Android lo requiere
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "default_notification_channel" // ID del canal
            val channelName = "Default Notifications" // Nombre visible del canal
            val channelDescription = "Este es el canal predeterminado para las notificaciones." // Descripción

            val importance = NotificationManager.IMPORTANCE_DEFAULT // Nivel de importancia
            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = channelDescription
            }

            // Registrar el canal en el sistema
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager?.createNotificationChannel(channel)
        }
    }
}
