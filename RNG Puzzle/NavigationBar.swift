//
//  NavigationBar.swift
//  AI Puzzle
//
//  Created by Jonathan Noyola on 7/12/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import UIKit

class NavigationBar: UINavigationBar {

    override func sizeThatFits(size: CGSize) -> CGSize {
    
        if let window = UIApplication.sharedApplication().delegate!.window! {
        let frame = window.frame
        let w = frame.width
        let h = frame.height
        let s = min(w, h)
    
        var size = super.sizeThatFits(size)
        size.height = s * Constants.TITLE_SCALE + 20
        return size
        } else {
            return super.sizeThatFits(size)
        }
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
