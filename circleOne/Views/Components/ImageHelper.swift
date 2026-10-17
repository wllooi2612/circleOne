import SwiftUI

#if canImport(AppKit)
import AppKit
public typealias UniversalImage = NSImage
#elseif canImport(UIKit)
import UIKit
public typealias UniversalImage = UIImage
#endif

public struct ImageHelper {
    public static func loadCustomImage(named name: String) -> Image? {
        let extensions = ["jpg", "jpeg", "png", "webp"]
        
        var candidatePaths: [String] = []
        
        // 1. Check Bundle main
        for ext in extensions {
            if let path = Bundle.main.path(forResource: name, ofType: ext) {
                candidatePaths.append(path)
            }
            if let resourcePath = Bundle.main.resourcePath {
                candidatePaths.append("\(resourcePath)/Images/\(name).\(ext)")
                candidatePaths.append("\(resourcePath)/\(name).\(ext)")
            }
        }
        
        // 2. Check Relative paths from execution directory
        for ext in extensions {
            candidatePaths.append("circleOne/Resources/Images/\(name).\(ext)")
            candidatePaths.append("Resources/Images/\(name).\(ext)")
            candidatePaths.append("circleOne.app/Contents/Resources/Images/\(name).\(ext)")
        }
        
        // 3. Absolute known path in workspace
        for ext in extensions {
            candidatePaths.append("/Users/looi1226/.gemini/antigravity-ide/scratch/circleOne/circleOne/Resources/Images/\(name).\(ext)")
        }
        
        // Find first file that exists
        for path in candidatePaths {
            if FileManager.default.fileExists(atPath: path) {
                #if canImport(AppKit)
                if let nsImage = NSImage(contentsOfFile: path) {
                    return Image(nsImage: nsImage)
                }
                #elseif canImport(UIKit)
                if let uiImage = UIImage(contentsOfFile: path) {
                    return Image(uiImage: uiImage)
                }
                #endif
            }
        }
        
        return nil
    }
}
