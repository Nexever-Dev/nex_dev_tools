import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nexever_check_plugin/nexever_check_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isUsbDebugging = false;
  bool isVpnConnected = false;
  bool isDeviceRooted = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    try {
      try {
        isUsbDebugging = await NexeverCheckPlugin.isUsbDebuggingEnabled;
      } catch (e, s) {
        printLog(e.toString() + s.toString());
      }
      try {
        isVpnConnected = await NexeverCheckPlugin.isVpnConnected;
      } catch (e, s) {
        printLog(e.toString() + s.toString());
      }
      try {
        isDeviceRooted = await NexeverCheckPlugin.isDeviceRooted;
      } catch (e, s) {
        printLog(e.toString() + s.toString());
      }
      printLog('USB Debugging Enabled: $isUsbDebugging');
      printLog('VPN Connected: $isVpnConnected');
      printLog('Device Rooted: $isDeviceRooted');
    } catch (e, s) {
      printLog('$e $s');
    }

    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: [
            InkWell(
              onTap: () => initPlatformState(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.sync),
              ),
            )
          ],
        ),
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('isUsbDebugging: $isUsbDebugging\n'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('isVpnConnected: $isVpnConnected\n'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('isDeviceRooted: $isDeviceRooted\n'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void printLog(
  dynamic text, {
  dynamic fun = "",
}) {
  if (kDebugMode) {
    if (Platform.isIOS) {
      print("$fun ()=> ${text.toString()}");
    } else {
      print('\x1B[31m${"$fun () => "}\x1B[0m\x1B[32m${text.toString()}\x1B[0m');
    }
  }
}
