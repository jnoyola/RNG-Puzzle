//
//  Constants.swift
//  AI Puzzle
//
//  Created by Jonathan Noyola on 7/10/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

public class Constants {

    static let FONT = "LIMBO" // "Optima-ExtraBlack"
    static let TITLE_SCALE: CGFloat = 0.12
    static let TEXT_SCALE: CGFloat = 0.08
    static let ICON_TO_TEXT_SCALE: CGFloat = 1.3
    static let ICON_SCALE = TEXT_SCALE * ICON_TO_TEXT_SCALE
    static let TITLE_COLOR = UIColor.cyanColor()
    
    static let HINT_COST = 5
    
    static func colorForLevel(level: Int) -> UIColor {
        let h = CGFloat((level + 35) % 50) / 50
        let s = min(1, 0.3 + 0.7 * CGFloat(level) / 200)
        let v = min(1, 0.5 + 0.5 * CGFloat(level) / 200)
        return UIColor(hue: h, saturation: s, brightness: v, alpha: 1)
    }
}
