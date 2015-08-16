//
//  main.swift
//  Parser
//
//  Created by Alessandro on 27/07/15.
//  Copyright (c) 2015 Alessandro. All rights reserved.
//

import Foundation

let test1 = "3+4*5/6"
let test2 = "(300+23)*(43-21)/(84+7)"
let test3 = "(4+8)*(6-5)/((3-2)*(2+2))"
let test4 = "((10 * 2) + (4 - 5)) / 2"
let test5 = "(7 / 3) / ((1 - 4) * 2) + 1"
let test6 = "cos(sin(pi/2))"
let test7 = "sqrt(2) + abs(2)"
let test8 = "ln(e) + sin(pi/2)"
let test9 = "cos(x)"
let test10 = "10 ^ 2 + (7 * 8) + cos(x)"
let test11 = "1234769.1234*1238746-1234*(12^2)"
let test12 = "abs(-2.5)"

func testTime()
{
    let parser = Parser(expression: test10, error: nil)
    
    let parserStart = NSDate()
    let tokens = parser.parse()
    let parserEnd = NSDate()
    
    println("Parser time: \(parserEnd.timeIntervalSinceDate(parserStart) * 1000.0) ms")
    
    let rpn = RPN(tokens: tokens)
    
    let start = NSDate()

    //let a = rpn.evaluate(start: -1.0, end: 1.0, step: 0.002, inclusive: true, async: false)
    rpn.evaluateWithClosure(start: -1.0, end: 1.0, step: 0.001, inclusive: true, async: true, closure: printa)
    
    let end = NSDate()
    
    println("\(end.timeIntervalSinceDate(start) * 1000.0) ms")
    //println(a.count)
}

func printa(x: Double, y: Double)
{
    //println("\(x) - \(y)")
}

testTime()