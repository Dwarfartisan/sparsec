//
//  propsTest.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/27.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Cocoa
import XCTest

class propsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testUnsignedFloat1() {
        // This is an example of a functional test case.
        let data = "3.15926"
        let state = BasicState(data.unicodeScalars)
        let num = unsignedFloat
        let (re, status) = num(state)
        switch status {
        case let .Failed(msg):
            XCTAssert(false, "excpet float parsec got a float but error: \(msg)")
        case .Success:
            XCTAssert(re == data, "float test success and got:\(re)")
        }
    }
    
    func testUnsignedFloat2() {
        // This is an example of a functional test case.
        let data = ".15926"
        let state = BasicState(data.unicodeScalars)
        let num = unsignedFloat
        let (re, status) = num(state)
        switch status {
        case let .Failed(msg):
            XCTAssert(false, "excpet float parsec got a float but error: \(msg)")
        case .Success:
            XCTAssert(re == data, "float test success and got:\(re)")
        }
    }
    
    func testUnsignedFloat3() {
        // This is an example of a functional test case.
        let data = "3.15926f"
        let state = BasicState(data.unicodeScalars)
        let num = unsignedFloat
        let (re, status) = num(state)
        switch status {
        case let .Failed(msg):
            XCTAssert(false, "excpet float parsec got a float but error: \(msg)")
        case .Success:
            XCTAssert(re == "3.15926", "float test success and got:\(re)")
        }
    }
    
    func testUnsignedFloat4() {
        // This is an example of a functional test case.
        let data = "315926"
        let state = BasicState(data.unicodeScalars)
        let num = unsignedFloat
        let (_, status) = num(state)
        switch status {
        case .Failed:
            XCTAssert(true, "pass")
        case .Success:
            XCTAssert(false, "\(data) is not a float")
        }
    }
    
    func testUnsignedFloat5() {
        // This is an example of a functional test case.
        let data = "beras3252.242"
        let state = BasicState(data.unicodeScalars)
        let num = unsignedFloat
        let (_, status) = num(state)
        switch status {
        case .Failed:
            XCTAssert(true, "pass")
        case .Success:
            XCTAssert(false, "\(data) is not a float")
        }
    }
    
    func testFloat1() {
        // This is an example of a functional test case.
        let data = "3.15926"
        let state = BasicState(data.unicodeScalars)
        let num = float
        let (re, status) = num(state)
        switch status {
        case let .Failed(msg):
            XCTAssert(false, "excpet float parsec got a float but error: \(msg)")
        case .Success:
            XCTAssert(re == data, "float test success and got:\(re)")
        }
    }
    
    func testFloat2() {
        // This is an example of a functional test case.
        let data = "-624.3"
        let state = BasicState(data.unicodeScalars)
        let num = float
        let (re, status) = num(state)
        print("re, status : \((re, status))")
        switch status {
        case let .Failed(msg):
            XCTAssert(false, "excpet float parsec got a float but error: \(msg)")
        case .Success:
            XCTAssert(re == data, "float test success and got:\(re)")
        }
    }
    
    func testFloat3() {
        // This is an example of a functional test case.
        let data = "-624.3dsfgasd"
        let state = BasicState(data.unicodeScalars)
        let num = float
        let (re, status) = num(state)
        print("re, status : \((re, status))")
        switch status {
        case let .Failed(msg):
            XCTAssert(false, "excpet float parsec got a float but error: \(msg)")
        case .Success:
            XCTAssert(re == "-624.3", "float test success and got:\(re)")
        }
    }
    
    func testFloat4() {
        // This is an example of a functional test case.
        let data = "-6243"
        let state = BasicState(data.unicodeScalars)
        let num = float
        let (_, status) = num(state)
        switch status {
        case .Failed:
            XCTAssert(true, "pass")
        case .Success:
            XCTAssert(false, "\(data) is not a float")
        }
    }
    
    func testFloat5() {
        // This is an example of a functional test case.
        let data = "315926"
        let state = BasicState(data.unicodeScalars)
        let num = float
        let (_, status) = num(state)
        switch status {
        case .Failed:
            XCTAssert(true, "pass")
        case .Success:
            XCTAssert(false, "\(data) is not a float")
        }
    }
    
    func testFloat6() {
        // This is an example of a functional test case.
        let data = "beras3252.242"
        let state = BasicState(data.unicodeScalars)
        let num = float
        let (_, status) = num(state)
        switch status {
        case .Failed:
            XCTAssert(true, "pass")
        case .Success:
            XCTAssert(false, "\(data) is not a float")
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
