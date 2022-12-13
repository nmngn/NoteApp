//
//  String+.swift
//  MoneyManager
//
//  Created by Nam Ngây on 07/07/2021.
//

import UIKit

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    var length: Int {
        return count
    }
    
    func toImage() -> UIImage? {
         if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
             return UIImage(data: data)
         }
         return nil
     }
}
