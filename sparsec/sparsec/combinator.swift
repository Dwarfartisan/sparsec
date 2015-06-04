//
//  combinator.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/16.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Foundation

func try<T, S:CollectionType>(parsec: Parsec<T, S>.Parser) -> Parsec<T, S>.Parser {
    return {(state: BasicState<S>) -> (T?, ParsecStatus) in
        var p = state.pos
        var (re, status) = parsec(state)
        switch status {
        case .Failed:
            state.pos = p
            fallthrough
        default:
            return (re, status)
        }
    }
}

func either<T, S:CollectionType>(x: Parsec<T, S>.Parser, y: Parsec<T, S>.Parser)
    -> Parsec<T, S>.Parser {
        return {(state: BasicState<S>) -> (T?, ParsecStatus) in
            var p = state.pos
            var (re, status) = x(state)
            switch status {
            case .Success:
                return (re, ParsecStatus.Success)
            default:
                if state.pos == p {
                    return y(state)
                } else {
                    return (re, status)
                }
            }

        }
}

infix operator <|> { associativity left }
func <|><T, S:CollectionType >(left: Parsec<T, S>.Parser,
        right: Parsec<T, S>.Parser)  -> Parsec<T, S>.Parser {
    return either(left, right)
}

func otherwise<T, S:CollectionType >(x:Parsec<T, S>.Parser, message:String)->Parsec<T, S>.Parser {
    return {(state: BasicState<S>) -> (T?, ParsecStatus) in
        var (re, status) = x(state)
        switch status {
        case .Success:
            return (re, status)
        default:
            return (nil, ParsecStatus.Failed(message))
        }
    }
}

infix operator <?> { associativity left }
func <?><T, S:CollectionType>(x: Parsec<T, S>.Parser, message: String)  -> Parsec<T, S>.Parser {
    return otherwise(x, message)
}

func option<T, S:CollectionType>(parsec:Parsec<T, S>.Parser, value:T?) -> Parsec<T, S>.Parser {
        return parsec <|> pack(value)
}

func oneOf<T:Equatable, Es:SequenceType, S:CollectionType
    where S.Generator.Element==T, Es.Generator.Element==T>(elements:Es)->Parsec<T, S>.Parser {
    return {(state: BasicState<S>) -> (T?, ParsecStatus) in
        var re = state.next()
        if re == nil {
            return (nil, ParsecStatus.Failed("Except one of [\(elements)] but Eof"))
        }
        
        for e in elements {
            if e == re! {
                return (e, ParsecStatus.Success)
            }
        }
        return (nil, ParsecStatus.Failed("Missmatch any one of [\(elements)]."))
    }
}

func noneOf<T:Equatable, Es:SequenceType, S:CollectionType
        where Es.Generator.Element==T, S.Generator.Element==T>(elements:Es)->Parsec<T, S>.Parser {
    return {(state: BasicState<S>) -> (T?, ParsecStatus) in
        var re = state.next()
        if re == nil {
            return (nil, ParsecStatus.Failed("Try to check none of [\(elements)] but Eof"))
        }
        
        for e in elements {
            if e == re! {
                var message = "Except None match [\(elements)] but found \(e)"
                return (e, ParsecStatus.Failed(message))
            }
        }
        return (re, ParsecStatus.Success)
    }
}

func bind<T, R, S:CollectionType >(x:Parsec<T, S>.Parser,
        binder:(T?)->Parsec<R, S>.Parser) -> Parsec<R, S>.Parser {
    return {(state: BasicState<S>) -> (R?, ParsecStatus) in
        var (re, status) = x(state)
        switch status {
        case .Success:
            var postfix = binder(re)
            return postfix(state)
        default:
            return (nil, status)
        }
    }
}
infix operator >>= { associativity left }
func >>= <T, R, S:CollectionType>(x: Parsec<T, S>.Parser, binder:(T?)->Parsec<R, S>.Parser) -> Parsec<R, S>.Parser {
    return bind(x, binder)
}

func bind_<T, R, S:CollectionType >(x: CPS<T, R, S>.Parser,
        y:CPS<T, R, S>.Passing) -> CPS<T, R, S>.Passing {
    return {(state: BasicState<S>) -> (R?, ParsecStatus) in
        var (re, status) = x(state)
        switch status {
        case .Success:
            return y(state)
        default:
            return (nil, status)
        }
    }
}
infix operator >> { associativity left }
func >> <T, R, S:CollectionType>(x: CPS<T, R, S>.Parser, y:CPS<T, R, S>.Passing)  -> CPS<T, R, S>.Passing {
    return bind_(x, y)
}

func between<T, S:CollectionType>(b:Parsec<T, S>.Parser, e:Parsec<T, S>.Parser,
        p:Parsec<T, S>.Parser)->Parsec<T, S>.Parser{
    return {(state: BasicState<S>) -> (T?, ParsecStatus) in
        var keep = {(data:T?)->Parsec<T, S>.Parser in
            return (e >> pack(data))
        }
        return (b >> (p>>=keep))(state)
    }
}

func many<T, S:CollectionType >(p:Parsec<T, S>.Parser) -> Parsec<[T?], S>.Parser {
    return {(state: BasicState<S>) -> ([T?]?, ParsecStatus) in
        return (many1(try(p)) <|> pack([]))(state)
    }
}

postfix operator >* { }
postfix func >* <T, S:CollectionType>(p: Parsec<T, S>.Parser)  -> Parsec<[T?], S>.Parser {
    return many(p)
}

func many1<T, S:CollectionType>(p: Parsec<T, S>.Parser)->Parsec<[T?], S>.Parser {
    var helper = {(start:T?)->Parsec<[T?], S>.Parser in
        return {(state:BasicState<S>)->([T?]?, ParsecStatus) in
            var res:[T?] = [start]
            while true {
                var (re, status) = try(p)(state)
                switch status {
                case .Success:
                    res.append(re)
                case .Failed:
                    return (res, ParsecStatus.Success)
                }
            }
        }
    }
    return p >>= helper
}

postfix operator >+ { }
postfix func >+ <T, S:CollectionType>(p: Parsec<T, S>.Parser)  -> Parsec<[T?], S>.Parser {
    return many(p)
}

func manyTil<T, TilType, S:CollectionType>(p:Parsec<T, S>.Parser,
        end:Parsec<TilType, S>.Parser)->Parsec<[T?], S>.Parser{
    var term = try(end) >> pack([T?]())
    return term <|> (many1(p) >>= {(re:[T?]?)->Parsec<[T?], S>.Parser in
        return term >> pack(re)
    })
}

func zeroOrOnce<T, S>(p:Parsec<T, S>.Parser)->Parsec<T, S>.Parser{
    return try(p) <|> pack(nil)
}

postfix operator >? { }
postfix func >? <T, S:CollectionType>(x: Parsec<T, S>.Parser)  -> Parsec<T, S>.Parser {
    return zeroOrOnce(x)
}

//parsec maybe curry
func maybe<T, X, S>(m:T, p:Parsec<X, S>.Parser)-> ((X)->T)->Parsec<T, S>.Parser {
    return {(f:(X)->T)->Parsec<T, S>.Parser in
        return maybe(m, p, f)
    }
}

func maybe<T, X, S>(m:T, p:Parsec<X, S>.Parser, f:(X)->T) -> Parsec<T, S>.Parser {
    return {(state:BasicState<S>)->(T?, ParsecStatus) in
        var (val, status) = p(state)
        switch status {
        case .Success:
            if val != nil {
                return (f(val!), .Success)
            }else{
                return (nil, .Success)
            }
        case .Failed:
            return (nil, status)
        }
    }
}

func sepBy<T, SepType, S:CollectionType>(p: Parsec<T, S>.Parser,
        sep:Parsec<SepType, S>.Parser)->Parsec<[T?], S>.Parser {
    return sepBy1(try(p), try(sep)) <|> pack([])
}

func sepBy1<T, SepType, S:CollectionType>(p: Parsec<T, S>.Parser,
        sep:Parsec<SepType, S>.Parser)->Parsec<[T?], S>.Parser {
    var helper = {(start:T?)->Parsec<[T?], S>.Parser in
        return {(state:BasicState<S>)->([T?]?, ParsecStatus) in
            var res:[T?] = [start]
            var parser = try(sep)>>try(p)
            while true {
                var (re, status) = parser(state)
                switch status {
                case .Success:
                    res.append(re)
                case .Failed:
                    return (res, ParsecStatus.Success)
                }
            }
        }
    }
    return (p >>= helper)
}

infix operator <- { associativity left }
func <- <T, S:CollectionType>(inout x: T?, p: Parsec<T, S>.Parser) -> Parsec<T, S>.Parser {
    return {(state:BasicState<S>)->(T?, ParsecStatus) in
        var (re, status) = p(state)
        switch status{
        case .Success:
            x=re
        case .Failed:
            x=nil
        }
        return (re, status)
    }
}

