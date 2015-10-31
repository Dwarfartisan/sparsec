//
//  axiom.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/22.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Foundation

enum ParsecError<I> : ErrorType {
    case Eof(pos:I)
    case Parse(pos:I, message:String)
}

struct Parsec<T, S:State> {
    typealias Parser = (S) throws -> T
}

func bind<T, R, S:State>(x:Parsec<T, S>.Parser, _ binder:(T)->Parsec<R, S>.Parser) -> Parsec<R, S>.Parser {
    return {( state: S) throws -> R in
        let data = try x(state)
        return try binder(data)(state)
    }
}

infix operator >>= { associativity left }
func >>= <T, R, S:State>(x: Parsec<T, S>.Parser, binder:(T)->Parsec<R, S>.Parser) -> Parsec<R, S>.Parser {
    return bind(x, binder)
}

func then<T, R, S:State >(x: Parsec<T, S>.Parser,
    _ y:Parsec<R, S>.Parser) -> Parsec<R, S>.Parser {
        return {(state: S) throws -> R in
            try x(state)
            return try y(state)
        }
}

infix operator >> { associativity left }
func >> <T, R, S:State>(x: Parsec<T, S>.Parser, y: Parsec<R, S>.Parser)  -> Parsec<R, S>.Parser {
    return then(x, y)
}

func over<T, R, S:State >(x: Parsec<T, S>.Parser,
    _ y:Parsec<R, S>.Parser) -> Parsec<T, S>.Parser {
        return {( state: S) throws -> T in
            let data = try x(state)
            try y(state)
            return data
        }
}

infix operator =>> { associativity left }
func =>> <T, R, S:State>(x: Parsec<T, S>.Parser, y: Parsec<R, S>.Parser)  -> Parsec<T, S>.Parser {
    return over(x, y)
}
