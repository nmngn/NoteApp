//
//  UIView+.swift
//  MoneyManager
//
//  Created by Nam Ngây on 05/07/2021.
//

import UIKit
import Then

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            clipsToBounds = true
        }
    }
    
    func makeBorderColor() {
        self.layer.do {
            $0.borderWidth = 0.5
            $0.borderColor = UIColor(red: 0.68, green: 0.68, blue: 0.68, alpha: 0.5).cgColor
        }
    }
    
    func makeShadow() {
        self.layer.do {
            $0.masksToBounds = false
            $0.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
            $0.shadowOpacity = 1
            $0.shadowOffset = CGSize(width: 0, height: 1)
            $0.shadowRadius = 4
        }
    }

}

extension UIImageView {
    func applyBlurEffect() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
    }
}
