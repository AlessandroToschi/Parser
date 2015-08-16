//
//  MathParserTests.swift
//  MathParserTests
//
//  Created by Alessandro on 13/08/15.
//  Copyright (c) 2015 Alessandro. All rights reserved.
//

import Cocoa
import XCTest

class MathParserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample()
    {
        let parser = Parser(expression: "1234769.1234*1238746-1234*(12^2)", error: nil)
        let tokens = parser.parse()
        let rpn = RPN(tokens: tokens)
        
        println(rpn.evaluate())
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock()
        {
            RPN(tokens: Parser(expression: "10 ^ 2 + (7 * 8) + cos(x)", error: nil).parse()).evaluate(range: 1 ... 10_000, async: true)
        }
    }
    
}
