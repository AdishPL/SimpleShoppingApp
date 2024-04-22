//
//  CurrencyService.swift
//  SimpleShoppingApp
//
//  Created by Adrian Kaczmarek on 21/04/2024.
//

import RxSwift

enum CurrencyServiceError: Error {
    case dataLoadingError(String)
    case parsingError(String)
    case invalidCurrencyCode(String)
}

protocol CurrencyServiceProtocol: CurrencyFormattable {
    func getExchangeRate(for currency: CurrencyCode) -> Observable<Double>
    func getAvailableCurrencyCodes() -> Observable<[CurrencyCode]>
}

class CurrencyServiceFromFile: CurrencyServiceProtocol {
    private var cachedQuotes: [CurrencyCode: Double]?  // Cache the last fetched rates
    private var fetchRatesObservable: Observable<[CurrencyCode: Double]>?
    private(set) var baseCurrency: CurrencyCode = CurrencyCode(baseCurrency: "USD")  // Default to USD

    private func getRates() -> Observable<[CurrencyCode: Double]> {
        if let cachedQuotes = cachedQuotes {
            return .just(cachedQuotes)
        } else if let fetchObservable = self.fetchRatesObservable {
            return fetchObservable
        } else {
            let fetchObservable = fetchExchangeRates().share(replay: 1, scope: .forever)
            self.fetchRatesObservable = fetchObservable

            return fetchObservable.do(onNext: { [weak self] quotes in
                self?.cachedQuotes = quotes
                self?.fetchRatesObservable = nil
            })
        }
    }

    func getExchangeRate(for currency: CurrencyCode) -> Observable<Double> {
        return getRates()
            .map { quotes in
                if currency.code == self.baseCurrency.code {
                    return 1.0 // Default rate for base currency to itself
                }
                guard let rate = quotes[currency] else {
                    throw CurrencyServiceError.invalidCurrencyCode("No rate found for \(currency.code)")
                }
                return rate
            }
    }

    // Method to retrieve available currency codes
    func getAvailableCurrencyCodes() -> Observable<[CurrencyCode]> {
        return getRates().map { quotes in
            Array(quotes.keys) + [self.baseCurrency]  // Ensure base currency is always an option
        }
    }

    private func fetchExchangeRates() -> Observable<[CurrencyCode: Double]> {
        return Observable.create { [weak self] observer in
            if let data = self?.loadJSONData(filename: "rates"),
               let response = self?.parseExchangeRates(data: data),
               response.success {
                self?.baseCurrency = CurrencyCode(baseCurrency: response.source)  // Set the base currency from source
                let quotes = response.quotes
                observer.onNext(quotes)
                observer.onCompleted()
            } else {
                observer.onError(CurrencyServiceError.dataLoadingError("Failed to load or parse exchange rates data"))
            }
            return Disposables.create()
        }
    }

    // Helper method to load JSON data
    private func loadJSONData(filename: String) -> Data? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else { return nil }
        return try? Data(contentsOf: url)
    }

    // Helper to parse the JSON
    private func parseExchangeRates(data: Data) -> CurrencyResponse? {
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(CurrencyResponse.self, from: data)
            return response
        } catch {
            print("Error decoding exchange rates: \(error)")
            return nil
        }
    }
}
