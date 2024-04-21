//
//  ProductService.swift
//  SimpleShoppingApp
//
//  Created by Adrian Kaczmarek on 22/04/2024.
//

import RxSwift

protocol ProductServiceProtocol {
    func getProducts() -> Observable<[Product]>
}

class ProductServiceFromFile: ProductServiceProtocol {
    private let disposeBag = DisposeBag()

    func getProducts() -> Observable<[Product]> {
        return Observable.create { observer in
            if let data = self.loadJSONData(filename: "products") {
                if let products = self.parseProducts(data: data) {
                    observer.onNext(products)
                    observer.onCompleted()
                } else {
                    observer.onError(NSError(domain: "ProductService", code: -1, userInfo: ["message": "Failed to parse products"]))
                }
            } else {
                observer.onError(NSError(domain: "ProductService", code: -1, userInfo: ["message": "Could not load products.json"]))
            }
            return Disposables.create()
        }
    }

    // Helper method to load JSON data
    private func loadJSONData(filename: String) -> Data? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else { return nil }
        return try? Data(contentsOf: url)
    }

    // Helper method to parse JSON into [Product]
    private func parseProducts(data: Data) -> [Product]? {
        let decoder = JSONDecoder()
        do {
            // Assuming your JSON structure
            let products = try decoder.decode([Product].self, from: data)
            return products
        } catch {
            print("Error decoding products: \(error)")
            return nil
        }
    }
}
