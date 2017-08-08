//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Lorenzo Norcini on 03/08/2017.
//  Copyright © 2017 Lorenzo Norcini. All rights reserved.
//

import Foundation

public class CalculatorModel{
    
    public var expression: String = ""
    
    private let evaluator : MathExpressionEvaluator = MathExpressionEvaluator()

    public var result: String {
        get {
            return self.compute() ?? "Error"
        }
    }
    
    public var validState: Bool {
        get {
            if result == "Error" {
                return false
            } else {
                return true
            }
        }
    }

    public func addToExpression(symbol: String){
        expression += symbol
    }
    
    public func clearExpression(){
        expression = ""
    }
    
    public func addConstant(name: String, value: Double){
        evaluator.addConstant(name: name, value: value)
    }
    
    public func getOperationsList() -> [String]{
        return evaluator.getOperationsList()
    }
    
    public func deleteSymbol(){
        if expression.characters.count > 0 {
            expression = expression.substring(to: expression.index(before: expression.endIndex))
        }
    }
    
    public func expressionLength() -> Int{
        return expression.characters.count
    }
    
    public func compute() -> String?{
        if let result = evaluator.eval(expr: expression){
            return String(result)
        } else if expression == "" {
            return "0"
        } else {
            return nil
        }
    }
    
}
