//
//  Model.swift
//  Calculator
//
//  Created by Анатолий Миронов on 15.02.2022.
//

import Foundation

struct OperationsType {
    // MARK: - Operation groups
    enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case factorial((Int) -> Int)
        case memory
        case equals
    }

    // MARK: - Operation types
    var operations: [String: Operation] = [
        "AC": Operation.constant(0),
        "e": Operation.constant(M_E),
        "π": Operation.constant(Double.pi),

        "√": Operation.unaryOperation(sqrt),
        "log₂": Operation.unaryOperation(log2),
        "log₁₀": Operation.unaryOperation(log10),
        "ln": Operation.unaryOperation(log),
        "cos": Operation.unaryOperation(cos),
        "sin": Operation.unaryOperation(sin),
        "tan": Operation.unaryOperation(tan),
        "asin": Operation.unaryOperation(asin),
        "acos": Operation.unaryOperation(acos),
        "atan": Operation.unaryOperation(atan),
        "%": Operation.unaryOperation({ $0 / 100 }),
        "+/-": Operation.unaryOperation({ -$0 }),
        "x²": Operation.unaryOperation({ $0 * $0 }),
        "x³": Operation.unaryOperation({ $0 * $0 * $0 }),
        
        "xʸ": Operation.binaryOperation({ pow($0, $1) }),
        "÷": Operation.binaryOperation({ $0 / $1 }),
        "×": Operation.binaryOperation({ $0 * $1 }),
        "-": Operation.binaryOperation({ $0 - $1 }),
        "+": Operation.binaryOperation({ $0 + $1 }),
        
        "x!": Operation.factorial({ $0 }),
        
        "m+": Operation.memory,
        "m-": Operation.memory,
        "mr": Operation.memory,
        "mc": Operation.memory,
        
        "=": Operation.equals,
    ]
}



