//
//  Color.swift
//  TodoApp
//
//  Created by Neal Archival on 1/9/23.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        // Note: 0xff = 255
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        // sRGB color space clamps each color component — red, green, and blue — to a range of 0 to 1, but SwiftUI colors use an extended sRGB color space
        // so you can use component values outside that range. This makes it possible to create colors using the Color.RGBColorSpace.sRGB (apple documentation)
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
    
    init(hexString: String, opacity: Double = 1.0) {
        // First convert from string
        let regex = try! NSRegularExpression(pattern: "^#[0-9a-f]{6}$", options: .caseInsensitive)
        let matches = regex.matches(in: hexString, range: NSRange(hexString.startIndex..., in: hexString))
        var hexInt: Int?
        if matches.isEmpty {
            print("An invalid hex was provided, reverting to white by default")
            hexInt = 0xf1f1f1 // Default to white
        } else {
            let hexValue = hexString.replacingOccurrences(of: "#", with: "")
            hexInt = Int(hexValue, radix: 16)
        }
        if hexInt == nil {
            print("Failed to convert hex, reverting to white by default")
            hexInt = 0xf1f1f1
        }
        self.init(hex: hexInt!, opacity: opacity)
    }
    
    static let offWhite = Color(hexString: "#FAF9F6", opacity: 1.0)
    
    // Returns a hex: "#ff00aa" as an example
    func getHexCode() -> String? {
        let colorDescription = self.description
        // It is possible for colorDescription to == "Color.red" when using generic SwiftUI colors
        // However, for custom colors, a kCGColorSpaceModelRGB description will be returned
        let regex = try! NSRegularExpression(pattern: #"^kCGColorSpaceModelRGB (0|1|[0-9]+.[0-9]+) (0|1|[0-9]+.[0-9]+) (0|1|[0-9]+.[0-9]+) (0|1|[0-9]+.[0-9]+)[ ]$"#) // colorDescription has a trailing line
        let matches = regex.matches(in: colorDescription, range: NSRange(location: 0, length: colorDescription.count))
        if matches.count == 0 {
            return nil
        }
        let colorComponents = colorDescription.components(separatedBy: " ")
        let red = colorComponents[1]
        let green = colorComponents[2]
        let blue = colorComponents[3]
        let alpha = colorComponents[4]
        // hex if 0, will return 0 not 00
        var redHex = String(Int(Float(red)! * 255), radix: 16)
        if redHex == "0" {
            redHex = "00"
        }
        var greenHex = String(Int(Float(green)! * 255), radix: 16)
        if greenHex == "0" {
            greenHex = "00"
        }
        var blueHex = String(Int(Float(blue)! * 255), radix: 16)
        if blueHex == "0" {
            blueHex = "00"
        }
        let _ = String(Int(Float(alpha)! * 255), radix: 16) // Alpha hex (opacity), in case needed
        let hexCode = "#\(redHex)\(greenHex)\(blueHex)"
        return hexCode
    }
}
