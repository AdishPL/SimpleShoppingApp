//
//  CurrencyResponse.swift
//  SimpleShoppingApp
//
//  Created by Adrian Kaczmarek on 21/04/2024.
//

import Foundation

struct CurrencyResponse: Codable {
    let success: Bool
    let timestamp: Int
    let source: String
    let quotes: [CurrencyCode: Double]
}

extension CurrencyResponse {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        timestamp = try container.decode(Int.self, forKey: .timestamp)
        source = try container.decode(String.self, forKey: .source)
        let quotesContainer = try container.decode([String: Double].self, forKey: .quotes)
        quotes = Dictionary(uniqueKeysWithValues: quotesContainer.map { (CurrencyCode($0), $1) })
    }
}
