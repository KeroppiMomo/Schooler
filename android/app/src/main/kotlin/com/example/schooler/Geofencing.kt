package com.example.schooler

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import android.app.Activity
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.provider.Settings
import android.os.Build
import com.google.android.gms.location.GeofencingEvent
import com.google.android.gms.location.GeofenceStatusCodes
import com.google.android.gms.location.GeofencingClient
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofencingRequest
import com.google.android.gms.common.api.ApiException
import java.lang.Exception
import java.util.*
import kotlin.reflect.KClass
import android.net.Uri


class FlutterException(val code: String, message: String?, val details: String?): Exception(message) {
    companion object {
        fun badArgument(message: String) = FlutterException("BAD_ARGUMENT", message, null)
        fun <T: Any> badArgument(expectedType: KClass<T>) = badArgument("Argument is expected to be '${expectedType.simpleName}'")
        fun <T: Any> badArgument(name: String, expectedType: KClass<T>) = badArgument("'$name' is expected to be '${expectedType.simpleName}'")

        fun unavailable(message: String) = FlutterException("UNAVAILABLE", message, null)
        fun permissionDenied(message: String) = FlutterException("PERMISSION_DENIED", message, null)
        fun maximumGeofencesReached(message: String) = FlutterException("MAX_GEOFENCES_REACHED", message, null)
        fun maximumRadiusReached(message: String) = FlutterException("MAX_RADIUS_REACHED", message, null)
        fun unknown(message: String) = FlutterException("UNKNOWN", message, null)
    }
}

class GeofencingBroadcastReceiver: BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        // This is not GeofenceEvent (similar name)
        val curEvent = GeofencingEvent.fromIntent(intent)
        if (curEvent.hasError()) {
            println(GeofenceStatusCodes.getStatusCodeString(curEvent.errorCode))
            return
        }

        var notificationId = System.currentTimeMillis().toInt() * 100
        for (geofence in curEvent.triggeringGeofences) {
            val id = geofence.requestId

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val notificationManager = context!!.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                val channel = NotificationChannel("reminders", "Reminders", NotificationManager.IMPORTANCE_HIGH)
                notificationManager.createNotificationChannel(channel)
            }
            var title = Geofencing.getGeofenceName(context!!, id)
            if (title == null) {
                title = id
                println("Could not retrieve geofence name")
            }

            val notification = NotificationCompat.Builder(context!!, "reminders")
                    .setSmallIcon(context.resources.getIdentifier("notification_icon", "drawable", context.packageName))
                    .setContentTitle(title)
                    .setContentText("Schooler Reminder")
                    .setPriority(NotificationCompat.PRIORITY_HIGH)
                    .setVisibility(NotificationCompat.VISIBILITY_PRIVATE)
                    .setCategory(NotificationCompat.CATEGORY_REMINDER)
                    .build()

            NotificationManagerCompat.from(context).notify(notificationId, notification)
            notificationId++
        }
    }
}

object Geofencing {
    enum class GeofenceEvent(val value: Int) {
        ENTER(0),
        EXIT(1);

        companion object {
            fun fromInt(value: Int) = if (value == 0) ENTER else EXIT
        }
    }

    const val LOCATION_PERMISSION_REQUEST_CODE = 99

    /** Used for requestPermission to wait for permission change to return. */
    private var requestPermissionCallback: (Boolean)->Unit = {}
    /** A geofencing client for the plugin. */
    private var geofencingClient: GeofencingClient? = null

    /** For `getGeofencePendingIntent` to return a single lazy object every time it is called. */
    private var geofencePendingIntentLazyCache: PendingIntent? = null

    /** Get the pending intent for adding geofences.
     *
     * This method is lazy and only returns a single object every time this is called.
     */
    private fun getGeofencePendingIntent(activity: Activity): PendingIntent {
        if (geofencePendingIntentLazyCache == null) {
            val intent = Intent(activity, GeofencingBroadcastReceiver::class.java)
            geofencePendingIntentLazyCache = PendingIntent.getBroadcast(activity, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)
        }
        return geofencePendingIntentLazyCache!!
    }

    fun initialize(@NonNull flutterEngine: FlutterEngine, @NonNull activity: Activity) {
        geofencingClient = LocationServices.getGeofencingClient(activity)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.schooler/geofencing").setMethodCallHandler {
            call, result ->
            Geofencing.handleMethodCall(activity, call, result)
        }
    }

    private fun handleMethodCall(@NonNull activity: Activity, @NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        fun handleException(e: FlutterException) {
            result.error(e.code, e.message, e.details)
        }

        try {
            when (call.method) {
                "requestPermission" -> requestPermission(activity) { x -> result.success(x) }
                "openAppsSettings" -> {
                    openAppsSettings(activity)
                    result.success(null)
                }
                "getMaximumRadius" -> result.success(getMaximumRadius())
                "startMonitoring" -> startMonitoring(activity, call.arguments) { error ->
                    if (error == null) result.success(null)
                    else handleException(error)
                }
                "stopMonitoring" -> stopMonitoring(activity, call.arguments) { error ->
                    if (error == null) result.success(null)
                    else handleException(error)
                }
                else -> {
                    result.notImplemented()
                    return
                }
            }
        } catch (e: FlutterException) {
            handleException(e)
        }
    }

    // Exposed methods
    private fun requestPermission(@NonNull activity: Activity, @NonNull completion: (Boolean)->Unit) {
        requestPermissionCallback = { permission ->
            requestPermissionCallback = {}
            completion(permission)
        }
        val permissions = {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                arrayOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_BACKGROUND_LOCATION)
            } else {
                arrayOf(Manifest.permission.ACCESS_FINE_LOCATION)
            }
        }()

        ActivityCompat.requestPermissions(activity, permissions, LOCATION_PERMISSION_REQUEST_CODE)
    }

    private fun openAppsSettings(@NonNull activity: Activity) {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        intent.data = Uri.parse("package:" + activity.packageName)
        activity.startActivity(intent)
    }

    private fun getMaximumRadius() = Double.POSITIVE_INFINITY

    private fun startMonitoring(@NonNull activity: Activity, arguments: Any, completion: (FlutterException?)->Unit) {
        try {
            val argDict = arguments as? HashMap<String, Any>
                    ?: throw FlutterException.badArgument(HashMap::class)
            val id = argDict["id"] as? String
                    ?: throw FlutterException.badArgument("id", String::class)
            val title = argDict["title"] as? String
                    ?: throw FlutterException.badArgument("title", String::class)
            val geofenceEventInt = argDict["geofenceEvent"] as? Int
                    ?: throw FlutterException.badArgument("geofenceEvent", Int::class)
            val geofenceEvent = GeofenceEvent.fromInt(geofenceEventInt)
            val latitude = argDict["latitude"] as? Double
                    ?: throw FlutterException.badArgument("latitude", Double::class)
            val longitude = argDict["longitude"] as? Double
                    ?: throw FlutterException.badArgument("longitude", Double::class)
            val radius = argDict["radius"] as? Int
                    ?: throw FlutterException.badArgument("radius", Int::class)

            val geofence = Geofence.Builder()
                    .setRequestId(id)
                    .setCircularRegion(latitude, longitude, radius.toFloat())
                    .setTransitionTypes(if (geofenceEvent == GeofenceEvent.ENTER) Geofence.GEOFENCE_TRANSITION_ENTER else Geofence.GEOFENCE_TRANSITION_EXIT)
                    .setExpirationDuration(Geofence.NEVER_EXPIRE)
                    .setNotificationResponsiveness(1000)
                    .build()
            val request = GeofencingRequest.Builder()
                    .setInitialTrigger(0)
                    .addGeofence(geofence)
                    .build()

            geofencingClient?.addGeofences(request, getGeofencePendingIntent(activity))?.run {
                addOnSuccessListener {
                    completion(null)
                }
                addOnFailureListener { e ->
                    if (e is ApiException) {
                        completion(when (e.statusCode) {
                            GeofenceStatusCodes.GEOFENCE_NOT_AVAILABLE -> FlutterException.unavailable(e.message ?: "")
                            GeofenceStatusCodes.GEOFENCE_TOO_MANY_GEOFENCES -> FlutterException.maximumGeofencesReached(e.message ?: "")
                            else -> FlutterException(e.statusCode.toString(), e.message ?: "", null)
                        })
                    } else {
                        completion(FlutterException.unknown(e.message ?: ""))
                    }
                }
            }

            setGeofenceName(activity, title, id)
        } catch (e: FlutterException) {
            completion(e)
        }
    }

    private fun stopMonitoring(@NonNull activity: Activity, arguments: Any, completion: (FlutterException?) -> Unit) {
        try {
            val id = arguments as? String ?: throw FlutterException.badArgument(String::class)
            geofencingClient?.removeGeofences(listOf(id))?.run {
                addOnSuccessListener {
                    completion(null)
                }
                addOnFailureListener { e ->
                    if (e is ApiException) {
                        completion(when (e.statusCode) {
                            GeofenceStatusCodes.GEOFENCE_NOT_AVAILABLE -> FlutterException.unavailable(e.message ?: "")
                            else -> FlutterException.unknown("ApiException ${e.statusCode.toString()}: ${e.message}")
                        })
                    } else {
                        completion(FlutterException.unknown(e.message ?: ""))
                    }
                }
            }

            removeGeofenceName(activity, id)
        } catch (e: FlutterException) {
            completion(e)
        }
    }

    // Exposed to MainActivity
    fun onRequestPermissionsResult(activity: Activity, requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            if (grantResults.count() >= 2) {
                requestPermissionCallback(grantResults[1] == PackageManager.PERMISSION_GRANTED)
            } else {
                requestPermissionCallback(false)
            }
        } else {
            if (grantResults.isNotEmpty()
                    && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                requestPermissionCallback(true)
            } else {
                requestPermissionCallback(false)
            }
        }
//        if (grantResults.isNotEmpty() // Not cancalled
//            && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
//            if (ContextCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
//                requestPermissionCallback(true)
//            } else {
//                requestPermissionCallback(false)
//            }
//        } else {
//            // Canceled or denied
//            requestPermissionCallback(false)
//        }
    }

    // Internal helper functions
    /** Identifier of the `SharedPreferences` storing names of geofences. */
    private val GEOFENCE_NAMES_ID = "com.example.schooler.GEOFENCE_NAMES"
    /** Set the name of a geofence to `SharedPreferences` with its ID. */
    fun setGeofenceName(@NonNull context: Context, name: String, id: String) {
        val sharedPref = context.getSharedPreferences(GEOFENCE_NAMES_ID, Context.MODE_PRIVATE)
        with (sharedPref.edit()) {
            putString(id, name)
            commit()
        }
    }
    /** Remove the name of a geofence in `SharedPreferences` with its ID. */
    fun removeGeofenceName(@NonNull context: Context, id: String) {
        val sharedPref = context.getSharedPreferences(GEOFENCE_NAMES_ID, Context.MODE_PRIVATE)
        with (sharedPref.edit()) {
            remove(id)
            commit()
        }
    }
    /** Retrieve the name of a geofence in `SharedPreferences` with its ID. */
    fun getGeofenceName(@NonNull context: Context, id: String): String? {
        val sharedPref = context.getSharedPreferences(GEOFENCE_NAMES_ID, Context.MODE_PRIVATE)
        return sharedPref.getString(id, null)
    }

}
