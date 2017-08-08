//
//  Stack.swift
//  Calculator
//
//  Created by Lorenzo Norcini on 02/08/2017.
//  Copyright © 2017 Lorenzo Norcini. All rights reserved.
//

import Foundation

public struct Stack<Element> {
    
    private var array: [Element] = []
    
    mutating func push(_ element: Element) {
        array.append(element)
    }
    
    mutating func pop() -> Element? {
        return array.popLast()
    }
    
    func empty() -> Bool{
        return self.array.isEmpty
    }
    
    func peek() -> Element? {
        return array.last
    }
}
