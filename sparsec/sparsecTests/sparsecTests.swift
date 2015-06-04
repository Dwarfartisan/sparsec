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
    
    func testString() {
        let data = "This is a \\\"string\\\"";
        var escape = char("\\") >> (
                            try(char("t")>>pack("\t" as UnicodeScalar))
                        <|> try(char("n")>>pack("\n" as UnicodeScalar))
                        <|> try(char("\"")>>pack("\"" as UnicodeScalar))
                        <|> {(state)->(UnicodeScalar?, ParsecStatus) in
                                var the_char = state.next({(x)->Bool in false})
                                return (nil, ParsecStatus.Failed("unknown escape char \(the_char)"))
                            })
        
        let strExpr = many1(try(noneOf(("\\" as String).unicodeScalars)) <|> escape) >>= {(x:[UnicodeScalar?]?)->Parsec<[UnicodeScalar?], String.UnicodeScalarView>.Parser in
            return eof >> pack(x!)
        }
        var state = BasicState(data.unicodeScalars)
        var (re, status) = strExpr(state)
        switch status {
        case .Success:
            var output = ucs2str(re!)
            println("string test passed, got: \(output)")
        case let .Failed(msg):
            XCTAssert(false, "string test failed, got: \(msg)")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
