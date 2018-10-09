//
//  UIView+RandomColor.swift
//  project
//
//  Created by Stanislav Korolev on 24.02.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import Foundation
import UIKit

class Helper {
    
    static func setStatusBarBackgroundColor(color: UIColor) {
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = color
    }
}
