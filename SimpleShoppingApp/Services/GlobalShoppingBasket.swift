//
//  GlobalShoppingBasket.swift
//  SimpleShoppingApp
//
//  Created by Adrian Kaczmarek on 21/04/2024.
//

import RxSwift

protocol ShoppingBasketProtocol {
    var items: BehaviorSubject<[GlobalShoppingBasket.BasketItem]> { get }
    var total: BehaviorSubject<Double> { get }
    func addItem(product: Product)
    func removeItem(product: Product)
}

class GlobalShoppingBasket: ShoppingBasketProtocol {
    struct BasketItem {
        let product: Product
        var quantity: Int
    }

    private var basketItems = [BasketItem]()
    private let disposeBag = DisposeBag()

    let items = BehaviorSubject<[BasketItem]>(value: [])
    let total = BehaviorSubject<Double>(value: 0.0)

    func addItem(product: Product) {
        if let index = basketItems.firstIndex(where: { $0.product == product }) {
            basketItems[index].quantity += 1
        } else {
            basketItems.append(BasketItem(product: product, quantity: 1))
        }
        updateObservables()
    }

    func removeItem(product: Product) {
        if let index = basketItems.firstIndex(where: { $0.product == product }) {
            if basketItems[index].quantity > 1 {
                basketItems[index].quantity -= 1
            } else {
                basketItems.remove(at: index)
            }
            updateObservables()
        }
    }

    private func calculateTotal() -> Double {
        basketItems.reduce(0.0) { partialResult, item in
            return partialResult + (item.product.price * Double(item.quantity))
        }
    }

    private func updateObservables() {
        items.onNext(basketItems)
        total.onNext(calculateTotal())
    }
}
