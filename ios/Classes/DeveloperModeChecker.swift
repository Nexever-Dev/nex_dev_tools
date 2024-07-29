import Foundation

class DeveloperModeChecker {
    static var isDeveloperModeEnabled: Bool {
        #if DEBUG
        return true
        #else
        return isDeveloperSettingsEnabled()
        #endif
    }

    private static func isDeveloperSettingsEnabled() -> Bool {
        // Check for the presence of developer-related files or settings
        if isDeveloperDiskImagesPresent() || isSimulator() {
            return true
        }
        return false
    }

    private static func isDeveloperDiskImagesPresent() -> Bool {
        let developerDiskImagesPath = "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport"
        print("Checking for developer disk images at \(developerDiskImagesPath)")
        if FileManager.default.fileExists(atPath: developerDiskImagesPath) {
            print("Developer disk images found at \(developerDiskImagesPath)")
            return true
        }
        return false
    }

    private static func isSimulator() -> Bool {
        #if targetEnvironment(simulator)
        print("Running on simulator")
        return true
        #else
        return false
        #endif
    }
}
