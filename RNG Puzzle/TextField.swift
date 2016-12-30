//
//  TextField.swift
//  Astro Maze
//
//  Created by Jonathan Noyola on 12/30/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import UIKit

class TextField: UITextField {

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x, y: bounds.origin.y - self.font!.pointSize * 0.13, width: bounds.width, height: bounds.height)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x, y: bounds.origin.y - self.font!.pointSize * 0.13, width: bounds.width, height: bounds.height)
    }

    override func caretRect(for position: UITextPosition) -> CGRect {
        let rect = super.caretRect(for: position)
        return CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height * 0.83)
    }
}
