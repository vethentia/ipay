//
//  Swag.swift
//  ApplePaySwag
//
//  Created by Erik.Kerber on 10/21/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import UIKit

enum SwagType {
    
    case delivered
    case electronic
}

func ==(lhs: SwagType, rhs: SwagType) -> Bool {
    
    switch(lhs, rhs) {
        case (.delivered( _), .delivered( _)):
            return true
        
        case (.electronic, .electronic):
            return true
        
        default:
            return false
    }
}

struct Swag {
    
    let image: UIImage?
    
    let title: String
    
    let price: NSDecimalNumber
    
    let description: String
    
    var swagType: SwagType
    
    let shippingPrice: NSDecimalNumber = NSDecimalNumber(string: "5.0")
    
    
    init(image: UIImage?, title: String, price: NSDecimalNumber, type: SwagType, description: String) {
        self.image = image
        self.title = title
        self.price = price
        self.swagType = type
        self.description = description
    }
    
    var priceString: String {
        let dollarFormatter: NumberFormatter = NumberFormatter()
        dollarFormatter.minimumFractionDigits = 2;
        dollarFormatter.maximumFractionDigits = 2;
        return dollarFormatter.string(from: price)!
    }
    
    func total() -> NSDecimalNumber {
        
        if (swagType == SwagType.delivered) {
            
            return price.adding(shippingPrice)
        }
        else {
            return price
        }
    }
}

let shippingPrice: NSDecimalNumber = NSDecimalNumber(string: "5.0")

