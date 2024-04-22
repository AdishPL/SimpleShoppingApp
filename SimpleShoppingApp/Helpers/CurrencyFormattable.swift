//
//  CurrencyFormattable.swift
//  SimpleShoppingApp
//
//  Created by Adrian Kaczmarek on 22/04/2024.
//

import Foundation

protocol CurrencyFormattable {
    func formatCurrency(value: Double, code: String?) -> String
    var baseCurrency: CurrencyCode { get }
}

extension CurrencyFormattable {
    private var currencyFormatter: NumberFormatter { // Shared instance
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }

    /// Format into readable price format
    /// - Parameters:
    ///   - value: Actual price
    ///   - code: Currency code (e.g. USD). If empty base currency will be used
    /// - Returns: Formatted price
    func formatCurrency(value: Double, code: String? = nil) -> String {
        let currencyCode = code ?? baseCurrency.code

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode

        if let formattedString = formatter.string(from: NSNumber(value: value)) {
            return formattedString
        } else {
            return "\(currencyCode) \(value)"  // Fallback if formatting fails
        }
    }
}
