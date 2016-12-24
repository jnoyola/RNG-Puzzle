//
//  Trail.swift
//  Astro Maze
//
//  Created by Jonathan Noyola on 8/6/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import SpriteKit

class Trail: CAShapeLayer {
    
    let _duration = 0.7
    let _lineWidth: CGFloat = 1
    let _margin: CGFloat = 0.1

    init(size: CGSize) {
        super.init()
        
        path = hermiteWithPoints(choosePoints(size)).CGPath
        fillColor = UIColor.clearColor().CGColor
        strokeColor = UIColor.blackColor().CGColor
        lineWidth = _lineWidth
        
        animate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func random(a a: CGFloat, b: CGFloat) -> CGFloat{
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * (b - a) + a
    }
    
    func choosePoints(size: CGSize) -> [CGPoint] {
        var points = [CGPoint]()
    
        let w = size.width
        let h = size.height
        let r = max(w, h)
        let pi = CGFloat(M_PI)
    
        let angleStart = random(a: -pi, b: pi)
        points.append(CGPoint(x: r * cos(angleStart), y: r * sin(angleStart)))
        
        points.append(CGPoint(x: random(a: w * 0.25, b: w * 0.75), y: random(a: h * 0.25, b: h * 0.75)))
        
        if rand() % 3 != 0 {
            points.append(CGPoint(x: random(a: w * 0.25, b: w * 0.75), y: random(a: h * 0.25, b: h * 0.75)))
        }
        
        let angleEnd = angleStart + pi + random(a: -pi / 4, b: pi / 4)
        points.append(CGPoint(x: r * cos(angleEnd), y: r * sin(angleEnd)))
        
        return points
    }
    
    func hermiteWithPoints(points: [CGPoint], alpha: CGFloat = 1/3) -> UIBezierPath
    {
        let curve = UIBezierPath()
        
        curve.moveToPoint(points[0])
        
        let n = points.count - 1
        
        for i in 0..<n
        {
            var currentPoint = points[i]
            var nextIndex = (i + 1) % points.count
            var prevIndex = i == 0 ? points.count - 1 : i - 1
            var previousPoint = points[prevIndex]
            var nextPoint = points[nextIndex]
            let endPoint = nextPoint
            var mx : CGFloat
            var my : CGFloat
            
            if i > 0 {
                mx = (nextPoint.x - previousPoint.x) / 2.0
                my = (nextPoint.y - previousPoint.y) / 2.0
            } else {
                mx = (nextPoint.x - currentPoint.x) / 2.0
                my = (nextPoint.y - currentPoint.y) / 2.0
            }
            
            let controlPoint1 = CGPoint(x: currentPoint.x + mx * alpha, y: currentPoint.y + my * alpha)
            currentPoint = points[nextIndex]
            nextIndex = (nextIndex + 1) % points.count
            prevIndex = i
            previousPoint = points[prevIndex]
            nextPoint = points[nextIndex]
            
            if i < n - 1
            {
                mx = (nextPoint.x - previousPoint.x) / 2.0
                my = (nextPoint.y - previousPoint.y) / 2.0
            }
            else
            {
                mx = (currentPoint.x - previousPoint.x) / 2.0
                my = (currentPoint.y - previousPoint.y) / 2.0
            }
            
            let controlPoint2 = CGPoint(x: currentPoint.x - mx * alpha, y: currentPoint.y - my * alpha)
            
            curve.addCurveToPoint(endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        }
        
        return curve
    }
    
    func animate() {
        
        strokeEnd = -_margin
        strokeEnd = 0
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.removeFromSuperlayer()
        })
        
        let startAnim = CABasicAnimation(keyPath: "strokeStart")
        startAnim.duration = _duration
        startAnim.fromValue = -_margin
        startAnim.toValue = 1
    
        let endAnim = CABasicAnimation(keyPath: "strokeEnd")
        endAnim.duration = _duration
        endAnim.fromValue = 0
        endAnim.toValue = 1 + _margin
        
        addAnimation(startAnim, forKey: "strokeStart")
        addAnimation(endAnim, forKey: "strokeEnd")
        
        CATransaction.commit()
    }
}
