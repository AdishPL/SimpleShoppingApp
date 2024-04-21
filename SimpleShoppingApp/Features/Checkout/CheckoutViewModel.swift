//
//  CheckoutViewModel.swift
//  SimpleShoppingApp
//
//  Created by Adrian Kaczmarek on 21/04/2024.
//

import RxSwift

final class CheckoutViewModel {
    let currencyService: CurrencyServiceProtocol
    private let shoppingBasket: ShoppingBasketProtocol
    private let disposeBag = DisposeBag()

    // Observables for the total and selected currency
    let totalPrice = BehaviorSubject<String>(value: "")
    let selectedCurrency = BehaviorSubject<CurrencyCode>(value: CurrencyCode(baseCurrency: "USD")) // Default to USD

    var availableCurrencies: Observable<[CurrencyCode]> {
        return currencyService.getAvailableCurrencyCodes()
    }

    init(currencyService: CurrencyServiceProtocol,
         shoppingBasket: ShoppingBasketProtocol) {
        self.currencyService = currencyService
        self.shoppingBasket = shoppingBasket

        // Set up binding to reactively calculate total price upon any changes in total or currency
        setupTotalPriceBinding()
    }

    private func setupTotalPriceBinding() {
        Observable.combineLatest(shoppingBasket.total, selectedCurrency)
            .flatMapLatest { [weak self] total, currencyCode -> Observable<String> in
                guard let self = self else { return .empty() }
                return self.currencyService.getExchangeRate(for: currencyCode)
                    .map { rate in
                        let totalInCurrency = total * rate
                        return "\(totalInCurrency) \(currencyCode.code)"
                    }
            }
            .bind(to: totalPrice)
            .disposed(by: disposeBag)
    }

    public func recalculateTotalPrice() {
        if let currentCurrency = try? selectedCurrency.value() {
            selectedCurrency.onNext(currentCurrency)
        } else {
            print("Failed to fetch the current currency value.")
        }
    }
}
