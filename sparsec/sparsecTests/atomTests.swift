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

    func testChar() throws {
        // This is an example of a functional test case.
        let data = "This is a String."
        let state = BasicState(data.unicodeScalars)
        let c:UnicodeScalar = "T"
        let re = try char(c)(state)
        print(re)
    }
    
    func testDigit() throws {
        // This is an example of a functional test case.
        let data = "07500"
        let state = BasicState(data.unicodeScalars)
        let re = try digit(state)
        print(re)
    }

    func testFMapFunction() {
        let x:Int? = 12
        let y:Int = 23
        let r:Int? = x.map({(d:Int)->Int in d+y})
        XCTAssert(r!==35, "Expect a int? is 35 but got \(r)")
    }

    func testEq() throws {
        let data = "b"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "b"
        let re = try eq(c)(state)
        print(re)
    }
    
    func testOne2() throws {
        let data = " "
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = " "
        let re = try eq(c)(state)
        print(re)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
