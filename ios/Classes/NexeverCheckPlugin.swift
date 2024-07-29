import Flutter
import UIKit
import Network

public class NexeverCheckPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.nexever/debugging", binaryMessenger: registrar.messenger())
        let instance = NexeverCheckPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isUsbDebuggingEnabled":
            result(isUsbDebuggingEnabled())
        case "isVpnConnected":
            result(isVpnActive())
        case "isDeviceRooted":
            result(isDeviceRooted())
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func isUsbDebuggingEnabled() -> Bool {
        // iOS does not provide a direct way to check for USB debugging.
        // Implement necessary iOS-specific functionality or return false.
        return false
    }

    private func isVpnConnected() -> Bool {
        let monitor = NWPathMonitor()
        var isConnected = false
        let semaphore = DispatchSemaphore(value: 0)

        monitor.pathUpdateHandler = { path in
            isConnected = path.usesInterfaceType(.wifi) || path.usesInterfaceType(.cellular)
            semaphore.signal()
        }

        monitor.start(queue: DispatchQueue.global())
        _ = semaphore.wait(timeout: .distantFuture)

        return isConnected
    }
private func isVpnActive() -> Bool {
        let vpnProtocolsKeysIdentifiers = [
            "tap", "tun", "ppp", "ipsec", "utun", "pptp",
        ]

        guard let cfDict = CFNetworkCopySystemProxySettings() else { return false }
        let nsDict = cfDict.takeRetainedValue() as NSDictionary
        guard let keys = nsDict["__SCOPED__"] as? NSDictionary,
              let allKeys = keys.allKeys as? [String] else { return false }

        // Checking for tunneling protocols in the keys
        for key in allKeys {
            for protocolId in vpnProtocolsKeysIdentifiers
            where key.starts(with: protocolId) {
                return true
            }
        }
        return false
    }
    private func isDeviceRooted() -> Bool {
        let fileManager = FileManager.default
        let pathsToCheck = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt",
            "/private/var/lib/cydia",
            "/private/var/mobile/Library/SBSettings/Themes",
            "/private/var/stash",
            "/private/var/tmp/cydia.log",
            "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
            "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
            "/usr/bin/ssh"
        ]

        for path in pathsToCheck {
            if fileManager.fileExists(atPath: path) {
                return true
            }
        }

        // Check if we can write to a file in a restricted directory
        let testFilePath = "/private/check_jailbreak.txt"
        let stringTestWrite = "checking jailbreak..."
        do {
            try stringTestWrite.write(toFile: testFilePath, atomically: true, encoding: .utf8)
            try fileManager.removeItem(atPath: testFilePath)
            return true
        } catch {
            return false
        }
    }
}
