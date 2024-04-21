//
//  Product.swift
//  SimpleShoppingApp
//
//  Created by Adrian Kaczmarek on 21/04/2024.
//

import Foundation

struct Product: Codable, Equatable {
    let name: String
    let price: Double
    let quantityDescription: String
}
