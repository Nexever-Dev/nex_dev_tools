import 'package:flutter/services.dart';

class NexeverCheckPlugin {
  static const MethodChannel _channel = MethodChannel('com.nexever/debugging');

  static Future<bool> get isUsbDebuggingEnabled async {
    final bool isEnabled = await _channel.invokeMethod('isUsbDebuggingEnabled');
    return isEnabled;
  }

  static Future<bool> get isVpnConnected async {
    final bool isConnected = await _channel.invokeMethod('isVpnConnected');
    return isConnected;
  }

  static Future<bool> get isDeviceRooted async {
    final bool isRooted = await _channel.invokeMethod('isDeviceRooted');
    return isRooted;
  }
}
