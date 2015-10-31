//
//  combinator.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/16.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Foundation

func attempt<T, S:State>(parsec: (S) throws->T) -> (S) throws -> T {
    return {(var state: S) throws -> T in
        let p = state.pos
        do {
            let result = try parsec(state)
            return result
        } catch let err {
            state.pos = p
            throw err
        }
    }
}

func either<T, S:State where S.I:Equatable>(x: Parsec<T, S>.Parser, _ y: Parsec<T, S>.Parser) -> Parsec<T, S>.Parser {
    return {(var state: S) throws -> T in
        let p = state.pos
        do {
            let re = try x(state)
            return re
        } catch let err {
            if state.pos == p {
                return try y(state)
            }else{
                throw err
            }
        }
    }
}

infix operator <|> { associativity left }
func <|><T, S:State where S.I:Equatable>(left: Parsec<T, S>.Parser,
        right: Parsec<T, S>.Parser)  -> Parsec<T, S>.Parser {
    return either(left, right)
}

func otherwise<T, S:State >(x:Parsec<T, S>.Parser, _ message:String)->Parsec<T, S>.Parser {
    return {(var state: S) throws -> T in
        do {
            let re = try x(state)
            return re
        } catch {
            throw ParsecError.Parse(pos: state.pos, message: message)
        }
    }
}

infix operator <?> { associativity left }
func <?><T, S:State>(x: Parsec<T, S>.Parser, message: String)  -> Parsec<T, S>.Parser {
    return otherwise(x, message)
}

func option<T, S:State where S.I:Equatable>(parsec:Parsec<T, S>.Parser, _ value:T) -> Parsec<T, S>.Parser {
    return {(var state: S) throws -> T in
        let p = state.pos
        do {
            let re = try parsec(state)
            return re
        } catch let err {
            if state.pos == p {
                return value
            }else{
                throw err
            }
        }
    }
}

func between<B, E, T, S:State>(b:Parsec<B, S>.Parser, _ e:Parsec<E, S>.Parser,
        _ p:Parsec<T, S>.Parser)->Parsec<T, S>.Parser{
    return {( state: S) throws -> T in
        let exp = (b >> p =>> e)
        return try exp(state)
    }
}

func many<T, S:State >(p:Parsec<T, S>.Parser) -> Parsec<[T], S>.Parser {
    return {( state: S) throws -> [T] in
        var re = [T]()
        let psc = attempt(p)
        do {
            while true {
                if let item = try? psc(state) {
                    re.append(item)
                } else {
                    break
                }
            }
        }
        return re
    }
}

postfix operator >* { }
postfix func >* <T, S:State>(p: Parsec<T, S>.Parser)  -> Parsec<[T], S>.Parser {
    return many(p)
}

func many1<T, S:State>(p: Parsec<T, S>.Parser)->Parsec<[T], S>.Parser {
    return {( state: S) throws -> [T] in
        let start = try p(state)
        var re:[T] = [start]
        let psc = attempt(p)
        do {
            while true {
                if let item = try? psc(state) {
                    re.append(item)
                } else {
                    break
                }
            }
        }
        return re
    }
}

postfix operator >+ { }
postfix func >+ <T, S:State>(p: Parsec<T, S>.Parser)  -> Parsec<[T], S>.Parser {
    return many1(p)
}

func manyTil<T, TilType, S:State>(p:Parsec<T, S>.Parser,
        tail:Parsec<TilType, S>.Parser)->Parsec<[T], S>.Parser{
    return (many(p) =>> tail)
}

func zeroOrOnce<T, S:State>(p:Parsec<T, S>.Parser)->Parsec<T?, S>.Parser{
    return{( state: S) throws -> T? in
        do{
            let re = try p(state)
            return re
        } catch {
            return nil
        }
    }
}

postfix operator >? { }
postfix func >? <T, S:State>(x: Parsec<T, S>.Parser)  -> Parsec<T?, S>.Parser {
    return zeroOrOnce(x)
}

func sepBy<T, SepType, S:State>(p: Parsec<T, S>.Parser,
        sep:Parsec<SepType, S>.Parser)->Parsec<[T], S>.Parser {
        return {( state: S) throws -> [T] in
            var re = [T]()
            do {
                let head = try p(state)
                re.append(head)
                let step = sep >> p
                while true {
                    if let item = try? step(state) {
                        re.append(item)
                    } else {
                        break
                    }
                }
            }
            return re
        }
}

func sepBy1<T, SepType, S:State>(p: Parsec<T, S>.Parser,
        sep:Parsec<SepType, S>.Parser)->Parsec<[T], S>.Parser {
    return {(state: S) throws ->[T] in
        let first = try p(state)
        var re:[T] = [first]
        let parser = attempt(sep)>>attempt(p)
        do {
            while true {
                if let item = try? parser(state) {
                    re.append(item)
                } else {
                    break
                }
            }
        }
        return re
    }
}


