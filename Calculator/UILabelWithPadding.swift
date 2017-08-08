//
//  UILabelWithPadding.swift
//  Calculator
//
//  Created by Lorenzo Norcini on 02/08/2017.
//  Copyright © 2017 Lorenzo Norcini. All rights reserved.
//

import Foundation
import UIKit

class UILabelWithPadding: UILabel {
    override func drawText(in rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()!
        context.stroke(self.bounds.insetBy(dx: 0, dy: 0))
        super.drawText(in: rect.insetBy(dx: 10.0, dy: 10.0))
    }
}
    
