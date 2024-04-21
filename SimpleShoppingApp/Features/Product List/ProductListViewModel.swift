//
//  ProductListViewModel.swift
//  SimpleShoppingApp
//
//  Created by Adrian Kaczmarek on 22/04/2024.
//

import RxSwift

class ProductListViewModel: CurrencyFormattable {
    private let productService: ProductServiceProtocol
    private let shoppingBasket: ShoppingBasketProtocol
    private let disposeBag = DisposeBag()

    var navigateToCheckout: ((CheckoutViewController) -> Void)?

    // Observables for the UI
    let products = BehaviorSubject<[Product]>(value: [])
    let basketTotal = BehaviorSubject<String>(value: "0.00") // Initially display 0

    let addItem = PublishSubject<Product>()
    let removeItem = PublishSubject<Product>()

    init(productService: ProductServiceProtocol,
         shoppingBasket: ShoppingBasketProtocol) {
        self.productService = productService
        self.shoppingBasket = shoppingBasket

        fetchProducts()

        // Update the basket total whenever the basket changes
        shoppingBasket.total
            .map { self.formatCurrency(value: $0, code: "USD") } // Format as USD
            .subscribe(onNext: { [weak self] formattedValue in
                self?.basketTotal.onNext(formattedValue) // Update the observable
            })
            .disposed(by: disposeBag)

        addItem.subscribe(onNext: { [weak self] product in
            self?.shoppingBasket.addItem(product: product)
        }).disposed(by: disposeBag)

        removeItem.subscribe(onNext: { [weak self] product in
            self?.shoppingBasket.removeItem(product: product)
        }).disposed(by: disposeBag)
    }

    private func fetchProducts() {
        productService.getProducts()
            .subscribe(onNext: { [weak self] products in
                self?.products.onNext(products)
            })
            .disposed(by: disposeBag)
    }

    func addItemToBasket(product: Product) {
        shoppingBasket.addItem(product: product)
    }

    func removeItemFromBasket(product: Product) {
        shoppingBasket.removeItem(product: product)
    }

    func isInBasket(product: Product) -> Observable<Bool> {
        return shoppingBasket.items.map { basketItems in
            basketItems.contains(where: { $0.product.name == product.name }) // Check by product ID
        }
    }

    func checkoutButtonTapped() {
        self.navigateToCheckout?(createCheckoutViewController())
    }

    private func createCheckoutViewController() -> CheckoutViewController {
        let viewModel = CheckoutViewModel(
            currencyService: CurrencyServiceFromFile(),
            shoppingBasket: shoppingBasket)

        return CheckoutViewController(viewModel: viewModel)
    }
}
