//
//  atom.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/10.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Foundation

func one<T, S:State where S.T == T> ( var state: S) throws -> T {
    return try state.next()
}

func eof<T, S:State where S.T == T> ( var state: S) throws -> T? {
    do{
        try state.next()
        throw ParsecError.Parse(pos: state.pos, message: "Expect eof at \(state.pos).")
    } catch ParsecError<S.I>.Eof {
        return nil
    }
}

// eq 期待当前元素与给定元素相等
func eq<T:Equatable, S:State where S.T==T>(one: T) ->Parsec<T, S>.Parser{
    return {(var state: S) throws -> T in
        let re = try state.next()
        if re == one {
            return re
        } else {
            let message = "Expect value equal to \(one) but \(re)"
            throw ParsecError.Parse(pos: state.pos, message: message)
        }
    }
}

// ne 期待当前元素与给定元素相等
func ne<T:Equatable, S:State where S.T==T>(one: T) ->Parsec<T, S>.Parser{
    return {(var state: S) throws -> T in
        let re = try state.next()
        if re == one {
            let message = "Expect value not equal to \(one) but them equal."
            throw ParsecError.Parse(pos: state.pos, message: message)
        } else {
            return re
        }
    }
}

// pred 接受一个谓词逻辑，如果当前元素匹配这个逻辑，就表示解析成功
func pred<T:Equatable, S:State where S.T==T >
    (pred:(T)->Bool)->Parsec<T, S>.Parser {
        return {(var state: S) throws -> T in
            let item = try state.next()
            if pred(item) {
                return item
            } else {
                throw ParsecError.Parse(pos: state.pos, message: "Predicate \(pred) check pass \(item) failed")
            }
        }
}


// subj 接受一个 curry 化的谓词逻辑，如果当前元素匹配这个逻辑，就表示解析成功
func subj<T:Equatable, S:State where S.T==T >
        (one: T, curry:(T)->(T)->Bool)->Parsec<T, S>.Parser {
    let pred:(T)->Bool = curry(one)
    return {(var state: S) throws -> T in
        let item = try state.next()
        if pred(item) {
            return item
        } else {
            throw ParsecError.Parse(pos: state.pos, message: "Subject \(one) can't predicate check \(pred) pass \(item)")
        }
    }
}

// 即 Haskell 的 return 或 pure 操作，将一个值封装为 parsec 算子
func pack<T, S:State>(value:T)->Parsec<T, S>.Parser {
    return {( state: S) throws -> T in
        return value
    }
}

// 给出指定的错误信息
func fail<S:State>(message:String)->Parsec<S.T, S>.Parser {
    return {( state: S) throws -> S.T in
        throw ParsecError.Parse(pos: state.pos, message: message)
    }
}

// 期待迭代到的元素是给定集合中的某一个
func oneOf<T:Equatable, Es:SequenceType, S:State
    where S.T==T, Es.Generator.Element==T>(elements:Es)->Parsec<T, S>.Parser {
        return {(var state: S) throws -> T in
            let data = try state.next()
            for e in elements {
                if e == data {
                    return data
                }
            }
            throw ParsecError.Parse(pos:state.pos, message:"Expect \(data) at \(state.pos) in [\(elements)].")
        }
}

// 期待迭代到的元素不是给定集合中的任何一个
func noneOf<T:Equatable, Es:SequenceType, S:State
    where Es.Generator.Element==T, S.T==T> (elements:Es)->Parsec<T, S>.Parser {
        return {(var state: S) throws -> T in
            let data = try state.next()
            for e in elements {
                if e == data {
                    throw ParsecError.Parse(pos:state.pos, message:"Expect none of [\(elements)] at \(state.pos) but got \(e)")
                }
            }
            return data
        }
}



