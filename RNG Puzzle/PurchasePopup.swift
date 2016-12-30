//
//  PurchasePopup.swift
//  AI Puzzle
//
//  Created by Jonathan Noyola on 3/25/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import UIKit
import SpriteKit
import StoreKit

class PurchasePopup: SKShapeNode, SKPaymentTransactionObserver {

    var _playScene: PlayScene! = nil
    
    var _cornerRadius: CGFloat = 0
    var _titleLabel: SKLabelNode! = nil
    var _closeLabel: SKLabelNode! = nil
    var _coinLabel: StarLabel! = nil
    
    var _products: [SKProduct]! = nil
    var _productLabels: [StarLabel]? = nil
    
    var _purchaseAmounts = [Int]()

    init(parent: PlayScene, cornerRadius: CGFloat = 10) {
        super.init()
        
        _playScene = parent
        _cornerRadius = cornerRadius
        fillColor = UIColor.white
        
        SKPaymentQueue.default().add(self)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addLabel(_ text: String, color: SKColor, fontSize: CGFloat, x: CGFloat, y: CGFloat) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: Constants.FONT)
        label.text = text
        label.fontColor = color
        label.fontSize = fontSize
        label.position = CGPoint(x: x, y: y)
        self.addChild(label)
        return label
    }
    
    func activate() {
        if !SKPaymentQueue.canMakePayments() {
            AlertManager.defaultManager().alert("Please enable In-App Purchases in Settings -> General -> Restrictions")
        }
    }
    
    func touch(_ p: CGPoint) {
        if isPointInBounds(p, node: _closeLabel) {
            SKPaymentQueue.default().remove(self)
            _playScene.closePurchasePopup()
        } else if _productLabels != nil {
            for i in 0...(_productLabels!.count - 1) {
                if isPointInCoinLabelBounds(p, node: _productLabels![i]) {
                    _purchaseAmounts.insert(ProductManager.defaultManager().getAmount(id: _products[i].productIdentifier), at: 0)
                    _productLabels![i].animate()
                    let payment = SKPayment(product: _products[i])
                    SKPaymentQueue.default().add(payment)
                    break
                }
            }
        }
    }
    
    func isPointInBounds(_ p: CGPoint, node: SKNode) -> Bool {
        let x1 = node.frame.minX - 30
        let x2 = node.frame.maxX + 30
        let y1 = node.frame.minY - 30
        let y2 = node.frame.maxY + 30
        if p.x > x1 && p.x < x2 && p.y > y1 && p.y < y2 {
            return true
        }
        return false
    }
    
    func isPointInCoinLabelBounds(_ p: CGPoint, node: StarLabel) -> Bool {
        let x1 = node.position.x + node._minX
        let x2 = node.position.x + node._maxX
        let y1 = node.position.y + node._minY
        let y2 = node.position.y + node._maxY
        if p.x > x1 && p.x < x2 && p.y > y1 && p.y < y2 {
            return true
        }
        return false
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                var amount = _purchaseAmounts.popLast()
                if amount == nil {
                    amount = 3
                }
                purchaseCoins(amount!)
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .failed:
                if !_purchaseAmounts.isEmpty {
                    _purchaseAmounts.removeLast()
                }
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                
            default:
                break
            }
        }
    }
    
    func purchaseCoins(_ amount: Int) {
        Storage.addStars(amount)
        refreshCoins()
        _coinLabel.animate()
    }
    
    func addProduct(_ product: SKProduct, idx: Int, total: Int) {
        let w = frame.width
        let h = frame.height
        let s = min(w, h)
        
        var titleString = product.localizedTitle
        let len = titleString.characters.count
        for _ in 0...(10 - len) {
            titleString += "  "
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        let priceString = formatter.string(from: product.price)!
        
        let text = "\(titleString)    \(priceString)"
        
        let label = StarLabel(text: text, color: SKColor.black, anchor: .left)
        label.setSize(s * 0.064)
        let x = w * 0.5 - s * 0.3
        let offsetFromCenter = CGFloat(total - 1) / 2 - CGFloat(idx)
        let y = h * 0.47 + s * 0.17 * offsetFromCenter
        label.position = CGPoint(x: x, y: y)
        _productLabels![idx] = label
        addChild(label)
    }

    func refreshLayout(size: CGSize) {
        removeAllChildren()
    
        let rect = CGRect(origin: CGPoint.zero, size: size)
        self.path = CGPath(roundedRect: rect, cornerWidth: _cornerRadius, cornerHeight: _cornerRadius, transform: nil)
        
        let w = frame.width
        let h = frame.height
        let s = min(w, h)
        
        // Title
        _titleLabel = addLabel("Purchase More?", color: SKColor.black, fontSize: s * 0.064, x: w * 0.5, y: h - s * 0.1)
        
        // Close
        _closeLabel = addLabel("Close", color: SKColor.black, fontSize: s * 0.064, x: w * 0.5, y: s * 0.05)
        
        refreshCoins()
        
        refreshProducts()
    }
    
    func refreshCoins() {
        let w = frame.width
        let h = frame.height
        let s = min(w, h)
        
        if _coinLabel != nil {
            _coinLabel.removeFromParent()
        }
        _coinLabel = StarLabel(text: "\(Storage.loadStars())", color: SKColor.black, anchor: .left)
        _coinLabel.setSize(s * Constants.TEXT_SCALE)
        _coinLabel.position = CGPoint(x: s * Constants.ICON_SCALE, y: h - s * Constants.ICON_SCALE)
        _coinLabel.zPosition = 50
        addChild(_coinLabel)
        
        _playScene.updateStarLabel()
    }
    
    func refreshProducts() {
        if _productLabels != nil {
            for productLabel in _productLabels! {
                productLabel.removeFromParent()
            }
        }
        
        if ProductManager.defaultManager()._products != nil {
            _products = ProductManager.defaultManager()._products!
            _productLabels = [StarLabel!](repeating: nil, count: _products.count)
            for i in 0...(_products.count - 1) {
                addProduct(_products[i], idx: i, total: _products.count)
            }
        }
    }
}
