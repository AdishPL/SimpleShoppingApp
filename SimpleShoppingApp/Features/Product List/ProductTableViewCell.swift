//
//  ProductTableViewCell.swift
//  SimpleShoppingApp
//
//  Created by Adrian Kaczmarek on 21/04/2024.
//

import UIKit
import RxSwift

final class ProductTableViewCell: UITableViewCell {
    private(set) var disposeBag = DisposeBag()

    private let productNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    private let productPricingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .gray
        return label
    }()

    private let addToBasketButton: UIButton = {
        let button = UIButton(type: .system)
        let plusImage = UIImage(systemName: "plus")
        button.setImage(plusImage, for: .normal)
        button.tintColor = .systemBlue
        button.setTitle(" Add", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)

        return button
    }()

    private let removeFromBasketButton: UIButton = {
        let button = UIButton(type: .system)
        let trashImage = UIImage(systemName: "trash")
        button.setImage(trashImage, for: .normal)
        button.tintColor = .systemRed
        button.setTitle(" Remove", for: .normal)

        return button
    }()

    var addToBasketObservable: Observable<Void> {
        return addToBasketButton.rx.tap.asObservable()
    }

    var removeFromBasketObservable: Observable<Void> {
        return removeFromBasketButton.rx.tap.asObservable()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        layoutUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with product: Product,
                   currencyFormatter: @escaping (Double) -> String) {
        productNameLabel.text = product.name
        productPricingLabel.text = currencyFormatter(product.price) + " \(product.quantityDescription)"
    }

    func bind(isInBasket: Observable<Bool>) {
        isInBasket
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isInBasket in
                self?.addToBasketButton.isHidden = isInBasket
                self?.removeFromBasketButton.isHidden = !isInBasket
            })
            .disposed(by: disposeBag)
    }

    private func setupUI() {
        contentView.addSubview(productNameLabel)
        contentView.addSubview(productPricingLabel)
        contentView.addSubview(addToBasketButton)
        contentView.addSubview(removeFromBasketButton)
    }

    private func layoutUI() {
        productNameLabel.translatesAutoresizingMaskIntoConstraints = false
        productPricingLabel.translatesAutoresizingMaskIntoConstraints = false
        addToBasketButton.translatesAutoresizingMaskIntoConstraints = false
        removeFromBasketButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            productNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            productNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            productNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            productPricingLabel.topAnchor.constraint(equalTo: productNameLabel.bottomAnchor, constant: 4),
            productPricingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            productPricingLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            addToBasketButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            addToBasketButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            removeFromBasketButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            removeFromBasketButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}
