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

    func testUnsignedFloat1() throws {
        // This is an example of a functional test case.
        let data = "3.15926"
        let state = BasicState(data.unicodeScalars)
        let re = try ufloat(state)
        print(re)
    }
    
    func testUnsignedFloat2() throws {
        // This is an example of a functional test case.
        let data = ".15926"
        let state = BasicState(data.unicodeScalars)
        let re = try ufloat(state)
        print(re)
    }
    
    func testUnsignedFloat3() throws {
        // This is an example of a functional test case.
        let data = "3.15926f"
        let state = BasicState(data.unicodeScalars)
        let re = try ufloat(state)
        print(re)
    }
    
    func testUnsignedFloat4() throws {
        // This is an example of a functional test case.
        let data = "315926"
        let state = BasicState(data.unicodeScalars)
        let re = try ufloat(state)
        print(re)
    }
    
    func testUnsignedFloat5() throws {
        // This is an example of a functional test case.
        let data = "beras3252.242"
        let state = BasicState(data.unicodeScalars)
        let re = try ufloat(state)
        print(re)
    }
    
    func testFloat1() throws {
        // This is an example of a functional test case.
        let data = "3.15926"
        let state = BasicState(data.unicodeScalars)
        let re = try float(state)
        print(re)
    }
    
    func testFloat2() throws {
        // This is an example of a functional test case.
        let data = "-624.3"
        let state = BasicState(data.unicodeScalars)
        let re = try float(state)
        print("result : \(re)")
        print(re)
    }
    
    func testFloat3() throws {
        // This is an example of a functional test case.
        let data = "-624.3dsfgasd"
        let state = BasicState(data.unicodeScalars)
        let re = try float(state)
        print("re, status : \(re)")
    }
    
    func testFloat4() throws {
        // This is an example of a functional test case.
        let data = "-6243"
        let state = BasicState(data.unicodeScalars)
        let re = try float(state)
        print(re)
    }
    
    func testFloat5() throws {
        // This is an example of a functional test case.
        let data = "315926"
        let state = BasicState(data.unicodeScalars)
        let re = try float(state)
        print(re)
    }
    
    func testFloat6() throws {
        // This is an example of a functional test case.
        let data = "beras3252.242"
        let state = BasicState(data.unicodeScalars)
        let re = try float(state)
        print(re)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
