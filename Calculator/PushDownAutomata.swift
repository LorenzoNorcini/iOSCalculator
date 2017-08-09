//
//  PushDownAutomata.swift
//  Calculator
//
//  Created by Lorenzo Norcini on 02/08/2017.
//  Copyright © 2017 Lorenzo Norcini. All rights reserved.
//

import Foundation

/**
 Indicates a transition from a given state, with a given top of the stack and a given input.
*/

struct Transition: Hashable{
    
    var hashValue: Int {
        return currentState.hashValue ^ tos.hashValue ^ input.hashValue &* 16777619
    }
    
    static func == (lhs: Transition, rhs: Transition) -> Bool{
        return lhs.currentState == rhs.currentState &&
               lhs.tos == rhs.tos &&
               lhs.input == rhs.input
    }
    
    let currentState: State
    let tos: String
    let input: String
    
    init(fromState currentState: State, withTopOfTheStack tos: String, withInput input: String) {
        self.currentState = currentState
        self.tos = tos
        self.input = input
    }
}

/**
 Indicates a possible state for the automata
*/

struct State: Hashable{
    
    var hashValue: Int {
        return final.hashValue ^ id.hashValue &* 16777619
    }
    
    static func == (lhs: State, rhs: State) -> Bool{
        return lhs.final == rhs.final && lhs.id == rhs.id
    }
    
    let final: Bool
    let id: String
    
    init(withID id : String, isFinal final: Bool) {
        self.id = id
        self.final = final
    }
}


/**
 An implementation of a push down automata, uses the Transition and State structs as building blocks for a graph.
 Such graph binds each trasition to the corresponding destination state and specifies the new values to be pushed to the stack.
*/

public class PDA{
    
    var currentState: State
    var initialState: State
    let graph: [Transition: (State, String)]
    var stack = Stack<String>()
    
    init(withGraph graph: [Transition: (State, String)], startingFrom initialState: State) {
        self.graph = graph
        stack.push("Z")
        self.currentState = initialState
        self.initialState = initialState
    }
    
    func reset(){
        while !stack.empty() {
            _ = stack.pop()
        }
        stack.push("Z")
        self.currentState = initialState
    }
    
    public func accept(string: [String]) -> Bool {
        var stringTerminated = string
        stringTerminated.append("eps")
        for c in stringTerminated{
            let transition = Transition(fromState: currentState,
                                        withTopOfTheStack: stack.pop() ?? "no stack",
                                        withInput: c)
            currentState = (graph[transition]?.0) ?? State(withID: "err", isFinal: false)
            if currentState.id == "err"{
                return false
            }
            let valuesToPush = (graph[transition]?.1)!
            for v in Array(valuesToPush.characters){
                stack.push(String(v))
            }
        }
        return currentState.final
    }
}
