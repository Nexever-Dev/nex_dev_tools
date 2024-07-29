package com.nexever.nexever_check_plugin

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader
import java.util.ArrayList
import java.util.Arrays
import java.util.Scanner

class NexeverCheckPlugin: FlutterPlugin, MethodChannel.MethodCallHandler {
  private lateinit var context: Context
  private lateinit var methodChannel: MethodChannel

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.nexever/debugging")
    methodChannel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "isUsbDebuggingEnabled" -> {
        val isEnabled = isUsbDebuggingEnabled()
        result.success(isEnabled)
      }
      "isVpnConnected" -> {
        val isConnected = isVpnConnected()
        result.success(isConnected)
      }
      "isDeviceRooted" -> {
        val isRooted = isDeviceRooted()
        result.success(isRooted)
      }
      else -> result.notImplemented()
    }
  }

  private fun isUsbDebuggingEnabled(): Boolean {
    return Settings.Global.getInt(context.contentResolver, Settings.Global.ADB_ENABLED, 0) == 1
  }

  private fun isVpnConnected(): Boolean {
    val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    val networkCapabilities = connectivityManager.getNetworkCapabilities(connectivityManager.activeNetwork)
    return networkCapabilities?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) == true
  }

  private fun isDeviceRooted(): Boolean {
    return isPathExist("su") ||
            isSUExist() ||
            isTestBuildKey() ||
            isHaveDangerousApps() ||
            isHaveRootManagementApps() ||
            isHaveDangerousProperties() ||
            isHaveReadWritePermission()
  }

  private fun isPathExist(ext: String): Boolean {
    for (path in ConstantCollections.superUserPath) {
      val joinPath = path + ext
      val file = File(path, ext)
      if (file.exists()) {
        Log.e("ROOT_CHECKER", "Path exists: $joinPath")
        return true
      }
    }
    return false
  }

  private fun isSUExist(): Boolean {
    var process: Process? = null
    return try {
      process = Runtime.getRuntime().exec(arrayOf("/system/xbin/which", "su"))
      val `in` = BufferedReader(InputStreamReader(process.inputStream))
      if (`in`.readLine() != null) {
        Log.e("ROOT_CHECKER", "Command executed")
        true
      } else {
        false
      }
    } catch (e: Exception) {
      false
    } finally {
      process?.destroy()
    }
  }

  private fun isTestBuildKey(): Boolean {
    val buildTags = Build.TAGS
    return if (buildTags != null && buildTags.contains("test-keys")) {
      Log.e("ROOT_CHECKER", "Device built with test key")
      true
    } else {
      false
    }
  }

  private fun isHaveDangerousApps(): Boolean {
    val packages = ArrayList<String>()
    packages.addAll(Arrays.asList(*ConstantCollections.dangerousListApps))
    return isAnyPackageFromListInstalled(packages)
  }

  private fun isHaveRootManagementApps(): Boolean {
    val packages = ArrayList<String>()
    packages.addAll(Arrays.asList(*ConstantCollections.rootsAppPackage))
    return isAnyPackageFromListInstalled(packages)
  }

  private fun isHaveDangerousProperties(): Boolean {
    val dangerousProps = mapOf(
      "ro.debuggable" to "1",
      "ro.secure" to "0"
    )

    val lines = commander("getprop") ?: return false

    for (line in lines) {
      for ((key, badValue) in dangerousProps) {
        if (line.contains(key)) {
          if (line.contains("[$badValue]")) {
            Log.e("ROOT_CHECKER", "Dangerous property found: $key with value $badValue")
            return true
          }
        }
      }
    }
    return false
  }

  private fun isHaveReadWritePermission(): Boolean {
    val lines = commander("mount") ?: return false

    for (line in lines) {
      val args = line.split(" ").toTypedArray()
      if (args.size < 4) continue

      val mountPoint = args[1]
      val mountOptions = args[3]

      for (path in ConstantCollections.notWritablePath) {
        if (mountPoint.equals(path, ignoreCase = true)) {
          for (opt in mountOptions.split(",")) {
            if (opt.equals("rw", ignoreCase = true)) {
              Log.e("ROOT_CHECKER", "Path: $path is mounted with read-write permission: $line")
              return true
            }
          }
        }
      }
    }
    return false
  }

  private fun commander(command: String): Array<String>? {
    return try {
      val inputStream = Runtime.getRuntime().exec(command).inputStream
      val propVal = Scanner(inputStream).useDelimiter("\\A").next()
      propVal.split("\n").toTypedArray()
    } catch (e: Exception) {
      e.printStackTrace()
      null
    }
  }

  private fun isAnyPackageFromListInstalled(pkg: ArrayList<String>): Boolean {
    val pm = context.packageManager
    for (packageName in pkg) {
      try {
        pm.getPackageInfo(packageName, 0)
        return true
      } catch (e: Exception) {
        // Package not found, continue checking
      }
    }
    return false
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
  }
}
