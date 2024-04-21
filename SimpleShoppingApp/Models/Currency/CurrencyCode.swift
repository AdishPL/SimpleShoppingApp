//
//  CurrencyCode.swift
//  SimpleShoppingApp
//
//  Created by Adrian Kaczmarek on 21/04/2024.
//

import Foundation

struct CurrencyCode: Hashable, Codable {
    let code: String

    init(_ rawCode: String) {
        self.code = String(rawCode.dropFirst(3))  // Assuming the source is always in the format "USDXXX"
    }

    // Designated initializer for base currency which is ommited inside quotes response
    init(baseCurrency: String) {
        self.code = baseCurrency
    }
}
