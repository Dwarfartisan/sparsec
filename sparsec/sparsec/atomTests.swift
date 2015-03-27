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
        var (re, status) = t(state)
        switch status {
        case .Success:
            XCTAssert(true, "pass")
        case let .Failed(msg):
            XCTAssert(false, "excpet t parsec got 't' but got error: \(msg)")
        }
    }
    
    func testDigit() {
        // This is an example of a functional test case.
        let data = "07500"
        let state = BasicState(data.unicodeScalars)
        let d = manyTil(digit, eof)
        var (re, status) = d(state)
        switch status {
        case let .Failed(msg):
            XCTAssert(false, "excpet digit parsec got a digit but error: \(msg)")
        case .Success:
            XCTAssert(true, "pass")
        }
    }
    
    func testFloat() {
        // This is an example of a functional test case.
        let data = "2.3"
        let state = BasicState(data.unicodeScalars)
        let d = unsignedFloat
        var (re, status) = d(state)
        switch status {
        case let .Failed(msg):
            XCTAssert(false, "excpet float parsec got a float but error: \(msg)")
        case .Success:
            XCTAssert(true, "pass")
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
