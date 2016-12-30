//
//  ProductManager.swift
//  AI Puzzle
//
//  Created by Jonathan Noyola on 3/25/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import StoreKit

class ProductManager: NSObject, SKProductsRequestDelegate {

    static var _defaultManager: ProductManager? = nil
    
    static func defaultManager() -> ProductManager {
        if _defaultManager == nil {
            _defaultManager = ProductManager()
        }
        return _defaultManager!
    }


    let _ids = [
        "coins3": 0,
        "coins10": 1,
        "coins20": 2,
        "coins100": 3,
        //"coins500": 4
    ]
    let _amounts = [3, 10, 20, 100, 500]
    
    var _products: [SKProduct?]? = nil
    
    func requestProductInfo()
    {
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers: Set(_ids.keys))
            request.delegate = self
            request.start()
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    
        _products = [SKProduct?](repeating: nil, count: response.products.count)
        for product in response.products {
            let i = _ids[product.productIdentifier]
            _products![i!] = product
        }
        
        for product in response.invalidProductIdentifiers {
            NSLog("Product not found: \(product)")
        }
    }
    
    func getAmount(id: String) -> Int {
        return _amounts[_ids[id]!]
    }
}
