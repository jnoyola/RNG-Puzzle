//
//  SKMultilineLabel.swift
//
//  Created by Craig on 10/04/2015
//  Modified by Christopher Klapp on 11/21/2015 for line breaks \n for paragraphs 
//  Copyright (c) 2015 Interactive Coconut. All rights reserved.
//
/*   USE:

(most component parameters have defaults)

let multiLabel = SKMultilineLabel(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", labelWidth: 250, pos: CGPoint(x: size.width / 2, y: size.height / 2))
self.addChild(multiLabel)

*/

import SpriteKit

class SKMultilineLabel: SKNode {
    //props
    var labelWidth:CGFloat {didSet {update()}}
    var labelHeight:CGFloat = 0
    var text:String {didSet {update()}}
    var fontName:String {didSet {update()}}
    var fontSize:CGFloat {didSet {update()}}
    var pos:CGPoint {didSet {update()}}
    var fontColor:SKColor {didSet {update()}}
    var spacing:CGFloat {didSet {update()}}
    var alignment:SKLabelHorizontalAlignmentMode {didSet {update()}}
    var dontUpdate = false
    var shouldShowBorder:Bool = false {didSet {update()}}
    //display objects
    var rect:SKShapeNode?
    var labels:[SKLabelNode] = []
    
    init(text:String, labelWidth:CGFloat, pos:CGPoint, fontName:String="Optima-ExtraBlack",fontSize:CGFloat=10,fontColor:SKColor=SKColor.blackColor(),spacing:CGFloat=1.5, alignment:SKLabelHorizontalAlignmentMode = .Center, shouldShowBorder:Bool = false)
    {
        self.text = text
        self.labelWidth = labelWidth
        self.pos = pos
        self.fontName = fontName
        self.fontSize = fontSize
        self.fontColor = fontColor
        self.spacing = spacing
        self.shouldShowBorder = shouldShowBorder
        self.alignment = alignment
        
        super.init()
        
        self.update()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //if you want to change properties without updating the text field,
    //  set dontUpdate to false and call the update method manually.
    func update() {
        if (dontUpdate) {return}
        if (labels.count>0) {
            for label in labels {
                label.removeFromParent()
            }
            labels = []
        }
        let separators = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        let lineSeparators = NSCharacterSet.newlineCharacterSet()
        let paragraphs = text.componentsSeparatedByCharactersInSet(lineSeparators)

        var lineCount = 0
        for (_, paragraph) in paragraphs.enumerate() {
            let words = paragraph.componentsSeparatedByCharactersInSet(separators)
            var finalLine = false
            var wordCount = -1
            while (!finalLine) {
                lineCount++
                var lineLength = CGFloat(0)
                var lineString = ""
                var lineStringBeforeAddingWord = ""
                
                // creation of the SKLabelNode itself
                let label = SKLabelNode(fontNamed: fontName)
                // name each label node so you can animate it if u wish
                label.name = "line\(lineCount)"
                label.horizontalAlignmentMode = alignment
                label.fontSize = fontSize
                label.fontColor = fontColor
                
                while lineLength < CGFloat(labelWidth)
                {
                    ++wordCount
                    if wordCount > words.count-1
                    {
                        //label.text = "\(lineString) \(words[wordCount])"
                        finalLine = true
                        break
                    }
                    else
                    {
                        lineStringBeforeAddingWord = lineString
                        lineString = "\(lineString) \(words[wordCount])"
                        label.text = lineString
                        lineLength = label.frame.size.width
                    }
                }
                if lineLength > 0 {
                    --wordCount
                    if (!finalLine) {
                        if lineStringBeforeAddingWord == "" {
                            NSLog("Words don't fit! Decrease the font size of increase the labelWidth (\"\(lineString)\")")
                            break
                        }
                        lineString = lineStringBeforeAddingWord
                    }
                    label.text = lineString
                    var linePos = pos
                    if (alignment == .Left) {
                        linePos.x -= labelWidth / 2
                    } else if (alignment == .Right) {
                        linePos.x += labelWidth / 2
                    }
                    linePos.y -= fontSize * spacing * CGFloat(lineCount)
                    label.position = CGPointMake( linePos.x , linePos.y )
                    self.addChild(label)
                    labels.append(label)
                    //print("was \(lineLength), now \(label.frame.size.width)")
                }
            }
        }
        labelHeight = fontSize * CGFloat(lineCount + 1) + fontSize * (spacing - 1) * CGFloat(lineCount)
        
        for label in labels {
            let pos = label.position
            label.position = CGPoint(x: pos.x, y: pos.y + (labelHeight / 2))
        }
        
        showBorder()
    }
    
    func showBorder() {
        if (!shouldShowBorder) {return}
        if let rect = self.rect {
            self.removeChildrenInArray([rect])
        }
        self.rect = SKShapeNode(rectOfSize: CGSize(width: labelWidth, height: labelHeight))
        if let rect = self.rect {
            rect.strokeColor = SKColor.whiteColor()
            rect.lineWidth = 1
            rect.position = CGPoint(x: pos.x, y: pos.y - (labelHeight / 2))
            self.addChild(rect)
        }
    }
}