//
//  atomTest.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/10.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Cocoa
import XCTest

class atomTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testChar() {
        // This is an example of a functional test case.
        let data = "This is a String."
        let state = BasicState(data.unicodeScalars)
        let c:UnicodeScalar = "T"
        let t = char(c)
        let re = t(state)
        switch re {
        case .Success:
            XCTAssert(true, "pass")
        case let .Failed(err):
            XCTAssert(false, "excpet t parsec got 't' but got error: \(err.message)")
        }
    }
    
    func testDigit() {
        // This is an example of a functional test case.
        let data = "07500"
        let state = BasicState(data.unicodeScalars)
        let num = digit
        let re = num(state)
        switch re {
        case let .Failed(err):
            XCTAssert(false, "excpet digit parsec got a digit but error: \(err.message)")
        case .Success:
            XCTAssert(true, "pass")
        }
    }

    func testFMapFunction() {
        let x:Int? = 12
        let y:Int = 23
        let r:Int? = x.map({(d:Int)->Int in d+y})
        XCTAssert(r!==35, "Expect a int? is 35 but got \(r)")
    }

    func testOne1() {
        let data = "b"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "b"
        let re = one(c)(state)
        switch re {
        case .Success:
            XCTAssert(true, "pass")
        case let .Failed(err):
            XCTAssert(false, "excpet b parsec got 'b' but got error: \(err.message)")
        }
    }
    
    func testOne2() {
        let data = " "
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = " "
        let re = one(c)(state)
        switch re {
        case .Success:
            XCTAssert(true, "pass")
        case let .Failed(err):
            XCTAssert(false, "excpet space parsec got 'space' but got error: \(err.message)")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
