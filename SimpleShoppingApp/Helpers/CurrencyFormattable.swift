//
//  CurrencyFormattable.swift
//  SimpleShoppingApp
//
//  Created by Adrian Kaczmarek on 22/04/2024.
//

import Foundation

protocol CurrencyFormattable {
    func formatCurrency(value: Double, code: String) -> String
}

extension CurrencyFormattable {
    private var currencyFormatter: NumberFormatter { // Shared instance
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }

    func formatCurrency(value: Double, code: String) -> String {
        currencyFormatter.currencyCode = code

        // Optional: Set locale for region-specific formatting
        // formatter.locale = Locale(identifier: "fr_FR") // Example: French

        if let formattedString = currencyFormatter.string(from: NSNumber(value: value)) {
            return formattedString
        } else {
            return "\(code) \(value)"  // Fallback if formatting fails
        }
    }
}
