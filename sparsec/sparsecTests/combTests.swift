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

    func testTry() {
        let data = "t1"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "t"
        let re = `try`(one(c))(state)
        print("re: \(re)")
        switch re {
        case .Success:
            XCTAssert(true, "pass")
        case let .Failed(err):
            XCTAssert(false, "c is equal to data[0] but got error: \(err.message)")
        }
    }
    
    func testEither1a() {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "u"
        let d: UnicodeScalar = "t"
        let re = either(`try`(one(c)), y: one(d))(state)
        print("re, : \(re)")
        switch re {
        case .Success:
            XCTAssert(true, "pass")
        case let .Failed(err):
            XCTAssert(false, "data[0] is equal to c or to d but got error: \(err.message)")
        }
    }
    
    func testEither2a() {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "u"
        let d: UnicodeScalar = "t"
        let re = either(one(c), y: one(d))(state)
        print("re: \(re)")
        switch re {
        case .Success:
            XCTAssert(false, "data[0] is equal to c but got error")
        case .Failed:
            XCTAssert(true)
        }
    }
    
    func testEither3a() {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "u"
        let d: UnicodeScalar = "v"
        let re = either(`try`(one(c)), y: one(d))(state)
        print("re: \(re)")
        switch re {
        case .Success:
            XCTAssert(false, "data is neither equal to c nor to d")
        case .Failed:
            XCTAssert(true)
        }
    }
    
    func testEither1b() {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "u"
        let d: UnicodeScalar = "t"
        let re = (`try`(one(c)) <|> one(d))(state)
        print("re, status: \(re)")
        switch re {
        case .Success:
            XCTAssert(true, "pass")
        case let .Failed(err):
            XCTAssert(false, "data[0] is either equal to c or to d but got error: \(err.message)")
        }
    }
    
    func testEither2b() {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "u"
        let d: UnicodeScalar = "t"
        let re = (one(c) <|> one(d))(state)
        print("re: \(re)")
        switch re {
        case .Success:
            XCTAssert(false, "data[0] is equal to c but error")
        case .Failed:
            XCTAssert(true)
        }
    }
    
    func testEither3b() {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "u"
        let d: UnicodeScalar = "v"
        let re = (`try`(one(c)) <|> one(d))(state)
        print("re: \(re)")
        switch re {
        case .Success:
            XCTAssert(false, "data is neither equal to c nor to d")
        case .Failed:
            XCTAssert(true)
        }
    }
    
    func testOtherwise1a() {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "t"
        let re = otherwise(one(c), message: "data is not equal to c")(state)
        print("re: \(re)")
        switch re {
        case .Success:
            XCTAssert(true)
        case let .Failed(err):
            XCTAssert(false, err.message)
        }
    }
    
    func testOtherwise2a() {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "b"
        let re = otherwise(one(c), message: "data is not equal to c")(state)
        print("re: \(re)")
        switch re {
        case .Success:
            XCTAssert(false)
        case let .Failed(err):
            XCTAssert(true, err.message)
        }
    }
    
    func testOtherwise1b() {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "t"
        let re = (one(c) <?> "data is not equal to c")(state)
        print("re: \(re)")
        switch re {
        case .Success:
            XCTAssert(true)
        case let .Failed(err):
            XCTAssert(false, err.message)
        }
    }
    
    func testOtherwise2b() {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "b"
        let re = (one(c) <?> "data is not equal to c")(state)
        print("re: \(re)")
        switch re {
        case .Success:
            XCTAssert(false)
        case let .Failed(err):
            XCTAssert(true, err.message)
        }
    }
    
    func testOption() {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "1"
        let d: UnicodeScalar = "d"

        let re = option(`try`(one(c)), value: d)(state)
        print("re: \(re)")
        switch re {
        case let .Success(value):
            XCTAssert(value==d, "re is \(value) and equal to \(d)")
        case let .Failed(err):
            XCTAssert(false, err.message)
        }
    }
    
    func testOneOf1() {
        let data = "2"
        let state = BasicState(data.unicodeScalars)
        let c = "3fs2ad1"
        
        let re = oneOf(c.unicodeScalars)(state)
        
        print("re: \(re)")
        switch re {
        case .Success:
            XCTAssert(true)
        case let .Failed(err):
            XCTAssert(false, err.message)
        }
    }
    
    func testOneOf2() {
        let data = "b"
        let state = BasicState(data.unicodeScalars)
        let c = "3fs2ad1"
        
        let re = oneOf(c.unicodeScalars)(state)
        
        print("re: \(re)")
        switch re {
        case .Success:
            XCTAssert(false, "data is not in c")
        case let .Failed(err):
            XCTAssert(true, err.message)
        }
    }

    func testOneOf3() {
        let data = " "
        let state = BasicState(data.unicodeScalars)
        let c = "3fs 2ad1"
        
        let re = oneOf(c.unicodeScalars)(state)
        
        print("re: \(re)")
        switch re {
        case .Success:
            XCTAssert(true, "data \(data) is not in c \(c)")
        case let .Failed(err):
            XCTAssert(false, err.message)
        }
    }
    
    func testNoneOf1() {
        let data = "b"
        let state = BasicState(data.unicodeScalars)
        let c = "3fs2ad1"
        
        let re = noneOf(c.unicodeScalars)(state)
        
        print("re: \(re)")
        switch re {
        case .Success:
            XCTAssert(true)
        case let .Failed(err):
            XCTAssert(false, err.message)
        }
    }

    func testNoneOf2() {
        let data = "2"
        let state = BasicState(data.unicodeScalars)
        let c = "3fs2ad1"
        
        let re = noneOf(c.unicodeScalars)(state)
        
        print("(re, status): \(re)")
        switch re {
        case .Success:
            XCTAssert(false, "data is not in c")
        case let .Failed(err):
            XCTAssert(true, err.message)
        }
    }
    
    func testNoneOf3() {
        let data = " "
        let state = BasicState(data.unicodeScalars)
        let c = "3fs 2a d1"
        
        let re = noneOf(c.unicodeScalars)(state)
        
        print("re: \(re)")
        switch re {
        case .Success:
            XCTAssert(false, "data \(data) is not in c \(c)")
        case let .Failed(err):
            XCTAssert(true, err.message)
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
