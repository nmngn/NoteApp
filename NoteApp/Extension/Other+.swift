//
//  Other+.swift
//  MoneyManager
//
//  Created by Nam Ngây on 20/12/2021.
//

import Foundation
import UIKit
import LocalAuthentication

extension UIColor {
    @nonobjc class var disabledGrey: UIColor {
        
        return UIColor(red: 194/255, green: 198/255, blue: 201/255, alpha:1.0)
    }

    @nonobjc class var darkblue: UIColor {
        return UIColor(red: 2.0 / 255.0, green: 21.0 / 255.0, blue: 101.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var primary: UIColor {
        return UIColor(hex: "#00B14F")!
        //UIColor(red: 0 / 255.0, green: 20.0 / 255.0, blue: 35.0 / 255.0, alpha: 1.0)
    }
    
    public convenience init?(hex: String, alpha: CGFloat = 1) {
        let r, g, b: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: alpha)
                    return
                }
            }
        } else {
          let hexColor = hex
          if hexColor.count == 6 {
              let scanner = Scanner(string: hexColor)
              var hexNumber: UInt64 = 0

              if scanner.scanHexInt64(&hexNumber) {
                  r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                  g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                  b = CGFloat(hexNumber & 0x0000ff) / 255

                  self.init(red: r, green: g, blue: b, alpha: alpha)
                  return
              }
          }
        }

        return nil
    }
    
    static func random() -> UIColor {
        return UIColor(
            red:   .random(),
            green: .random(),
            blue:  .random(),
            alpha: 0.5
        )
    }
}

extension NSObject {
    
    var className: String {
        return String(describing: type(of: self)).components(separatedBy: ".").last!
    }
    
    class var className: String {
        return String(describing: self).components(separatedBy: ".").last!
    }
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter
    }()
}

extension Numeric {
    var formattedWithSeparator: String { Formatter.withSeparator.string(for: self) ?? "" }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UILabel {
    func autoResize() {
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = 0.2
        self.numberOfLines = 1
    }
}

extension UIImage {
    func toPngString() -> String? {
         let data = self.pngData()
         return data?.base64EncodedString(options: .endLineWithLineFeed)
     }
}
