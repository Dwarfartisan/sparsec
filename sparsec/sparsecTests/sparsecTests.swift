//
//  sparsecTests.swift
//  sparsecTests
//
//  Created by Mars Liu on 15/3/4.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Cocoa
import XCTest

class sparsecTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testString() throws {
        let data = "This is a \\\"string\\\"";
        let escape = {( state:BasicState<UStr>) throws ->UChr in
            try char("\\")(state)
            let c = try state.next()
            switch c {
                case "t": return "\t"
                case "n": return "\n"
                case "\"": return "\""
            default:
                throw ParsecError.Parse(pos: state.pos, message: "unknown escape char \(c)")
            }
        }
        
        let strExpr = many1(attempt(noneOf("\\".unicodeScalars)) <|> escape) >>= {(x:[UnicodeScalar]) in
            return eof >> pack(x)
        }
        let state = BasicState(data.unicodeScalars)
        let re = try strExpr(state)
        print(re)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
