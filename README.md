# nexever_check_plugin
![nexever logo](https://nexever.com/images/logo2.png)

# nexever_check_plugin

## Overview

`nexever_check_plugin` is a Flutter plugin designed to provide platform-specific functionality for checking USB debugging status, VPN connectivity, and device rooting. This plugin integrates with both Android and iOS platforms to enable these checks through Flutter's method channels.

## Features

- **Check USB Debugging**: Determine if USB debugging is enabled on the device.
- **Check VPN Connectivity**: Determine if the device is connected to a VPN.
- **Check Device Root Status**: Determine if the device is rooted (Android only).

## Getting Started

To use this plugin in your Flutter application, follow these steps:

### Installation

Add the plugin to your `pubspec.yaml` file:

# add this permission in [AndroidManifest.xml]
# <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>

```yaml
dependencies:
  flutter:
    sdk: flutter
  nexever_check_plugin:
    git:
      url: https://github.com/sukhchainNexever/nexever_check_plugin.git

