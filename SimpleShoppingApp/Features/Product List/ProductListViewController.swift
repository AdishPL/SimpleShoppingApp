//
//  ProductListViewController.swift
//  SimpleShoppingApp
//
//  Created by Adrian Kaczmarek on 21/04/2024.
//

import UIKit
import RxSwift
import RxCocoa

class ProductListViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let viewModel: ProductListViewModel

    // UI Elements
    private let productTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ProductTableViewCell.self, forCellReuseIdentifier: "ProductCell")
        return tableView
    }()

    private let checkoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Checkout", for: .normal)
        return button
    }()

    private let basketTotalLabel: UILabel = {
        let label = UILabel()
        label.text = "0.00"
        return label
    }()

    init(viewModel: ProductListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        layoutUI()
        bindViewModel()
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = "Product List"

        [productTableView, checkoutButton, basketTotalLabel].forEach(view.addSubview)
    }

    private func layoutUI() {
        productTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            productTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            productTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            productTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            productTableView.bottomAnchor.constraint(equalTo: checkoutButton.topAnchor, constant: -16) // Spacing
        ])

        checkoutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            checkoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        basketTotalLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            basketTotalLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            basketTotalLabel.centerYAnchor.constraint(equalTo: checkoutButton.centerYAnchor)
        ])
    }

    private func configureCell(_ cell: ProductTableViewCell, with product: Product) {
        cell.configure(with: product, currencyFormatter: viewModel.formatCurrency)
        bindActions(to: cell, with: product)
        bindBasketState(to: cell, with: product)
    }

    private func bindActions(to cell: ProductTableViewCell, with product: Product) {
        cell.addToBasketObservable
            .map { product }
            .bind(to: viewModel.addItem)
            .disposed(by: cell.disposeBag)

        cell.removeFromBasketObservable
            .map { product }
            .bind(to: viewModel.removeItem)
            .disposed(by: cell.disposeBag)
    }

    private func bindBasketState(to cell: ProductTableViewCell, with product: Product) {
        let isInBasketObservable = viewModel.isInBasket(product: product)
        cell.bind(isInBasket: isInBasketObservable)
    }

    private func bindViewModel() {
        viewModel.products
            .bind(to: productTableView.rx.items(cellIdentifier: "ProductCell", cellType: ProductTableViewCell.self)) { [weak self] index, product, cell in
                self?.configureCell(cell, with: product)
            }
            .disposed(by: disposeBag)

        viewModel.basketTotal
            .bind(to: basketTotalLabel.rx.text)
            .disposed(by: disposeBag)

        checkoutButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.checkoutButtonTapped()
            })
            .disposed(by: disposeBag)

        viewModel.navigateToCheckout = { [weak self] checkoutViewController in
            checkoutViewController.modalPresentationStyle = .popover
            self?.present(checkoutViewController, animated: true, completion: nil)
        }
    }
}
