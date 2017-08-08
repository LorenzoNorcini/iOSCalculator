//
//  MathEvaluator.swift
//  Calculator
//
//  Created by Lorenzo Norcini on 01/08/2017.
//  Copyright © 2017 Lorenzo Norcini. All rights reserved.
//

import Foundation

/**
 A MathExpressionEvaluator object provides internal methods for preprocessing and exposes the method for evaluating a mathematical formula.
 
 The correctness of the formula to be evaluated is checked using an implementation of PDA (Push Down Automata).
 
 This class uses the Shunting Yard algorithm to convert from prefix to postfix notation.
 
 */

public class MathExpressionEvaluator{
    
    private var pda: PDA
    
    private let arithmeticExprRegex : String = "(\\b\\w*[\\.]?\\w+\\b|[\\(\\)\\+\\*\\-\\/\\^\\√])"
    
    private let delimiters : [String] = ["(", ")"]
    
    
    enum Operation{
        case twoOperandsFunction((Double, Double)->Double)
        case singleOperandFunction((Double)->Double)
        case constant(Double)
        
        var numberOfOperands: Int{
            switch self {
            case .twoOperandsFunction:
                return 2
            case .singleOperandFunction:
                return 1
            default:
                return 0
            }
        }
    }
    
    private var operations : [String : Operation] = [
        
        "π" : Operation.constant( Double.pi ),
        "e" : Operation.constant(    M_E    ),
        
        "+" : Operation.twoOperandsFunction ({  $1 + $0  }),
        "-" : Operation.twoOperandsFunction ({  $1 - $0  }),
        "*" : Operation.twoOperandsFunction ({  $1 * $0  }),
        "/" : Operation.twoOperandsFunction ({  $1 / $0  }),
        "^" : Operation.twoOperandsFunction (     pow     ),
        
        "sin"   : Operation.singleOperandFunction( sin   ),
        "cos"   : Operation.singleOperandFunction( cos   ),
        "log2"  : Operation.singleOperandFunction( log2  ),
        "ln"    : Operation.singleOperandFunction( log   ),
        "log10" : Operation.singleOperandFunction( log10 ),
        "tan"   : Operation.singleOperandFunction( tan   ),
        "abs"   : Operation.singleOperandFunction( abs   ),
        "√"     : Operation.singleOperandFunction( sqrt  )
    ]
    
    
    init() {
        
        let q0 = State(withID: "q0", isFinal: false)
        let q1 = State(withID: "q1", isFinal: false)
        let q2 = State(withID: "q2", isFinal: false)
        let qf = State(withID: "qf", isFinal: true)
        
        let t0 = Transition(fromState: q0, withTopOfTheStack: "Z", withInput: "(")
        let t1 = Transition(fromState: q0, withTopOfTheStack: "(", withInput: "(")
        let t2 = Transition(fromState: q0, withTopOfTheStack: "Z", withInput: "num")
        let t3 = Transition(fromState: q0, withTopOfTheStack: "(", withInput: "num")
        
        let t4 = Transition(fromState: q1, withTopOfTheStack: "(", withInput: ")")
        let t6 = Transition(fromState: q1, withTopOfTheStack: "(", withInput: "op")
        let t5 = Transition(fromState: q1, withTopOfTheStack: "Z", withInput: "op")
        
        let t7 = Transition(fromState: q0, withTopOfTheStack: "Z", withInput: "fun")
        let t8 = Transition(fromState: q0, withTopOfTheStack: "(", withInput: "fun")
        let t9 = Transition(fromState: q2, withTopOfTheStack: "Z", withInput: "(")
        let t10 = Transition(fromState: q2, withTopOfTheStack: "(", withInput: "(")
        
        let t11 = Transition(fromState: q1, withTopOfTheStack: "(", withInput: "fun")
        let t12 = Transition(fromState: q1, withTopOfTheStack: "Z", withInput: "fun")
        
        let tf = Transition(fromState: q1, withTopOfTheStack: "Z", withInput: "eps")
        
        let graph = [
            t0 : (q0 , "Z("),
            t1 : (q0 , "(("),
            t2 : (q1 , "Z" ),
            t3 : (q1 , "(" ),
            t4 : (q1 ,  "" ),
            t5 : (q0 , "Z" ),
            t6 : (q0 , "(" ),
            t7 : (q2 , "Z" ),
            t8 : (q2 , "(" ),
            t9 : (q0 , "Z("),
            t10: (q0 , "(("),
            t11: (q2 , "(" ),
            t12: (q2 , "Z" ),
            tf : (qf ,  "" )
        ]
        
        pda = PDA(withGraph: graph, startingFrom: q0)
        
    }
    
    /**
     
    */
    
    public func addConstant(name: String, value: Double){
        operations[name] = Operation.constant(value)
    }
    
    public func getOperationsList() -> [String]{
        return Array(operations.keys)
    }
    
    /**
     Checks whether a string is a number
     - returns: true if the string can be converted to Double false otherwise
     - parameter value: the string to be checked
     */
    
    private func isNumber(value: String) -> Bool {
        if let _ = Double(value) {
            return true
        }else {
            return false
        }
    }
    
    /**
     Returns the priority level (i.e. the order of evaluation) of the symbol in a mathematical expression.
     - returns: a priority level between 0 and 3.
     - parameter operatorSymbol: a symbol of operation, either an operator or a function.
     */
    
    private func getPriorityLevel(operatorSymbol : String) -> Int {
        if ["^"].contains(operatorSymbol) || operations[operatorSymbol]?.numberOfOperands == 1 {
            return 3
        } else if ["*", "/"].contains(operatorSymbol){
            return 2
        } else if ["+", "-"].contains(operatorSymbol){
            return 1
        } else {
            return 0
        }
    }
    
    
    /**
     An implementation of the [Dijkstra's Shunting Yard algorithm]( https://en.wikipedia.org/wiki/Shunting-yard_algorithm ), converts a mathematical formula expressed in infix notation to the corresponding formula in postfix notation (also known as Reverse Polish Notation)
     - returns: a vector containing the tokenized expression in postfix notation.
     - parameter tokenizedExpr: a vector containing a mathematical expression in infix notation.
     - parameter allowedOperators: a vector containing the allowed operators in the expression.
     */
    
    private func shuntingYard(tokenizedExpr: [String], allowedOperators: [String]) -> [String] {
        var operators = Stack<String>()
        var output : [String] = []
        for symbol in tokenizedExpr{
            if isNumber(value: symbol){
                output.append(symbol)
            } else if allowedOperators.contains(symbol){
                let current_symbol_priority = getPriorityLevel(operatorSymbol: symbol)
                while getPriorityLevel(operatorSymbol: operators.peek() ?? "empty") > current_symbol_priority {
                    let new_element = operators.pop()!
                    output.append(new_element)
                }
                operators.push(symbol)
            } else if symbol == "(" {
                operators.push(symbol)
            } else if symbol == ")" {
                while operators.peek() != "(" {
                    let new_element = operators.pop()!
                    output.append(new_element)
                }
                _ = operators.pop()
            }
        }
        while !operators.empty() {
            let new_element = operators.pop()!
            output.append(new_element)
        }
        return output
    }
    
    /**
     Evaluates an RPN (Reverse Polish Notation) expression and returns the resulting value.
     - returns: the result of the evaluated expression.
     - parameter rpnExpr: the RPN expression to be evaluated.
     */
    
    private func evalReversPolishNotation(rpnExpr : [String]) -> Double? {
        var result: [Double] = []
        for symbol in rpnExpr{
            if let op = operations[symbol] {
                switch op {
                case .singleOperandFunction(let fun):
                    result.append(fun(result.popLast()!))
                case .twoOperandsFunction(let fun):
                    result.append(fun(result.popLast()!, result.popLast()!))
                default:
                    continue
                }
            } else if isNumber(value: symbol){
                result.append(Double(symbol)!)
            }
        }
        return result[0]
    }
    
    /**
     Splits a mathematical formula in its components using a regular expression, each components can be replaced with a placeholder value for its corresponding class (i.e. operators, funcions, numbers ecc).
     - returns: a vector containing the formula's components.
     - parameter exprString: the expression to be tokenized.
     - parameter changeWithPlaceholders: a function that replaces the symbols with some choosen values.
     */
    
    private func tokenize(exprString: String, changeWithPlaceholders: ([String])->[String]) -> [String] {
        let tmp = exprString.matchingStrings(regex: arithmeticExprRegex)
        var tokenized : [String] = []
        for el in tmp{
            tokenized.append(el[0])
        }
        tokenized = fixForNegative(tokenizedExpr: tokenized)
        return changeWithPlaceholders(tokenized)
    }
    
    /**
     Adapts a mathematical expression in orderd to deal with negative values (i.e. -3 and -sin(1)).
     - returns: a vector containing the adapted expression.
     - parameter tokenizedExpr: a tokenized expression.
     - note: while using this function simplifies the implementation of both the accepting PDA (Push Down Automata) and the evaluation function of the RPN (Reverse Polish Notation), it's also ugly and I don't like it.
     */
    
    private func fixForNegative(tokenizedExpr expr: [String]) -> [String] {
        var new_expr = expr
        var i = 0
        while i < new_expr.count-1 {
            if String(describing: new_expr[i]) == "(" && String(describing: new_expr[i+1]) == "-" {
                if new_expr.count > i+2 {
                    if isNumber(value: new_expr[i+2]) {
                        new_expr.insert("(", at: i+1)
                        new_expr.insert("0", at: i+2)
                        new_expr.insert(")", at: i+5)
                        i += 5
                    } else if operations[new_expr[i+2]]?.numberOfOperands == 1 {
                        new_expr.insert("0", at: i+1)
                        i += 2
                    }
                }
            }
            i += 1
        }
        if expr.count > 1 && expr[0] == "-"  {
            if isNumber(value:new_expr[1]) {
                new_expr.insert("(", at: 0)
                new_expr.insert("0", at: 1)
                new_expr.insert(")", at: 4)
                i += 5
            }
            if operations[new_expr[1]]?.numberOfOperands == 1 {
                new_expr.insert("0", at: 0)
                i += 1
            }
        }
        return new_expr
    }
    
    
    private func PlaceholdersforPDA(tokens: [String]) -> [String] {
        var newTokens: [String] = []
        for t in tokens{
            if operations[t]?.numberOfOperands == 0 || isNumber(value: t) {
                newTokens.append("num")
            } else if operations[t]?.numberOfOperands == 2 {
                newTokens.append("op")
            } else if operations[t]?.numberOfOperands == 1 {
                newTokens.append("fun")
            } else if ["(",")"].contains(t){
                newTokens.append(t)
            } else {
                newTokens.append("nk")
            }
        }
        return newTokens
    }
    
    private func replaceConstants(tokenizedExpr: [String]) -> [String] {
        var replacedExpr = tokenizedExpr
        for i in 0..<replacedExpr.count {
            if let c = operations[replacedExpr[i]] {
                switch c {
                case .constant(let val):
                    replacedExpr[i] = String(val)
                default:
                    continue
                }
            }
        }
        return replacedExpr
    }
    
    public func eval(expr: String) -> Double? {
        pda.reset()
        let tokenizedForPDA = tokenize(exprString: expr, changeWithPlaceholders: PlaceholdersforPDA)
        if pda.accept(string: tokenizedForPDA){
            let tExpr = tokenize(exprString: expr, changeWithPlaceholders: {$0})
            let rExpr = replaceConstants(tokenizedExpr: tExpr)
            let rpn = shuntingYard(tokenizedExpr: rExpr, allowedOperators: Array(operations.keys))
            return evalReversPolishNotation(rpnExpr: rpn)
        } else{
            return nil
        }
    }
    
}

extension String {
    
    func matchingStrings(regex: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        return results.map { result in
            (0..<result.numberOfRanges).map {
                result.rangeAt($0).location != NSNotFound
                    ? nsString.substring(with: result.rangeAt($0))
                    : ""
            }
        }
    }
    
    func index(of string: String, from startPos: Index? = nil, options: CompareOptions = .literal) -> Index? {
        let startPos = startPos ?? startIndex
        return range(of: string, options: options, range: startPos ..< endIndex)?.lowerBound
    }
}


