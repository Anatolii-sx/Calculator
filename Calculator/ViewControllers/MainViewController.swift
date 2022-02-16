//
//  MainViewController.swift
//  Calculator
//
//  Created by Анатолий Миронов on 12.02.2022.
//

import UIKit

// MARK: - MainViewProtocol (Connection Presenter -> View)
protocol MainViewProtocol: AnyObject {
    func setDisplayText(_ text: String)
    func showError(message: String)
}

class MainViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet var calculatorButtons: [UIButton]!
    
    // MARK: - Private Properties
    private var presenter: MainPresenterProtocol!
    private var windowInterfaceOrientation: UIInterfaceOrientation? {
        return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
    }
    
    // MARK: - Methods Of ViewController's Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MainPresenter(view: self)
    }
    
    override func viewWillLayoutSubviews() {
        setButtonsCornerRadiusDependOnOrientation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setButtonsCornerRadiusDependOnOrientation()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setButtonsCornerRadius(coordinator: coordinator)
    }
    
    // MARK: - IBActions
    @IBAction func numberButtonTapped(_ sender: UIButton) {
        presenter.numberButtonTapped(
            tappedButton: sender.currentTitle ?? "",
            displayLabelText: displayLabel.text ?? ""
        )
    }
    
    @IBAction func dotButtonTapped() {
        presenter.dotButtonTapped(
            displayLabelText: displayLabel.text ?? ""
        )
    }
    
    @IBAction func operationButtonTapped(_ sender: UIButton) {
        presenter.operationButtonTapped(
            tappedButton: sender.currentTitle ?? "",
            displayLabelText: displayLabel.text ?? ""
        )
    }
    
    // MARK: - Methods Of Setting Buttons Corner Radius
    private func setButtonsCornerRadius(coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
            self.setButtonsCornerRadiusDependOnOrientation()
        })
    }
    
    private func setButtonsCornerRadiusDependOnOrientation() {
        guard let windowInterfaceOrientation = self.windowInterfaceOrientation else { return }
        if windowInterfaceOrientation.isLandscape || UIDevice.current.userInterfaceIdiom == .pad {
            self.calculatorButtons.forEach { $0.layer.cornerRadius = 12 }
        } else {
            calculatorButtons.forEach { $0.layer.cornerRadius = $0.frame.height / 2}
        }
    }
}

// MARK: - Alert Controller
extension MainViewController {
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "⛔️",
            message: message,
            preferredStyle: .alert
        )
        
        let okButton = UIAlertAction(
            title: "OK",
            style: .default,
            handler: { _ in self.presenter.okAlertButtonPressed() }
        )
        
        alert.addAction(okButton)
        present(alert, animated: true)
    }
}

// MARK: - Realization MainViewProtocol Methods (Connection Presenter -> View)
extension MainViewController: MainViewProtocol {
    func setDisplayText(_ text: String) {
        displayLabel.text = text
    }
    
    func showError(message: String) {
        showAlert(message: message)
    }
}

