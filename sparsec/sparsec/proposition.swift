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

func charSet(title:String, charSet:NSCharacterSet)->Parsec<UChr, UStr>.Parser {
    let pred = {(c:UnicodeScalar)-> Bool in
        return charSet.longCharacterIsMember(c.value)
    }
    return {(state:BasicState<UStr>)->Result<UChr, SimpleError<UStr.Index>> in
        let pre = state.next(pred)
        switch pre {
        case let .Success(value):
            return Result.Success(value)
        case let .Failed(msg):
            return Result.Failed(SimpleError(pos:state.pos, message:"Expect \(title) at \(state.pos) but \(msg)."))
        }
    }
}

let digit = charSet("digit", charSet: digits)
let letter = charSet("letter", charSet: letters)
let space = charSet("space", charSet: spaces)
let sol = charSet("space or newline", charSet: spacesAndNewlines)
let newline = charSet("newline", charSet: newlines)

let unsignedFloat = many(digit) >>= {(n:[UChr])->Parsec<String, UStr>.Parser in
    return {(state:BasicState<UStr>)->Result<String, SimpleError<UStr.Index>> in
        var re = (char(".") >> many1(digit))(state)
        switch re {
        case let .Success(data):
            return Result.Success("\(ucs2str(n)).\(ucs2str(data))")
        case let .Failed(err):
            return Result.Failed(err)
        }
    }
}

let float = `try`(unsignedFloat) <|> (char("-") >> {(state: BasicState<UStr>)->Result<String, SimpleError<UStr.Index>> in
    var re = unsignedFloat(state)
    switch re {
    case let .Success(data):
        return Result.Success("-\(data)")
    case let .Failed(err):
        return Result.Failed(err)
    }
})

func char(c:UChr)->Parsec<UChr, UStr>.Parser {
    return one(c)
}

//bind(x:many1(digit) , binder:{(x:[UChr])->Parsec<String, UStr>.Parser in
//    return pack(ucs2str(x))
//})
let uint = many1(digit) >>= {(n:[UChr])->Parsec<String, UStr>.Parser in
    return pack(ucs2str(n))
}

let int = optional(`try`(char("-"))) >>= {(x:UChr?) -> Parsec<String, UStr>.Parser in
    return {(state:BasicState<UStr>)->Result<String, SimpleError<UStr.Index>> in
        var re = uint(state)
        switch re {
        case let .Success(data):
            if x == nil {
                return Result<String, SimpleError<UStr.Index>>.Success(data)
            }else{
                var s:String="-" + data
                return Result.Success(s)
            }
        case .Failed:
            return Result.Failed(SimpleError(pos:state.pos, message:"Expect a Unsigned Integer token but failed."))
        }
    }
}

func text(value:String)->Parsec<String, String.UnicodeScalarView>.Parser {
    return {(state: BasicState<UStr>)->Result<String, SimpleError<UStr.Index>> in
        let scalars = value.unicodeScalars
        for idx in scalars.startIndex...scalars.endIndex {
            let re = state.next()
            if re == nil {
                return Result.Failed(SimpleError(pos:state.pos, message:"Expect Text \(value) but Eof"))
            } else {
                let rune = re!
                if rune != scalars[idx] {
                    return Result.Failed(SimpleError(pos: state.pos, message:"Text[\(idx)]:\(scalars[idx]) not match Data[\(state.pos)]:\(rune)"))
                }
            }
        }
        return Result.Success(value)
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

func csm2us(cs:[UChr?]) -> UStr {
    var re = "".unicodeScalars
    let values = unbox(cs)
    for c in  values {
        re.append(c)
    }
    return re
}

func csm2str(cs:[UChr?]) -> String {
    var re = "".unicodeScalars
    let values = unbox(cs)
    for c in  values {
        re.append(c)
    }
    return String(re)
}

func ucsm2us(cs:[UnicodeScalar?]) -> UStr {
    var re = "".unicodeScalars
    let values = unbox(cs)
    for c in  values {
        re.append(c)
    }
    return re
}

func ucsm2str(cs:[UnicodeScalar?]) -> String {
    var re = "".unicodeScalars
    let values = unbox(cs)
    for c in  values {
        re.append(c)
    }
    return String(re)
}