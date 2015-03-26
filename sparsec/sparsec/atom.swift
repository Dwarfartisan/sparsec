//
//  atom.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/10.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Foundation

func one<T:Equatable, S:CollectionType where S.Generator.Element==T>(one: T)->Parsec<T, S>.Parser{
    var pred = equals(one)
    return {(state: BasicState<S>)->(T?, ParsecStatus) in
        var re = state.next(pred)
        switch re {
        case .Success:
            return (one, ParsecStatus.Success)
        case .Failed:
            return (nil, ParsecStatus.Failed("Except \(one) but \(state[state.pos]) missmatch."))
        case .Eof:
            return (nil, ParsecStatus.Failed("Except \(one) but \(state[state.pos]) Eof."))
        }
    }
}

func subject<T:Equatable, S:CollectionType where S.Generator.Element==T >
        (one: T, curry:(T)->(T)->Bool)->Parsec<T, S>.Parser {
    var pred:(T)->Bool = curry(one)
    return {(state: BasicState<S>)->(T?, ParsecStatus) in
        var re = state.next(pred)
        switch re {
        case .Success:
            return (one, ParsecStatus.Success)
        case .Failed:
            return (nil, ParsecStatus.Failed("Except \(one) but \(state[state.pos]) missmatch."))
        case .Eof:
            return (nil, ParsecStatus.Failed("Except \(one) but \(state[state.pos]) Eof."))
        }
    }
}

func eof<S:CollectionType>(state: BasicState<S>)->(S.Generator.Element?, ParsecStatus){
    var item = state.next()
    if item == nil {
        return (nil, ParsecStatus.Success)
    } else {
        return (item, ParsecStatus.Failed("Except Eof but \(item)"))
    }
}



func pack<T, S:CollectionType>(value:T?)->Parsec<T, S>.Parser {
    return {(state:BasicState)->(T?, ParsecStatus) in
        return (value, ParsecStatus.Success)
    }
}

func fail<S:CollectionType>(message:String)->Parsec<S.Generator.Element, S>.Parser {
    return {(state:BasicState)->(S.Generator.Element?, ParsecStatus) in
        return (nil, ParsecStatus.Failed(message))
    }
}

let unsignedFloat = bind(many(digit), {(x: [UChr?]?)->Parsec<UStr, UStr>.Parser in
    return {(state:BasicState<UStr>)->(UStr?, ParsecStatus) in
        var (re, status) = bind_(char("."), many1(digit))(state)
        switch status {
        case .Success:
            return (nil, ParsecStatus.Success)
        case .Failed:
            return (nil, ParsecStatus.Failed("Except a Unsigned Float token but failed."))
        }
    }
})


