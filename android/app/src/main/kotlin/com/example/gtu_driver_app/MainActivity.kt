package com.example.ubicacion

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.os.Handler
import android.os.Looper
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import com.google.android.gms.location.*

class MainActivity : FlutterActivity() {

    private val STREAM_CHANNEL = "com.example.gtu_driver_app/stream_ubicacion"
    private val METHOD_CHANNEL = "com.example.gtu_driver_app/bg_service"

    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private var eventSink: EventChannel.EventSink? = null
    private val handler = Handler(Looper.getMainLooper())
    private val locationRunnable = object : Runnable {
        override fun run() {
            sendLocation()
            handler.postDelayed(this, 2500)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, STREAM_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    handler.post(locationRunnable)
                }

                override fun onCancel(arguments: Any?) {
                    handler.removeCallbacks(locationRunnable)
                    eventSink = null
                }
            }
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    val intent = Intent(this, LocationForegroundService::class.java)
                    startForegroundService(intent)
                    result.success(null)
                }
                "stopService" -> {
                    stopService(Intent(this, LocationForegroundService::class.java))
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun sendLocation() {
        if (eventSink == null) return 

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
            != PackageManager.PERMISSION_GRANTED) {
            eventSink?.error("PERMISO", "Permiso de ubicación no concedido", null)
            return
        }

        fusedLocationClient.lastLocation
            .addOnSuccessListener { location: Location? ->
                if (location != null) {
                    val coordinates = "${location.latitude},${location.longitude}"
                    eventSink?.success(coordinates)
                } else {
                    eventSink?.error("UBICACION", "No se pudo obtener la ubicación", null)
                }
            }
            .addOnFailureListener {
                eventSink?.error("ERROR", "Error al obtener la ubicación", null)
            }
    }

    override fun onDestroy() {
        super.onDestroy()
        stopService(Intent(this, LocationForegroundService::class.java))
        handler.removeCallbacks(locationRunnable)
        eventSink = null
    }
}