//
//  UIColor+RGB255.swift
//  project
//
//  Created by Stanislav Korolev on 01.03.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat){
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: 1)
    }
}
