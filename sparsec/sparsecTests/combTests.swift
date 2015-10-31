//
//  combTests.swift
//  sparsec
//
//  Created by lincoln on 03/04/2015.
//  Copyright (c) 2015 Dwarf Artisan. All rights reserved.
//
// The testing name of last number is the serial number
//

import Cocoa
import XCTest

class combTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testTry() throws {
        let data = "t1"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "t"
        let re = try attempt(eq(c))(state)
        print("re: \(re)")
    }
    
    func testEither1a() throws {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "u"
        let d: UnicodeScalar = "t"
        let re = try either(attempt(char(c)), char(d))(state)
        print("re, : \(re)")
    }
    
    func testEither2a() throws {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "u"
        let d: UnicodeScalar = "t"
        let re = try either(char(c), char(d))(state)
        print("re: \(re)")
    }
    
    func testEither3a() throws {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "u"
        let d: UnicodeScalar = "v"
        let re = try either(attempt(eq(c)), eq(d))(state)
        print("re: \(re)")
    }
    
    func testEither1b() throws {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "u"
        let d: UnicodeScalar = "t"
        let re = try (attempt(eq(c)) <|> eq(d))(state)
        print("re, status: \(re)")
    }
    
    func testEither2b() throws {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "u"
        let d: UnicodeScalar = "t"
        let re = try (char(c) <|> char(d))(state)
        print("re: \(re)")
    }
    
    func testEither3b() throws {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "u"
        let d: UnicodeScalar = "v"
        let re = try (attempt(char(c)) <|> char(d))(state)
        print("re: \(re)")
    }
    
    func testOtherwise1a() throws {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "t"
        let re = try otherwise(char(c), "data is not equal to c")(state)
        print("re: \(re)")
    }
    
    func testOtherwise2a() throws {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "b"
        let re = try otherwise(char(c), "data is not equal to c")(state)
        print("re: \(re)")
    }
    
    func testOtherwise1b() throws {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "t"
        let re = try (char(c) <?> "data is not equal to c")(state)
        print("re: \(re)")
    }
    
    func testOtherwise2b() throws {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "b"
        let re = try (char(c) <?> "data is not equal to c")(state)
        print("re: \(re)")
    }
    
    func testOption() throws {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "1"
        let d: UnicodeScalar = "d"

        let re = try option(attempt(char(c)), d)(state)
        print("re: \(re)")
    }
    
    func testOneOf1() throws {
        let data = "2"
        let state = BasicState(data.unicodeScalars)
        let c = "3fs2ad1"
        
        let re = try oneOf(c.unicodeScalars)(state)
        print("re: \(re)")
    }
    
    func testOneOf2() throws {
        let data = "b"
        let state = BasicState(data.unicodeScalars)
        let c = "3fs2ad1"
        
        let re = try oneOf(c.unicodeScalars)(state)
        
        print("re: \(re)")
    }

    func testOneOf3() throws {
        let data = " "
        let state = BasicState(data.unicodeScalars)
        let c = "3fs 2ad1"
        
        let re = try oneOf(c.unicodeScalars)(state)
        print("re: \(re)")
    }
    
    func testNoneOf1() throws {
        let data = "b"
        let state = BasicState(data.unicodeScalars)
        let c = "3fs2ad1"
        
        let re = try noneOf(c.unicodeScalars)(state)
        print("re: \(re)")
    }

    func testNoneOf2() throws {
        let data = "2"
        let state = BasicState(data.unicodeScalars)
        let c = "3fs2ad1"
        
        let re = try noneOf(c.unicodeScalars)(state)
        print("(re, status): \(re)")
    }
    
    func testNoneOf3() throws {
        let data = " "
        let state = BasicState(data.unicodeScalars)
        let c = "3fs 2a d1"
        
        let re = try noneOf(c.unicodeScalars)(state)
        print("re: \(re)")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
