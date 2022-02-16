//
//  MainPresenter.swift
//  Calculator
//
//  Created by Анатолий Миронов on 14.02.2022.
//

import Foundation

// MARK: - MainPresenterProtocol (Connection View -> Presenter)
protocol MainPresenterProtocol {
    init(view: MainViewProtocol)
    func numberButtonTapped(tappedButton: String, displayLabelText: String)
    func operationButtonTapped(tappedButton: String, displayLabelText: String)
    func dotButtonTapped(displayLabelText: String)
    func okAlertButtonPressed()
}

class MainPresenter: MainPresenterProtocol {
    // MARK: - Private Properties
    private var calculatorGroupOfOperations = OperationsType()
    private var isUserTyping = false
    private var dotIsPlaced = false
    private var accumulator: Double?
    private var calculatorMemory: Double = 0
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private var result: Double {
        get {
            accumulator ?? 0
        }
        set {
            showNewResult(newValue)
        }
    }
    
    private unowned let view: MainViewProtocol
    
    // MARK: - Realization MainPresenterProtocol Init (Connection View -> Presenter)
    required init(view: MainViewProtocol) {
        self.view = view
    }
    
    // MARK: - Realization MainPresenterProtocol Methods (Connection View -> Presenter)
    func numberButtonTapped(tappedButton: String, displayLabelText: String) {
        if isUserTyping {
            guard displayLabelText.count < 15 else { return }
            let text = displayLabelText + tappedButton
            view.setDisplayText(text)
        } else {
            let text = tappedButton
            view.setDisplayText(text)
            isUserTyping = true
        }
    }
    
    func operationButtonTapped(tappedButton: String, displayLabelText: String) {
        if isUserTyping {
            let number = Double(displayLabelText) ?? 0
            setOperand(number)
            dotIsPlaced = false
            isUserTyping = false
        }
        performOperation(tappedButton)
        getResult()
    }
    
    func dotButtonTapped(displayLabelText: String) {
        if isUserTyping && !dotIsPlaced {
            let text = displayLabelText + "."
            view.setDisplayText(text)
            dotIsPlaced = true
        } else if !isUserTyping && !dotIsPlaced {
            let text = "0."
            view.setDisplayText(text)
            isUserTyping = true
        }
    }
    
    func okAlertButtonPressed() {
        result = 0
    }
    
    // MARK: - Method Of Getting Result
    private func getResult() {
        guard let accumulator = accumulator else { return }
        if accumulator.isNaN {
            view.showError(message: "NaN")
        } else if !accumulator.isFinite {
            view.showError(message: "Получается слишком большое число")
        } else {
            result = accumulator
        }
    }
    
    // MARK: - Method Of Showing New Result
    private func showNewResult(_ newValue: Double) {
        let value = "\(newValue)"
        let valueArray = value.components(separatedBy: ".")
        if valueArray.last == "0" {
            view.setDisplayText(valueArray.first ?? "")
            StorageManager.shared.save(valueArray.first ?? "", completion: nil)
        } else {
            view.setDisplayText("\(newValue)")
            StorageManager.shared.save("\(newValue)", completion: nil)
        }
    }
    
    // MARK: - Methods Of Performing Operations
    private func setOperand(_ operand: Double) {
        accumulator = operand
    }

    private func performOperation(_ symbol: String) {
        if let operation = calculatorGroupOfOperations.operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
            case .unaryOperation(let function):
                guard let accumulator = accumulator else { return }
                self.accumulator = function(accumulator)
            case .binaryOperation(let function):
                guard let accumulator = accumulator else { return }
                pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator)
                self.accumulator = nil
            case .equals:
                performPendingBinaryOperation()
            case .factorial:
                guard let accumulator = accumulator else { return }
                if accumulator.truncatingRemainder(dividingBy: 1) == 0 {
                    let value = Int(accumulator)
                    self.accumulator = Double(getFactorial(value))
                } else {
                    view.showError(message: "Неверный формат числа")
                }
            case .memory:
                memoryFunction(symbol)
            }
        }
    }
    
    private func getFactorial(_ number: Int) -> Int {
        if number == 0 {
           return 1
        } else if number < 0 {
            view.showError(message: "Неверный формат числа")
            return 0
        } else if number < 21 {
            return number * getFactorial(number - 1)
        }
        view.showError(message: "Получается слишком большое число")
        return 0
    }
    
    private func memoryFunction(_ symbol: String) {
        switch symbol {
        case "m+":
            calculatorMemory += accumulator ?? 0
        case "m-":
            calculatorMemory -= accumulator ?? 0
        case "mr":
            accumulator = calculatorMemory
        case "mc":
            calculatorMemory = 0
        default:
            break
        }
    }
    
    private func performPendingBinaryOperation() {
        guard let pendingBinaryOperation = pendingBinaryOperation, let accumulator = accumulator else { return }
        self.accumulator = pendingBinaryOperation.perform(with: accumulator)
        dotIsPlaced = false
        isUserTyping = false
    }
    
    // MARK: - Struct Of Pending Binary Operation
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            function(firstOperand, secondOperand)
        }
    }
}
