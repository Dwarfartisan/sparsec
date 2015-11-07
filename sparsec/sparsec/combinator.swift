//
//  combinator.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/16.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Foundation

// 即 Haskell Parsec 的 try 算子，如果发生错误，将 state 复位
func attempt<T, S:State>(parsec: (S) throws->T) -> (S) throws -> T {
    return {(var state: S) throws -> T in
        let tran = state.begin()
        do {
            let result = try parsec(state)
            state.commit(tran)
            return result
        } catch let err {
            state.rollback(tran)
            throw err
        }
    }
}

// 如果第一个算子成功，返回其结果，否则要检查其是否复位，如果复位，就尝试第二个算子并返回其结果
func either<T, S:State where S.I:Equatable>(x: Parsec<T, S>.Parser, _ y: Parsec<T, S>.Parser) -> Parsec<T, S>.Parser {
    return {( state: S) throws -> T in
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

// either 的中置运算符形式
infix operator <|> { associativity left }
func <|><T, S:State where S.I:Equatable>(left: Parsec<T, S>.Parser,
        right: Parsec<T, S>.Parser)  -> Parsec<T, S>.Parser {
    return either(left, right)
}

// 如果给定算子发生错误，给出指定的错误信息
func otherwise<T, S:State >(x:Parsec<T, S>.Parser, _ message:String)->Parsec<T, S>.Parser {
    return {( state: S) throws -> T in
        do {
            let re = try x(state)
            return re
        } catch {
            throw ParsecError.Parse(pos: state.pos, message: message)
        }
    }
}

// otherwise 的中置运算符形式
infix operator <?> { associativity left }
func <?><T, S:State>(x: Parsec<T, S>.Parser, message: String)  -> Parsec<T, S>.Parser {
    return otherwise(x, message)
}

// 如果给定算子发生错误，给出指定的值
func option<T, S:State where S.I:Equatable>(value:T, _ parsec:Parsec<T, S>.Parser) -> Parsec<T, S>.Parser {
    return {( state: S) throws -> T in
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

// 给出在指定起止算子之间的给定算子的计算结果
func between<B, E, T, S:State>(open:Parsec<B, S>.Parser, _ close:Parsec<E, S>.Parser,
        _ p:Parsec<T, S>.Parser)->Parsec<T, S>.Parser{
    return {( state: S) throws -> T in
        // return try (open >> p =>> close)(state)
        try open(state)
        let re = try p(state)
        try close(state)
        return re
    }
}

// 匹配给定算子0到多次
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

// 匹配给定算子一到多次
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

// 匹配给定算子0到多次，并以指定的算子结尾
func manyTil<T, TilType, S:State>(p:Parsec<T, S>.Parser,
        tail:Parsec<TilType, S>.Parser)->Parsec<[T], S>.Parser{
    return (many(p) =>> tail)
}

// 匹配给定算子0到1次，失败返回 nil
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

// 以指定算子分隔的 many 匹配
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

// 以指定算子分隔的 many1 匹配
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

// 跳过给定算子0到多次
func skip<T, S:State >(p:Parsec<T, S>.Parser) -> Parsec<T?, S>.Parser {
    return {( state: S) throws -> T? in
        let psc = attempt(p)
        do {
            while true {
                let re = try? psc(state)
                if re == nil {
                    break
                }
            }
        }
        return nil
    }
}

// 跳过给定算子 1 到多次
func skip1<T, S:State>(p: Parsec<T, S>.Parser)->Parsec<T?, S>.Parser {
    return {( state: S) throws -> T? in
        try p(state)
        let psc = attempt(p)
        do {
            while true {
                let re = try? psc(state)
                if re == nil {
                    break
                }
            }
        }
        return nil
    }
}


