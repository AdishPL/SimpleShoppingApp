//
//  CheckoutViewController.swift
//  SimpleShoppingApp
//
//  Created by Adrian Kaczmarek on 21/04/2024.
//

import UIKit
import RxSwift

final class CheckoutViewController: UIViewController {
    private let viewModel: CheckoutViewModel

    private let disposeBag = DisposeBag()
    private let currencyPicker = UIPickerView()
    private let totalPriceLabel = UILabel()
    private let changeCurrencyButton = UIButton(type: .system)

    init(viewModel: CheckoutViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        view.backgroundColor = .white

        setupTotalPriceLabel()
        setupCurrencyPicker()
        setupChangeCurrencyButton()
    }

    private func setupTotalPriceLabel() {
        totalPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        totalPriceLabel.textAlignment = .center
        totalPriceLabel.font = .systemFont(ofSize: 24)
        view.addSubview(totalPriceLabel)

        NSLayoutConstraint.activate([
            totalPriceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            totalPriceLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            totalPriceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            totalPriceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func setupCurrencyPicker() {
        currencyPicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(currencyPicker)

        NSLayoutConstraint.activate([
            currencyPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currencyPicker.topAnchor.constraint(equalTo: totalPriceLabel.bottomAnchor, constant: 20),
            currencyPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            currencyPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            currencyPicker.heightAnchor.constraint(equalToConstant: 150)
        ])
    }

    private func setupChangeCurrencyButton() {
        changeCurrencyButton.setTitle("Change Currency", for: .normal)
        changeCurrencyButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(changeCurrencyButton)

        NSLayoutConstraint.activate([
            changeCurrencyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changeCurrencyButton.topAnchor.constraint(equalTo: currencyPicker.bottomAnchor, constant: 20),
            changeCurrencyButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func bindViewModel() {
        viewModel.totalPrice
            .bind(to: totalPriceLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.availableCurrencies
            .bind(to: currencyPicker.rx.itemTitles) { _, item in
                return item.code
            }
            .disposed(by: disposeBag)

        currencyPicker.rx.modelSelected(CurrencyCode.self)
            .compactMap { $0.first }
            .bind(to: viewModel.selectedCurrency)
            .disposed(by: disposeBag)

        changeCurrencyButton.rx.tap
            .bind { [weak self] in
                self?.viewModel.recalculateTotalPrice()
            }
            .disposed(by: disposeBag)
    }
}
