//
//  atom.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/10.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Foundation

func one<T:Equatable, S:CollectionType where S.Generator.Element==T>(one: T)->Parsec<T, S>.Parser{
    let pred = equals(one)
    return {(state: BasicState<S>)->Result<T, SimpleError<S.Index>> in
        let re = state.next(pred)
        switch re {
        case .Success:
            return Result.Success(one)
        case let .Failed(err):
            return Result.Failed(err)
        }
    }
}

func subject<T:Equatable, S:CollectionType where S.Generator.Element==T >
        (one: T, curry:(T)->(T)->Bool)->Parsec<T, S>.Parser {
    let pred:(T)->Bool = curry(one)
    return {(state: BasicState<S>)->Result<T, SimpleError<S.Index>> in
        let re = state.next(pred)
        switch re {
        case let .Success(data):
            return Result.Success(data)
        case let .Failed(err):
            return Result.Failed(err)
        }
    }
}

func eof<S:CollectionType>(state: BasicState<S>)->Result<S.Generator.Element?, SimpleError<S.Index>>{
    let item = state.next()
    if item == nil {
        return Result.Success(nil)
    } else {
        return Result.Failed(SimpleError(pos:state.pos, message:"Expect Eof but \(item) at \(state.pos)"))
    }
}


func pack<T, S:CollectionType>(value:T)->Parsec<T, S>.Parser {
    return {(state:BasicState)->Result<T, SimpleError<S.Index>> in
        return Result.Success(value)
    }
}

func fail<S:CollectionType>(err:SimpleError<S.Index>)->Parsec<S.Generator.Element, S>.Parser {
    return {(state:BasicState)->Result<S.Generator.Element, SimpleError<S.Index>> in
        return Result.Failed(err)
    }
}



