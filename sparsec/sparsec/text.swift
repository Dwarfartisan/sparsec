//
//  proposition.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/19.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Foundation

let letters = NSCharacterSet.letterCharacterSet()
let digits = NSCharacterSet.decimalDigitCharacterSet()
let spaces = NSCharacterSet.whitespaceCharacterSet()
let spacesAndNewlines = NSCharacterSet.whitespaceAndNewlineCharacterSet()
let newlines = NSCharacterSet.newlineCharacterSet()

typealias UChr = UnicodeScalar
typealias UStr = String.UnicodeScalarView

func charSet<S:State where S.T==UChr>(title:String, _ charSet:NSCharacterSet)->Parsec<UChr, S>.Parser {
    return {(var state: S) throws -> UChr in
        let data = try state.next()
        if charSet.longCharacterIsMember(data.value) {
            return data
        } else {
            throw ParsecError.Parse(pos: state.pos, message: "Expect \(title) at \(state.pos)")
        }
    }
}

func digit<S:State where S.T==UChr>( state: S) throws -> UChr {
    return try charSet("digit", digits)(state)
}

func letter<S:State where S.T==UChr>( state: S) throws -> UChr {
    return try charSet("letter", letters)(state)
}

func space<S:State where S.T==UChr>( state: S) throws -> UChr {
    return try charSet("space", spaces)(state)
}

func sol<S:State where S.T==UChr>( state: S) throws -> UChr {
    return try charSet("space or newline", spacesAndNewlines)(state)
}

func newline<S:State where S.T==UChr>( state: S) throws -> UChr {
    return try charSet("newline", newlines)(state)
}

func char<S:State where S.T==UChr>(c:UChr)-> Parsec<UChr, S>.Parser {
    return {(var state:S) throws -> UChr in
        let item = try state.next()
        if item == c {
            return item
        } else {
            throw ParsecError.Parse(pos: state.pos, message: "Expect unicode char \(c) but \(item)")
        }
    }
}

func uint<S:State where S.T==UChr>(state: S) throws -> String {
    let buffer = try many1(digit)(state)
    return ucs2str(buffer)
}

func int<S:State where S.T==UChr>(state: S) throws -> String {
    var buffer = ""
    do {
        try attempt(char("-"))(state)
        buffer = "-"
    }
    let body:String = try uint(state)
    buffer = buffer + body
    return buffer
}

func ufloat<S:State where S.T==UChr, S.I:Equatable>(state: S) throws -> String {
    let left = try option("0" as String, attempt(uint))(state)
    try char(".")(state)
    let right = try uint(state)
    return "\(left).\(right)"
}

func float<S:State where S.T==UChr, S.I:Equatable>(state: S) throws -> String {
    let sign = try option("" as String, attempt(char("-") >> pack("-" as String)))(state)
    let left = try option("0", attempt(uint))(state)
    try char(".")(state)
    let right = try uint(state)
    return "\(sign)\(left).\(right)"
}

func text<S:State where S.T==UnicodeScalar>(value:String)->Parsec<String, S>.Parser {
    return {(var state: S) throws -> String in
        let scalars = value.unicodeScalars
        for idx in scalars.startIndex...scalars.endIndex {
            let re = try state.next()
            if re != scalars[idx] {
                throw ParsecError.Parse(pos: state.pos,
                    message:"Text[\(idx)]:\(scalars[idx]) not match Data[\(state.pos)]:\(re)")
            }
        }
        return value
    }
}


func cs2us(cs:[UChr]) -> UStr {
    var re = "".unicodeScalars
    for c in cs {
        re.append(c)
    }
    return re
}

func cs2str(cs:[UChr]) -> String {
    var re = "".unicodeScalars
    for c in cs {
        re.append(c)
    }
    return String(re)
}

func ucs2us(cs:[UnicodeScalar]) -> UStr {
    var re = "".unicodeScalars
    for c in cs {
        re.append(c)
    }
    return re
}

func ucs2str(cs:[UnicodeScalar]) -> String {
    var re = "".unicodeScalars
    for c in cs {
        re.append(c)
    }
    return String(re)
}
