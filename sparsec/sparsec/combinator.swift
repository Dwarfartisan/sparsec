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
    return {(state: BasicState<S>) -> (T?, ParsecStatus) in
        return either(parsec, pack(value))(state)
    }
}

func oneOf<T:Equatable, C:CollectionType, S:CollectionType
    where S.Generator.Element==T, C.Generator.Element==T>(elements:C)->Parsec<T, S>.Parser {
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

func noneOf<T:Equatable, C:CollectionType, S:CollectionType
        where C.Generator.Element==T, S.Generator.Element==T>(elements:C)->Parsec<T, S>.Parser {
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

func bind<T, R, S:CollectionType >(x:CPS<T, R, S>.Parser,
        binder:CPS<T, R, S>.Continuation) -> CPS<T, R, S>.Passing {
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
func >>=<T, R, S:CollectionType>(x: CPS<T, R, S>.Parser, binder:CPS<T, R, S>.Continuation) -> CPS<T, R, S>.Passing {
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
func >><T, R, S:CollectionType>(x: CPS<T, R, S>.Parser, y:CPS<T, R, S>.Passing)  -> CPS<T, R, S>.Passing {
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
        return option(many1(p), [])(state)
    }
}

func many1<T, S:CollectionType>(p: Parsec<T, S>.Parser)->Parsec<[T?], S>.Parser {
    return {(state: BasicState<S>) -> ([T?]?, ParsecStatus) in
        var head = {(value:T?) -> Parsec<[T?], S>.Parser in
            var tail = {(data:[T?]?)->Parsec<[T?], S>.Parser in
                var buf = [value]
                for d in data! {
                    buf.append(d)
                }
                return pack(buf)
            }
            return many(p) >>= tail
        }
        return (p >>= head)(state)
    }
}

func manyTil<T, TilType, S:CollectionType>(p:Parsec<T, S>.Parser,
        end:Parsec<TilType, S>.Parser)->Parsec<[T?], S>.Parser{
    var head = {(value:T?)->Parsec<[T?], S>.Parser in
        var tail = {(data:[T?]?)->Parsec<[T?], S>.Parser in
            var buf = [value]
            for d in data! {
                buf.append(d)
            }
            return pack(buf)
        }
        return manyTil(p, end) >>= tail
    }
    var term = try(end) >> pack([T?]())
    return term <|> (p >>= head)
}

func maybe<T, S>(p:Parsec<T, S>.Parser)->Parsec<T, S>.Parser{
    return option((p>>pack(nil)), nil)
}

func skip<T, S>(p:Parsec<T, S>.Parser)->Parsec<[T?], S>.Parser{
    return maybe(many(p))
}

func sepBy<T, SepType, S:CollectionType>(p: Parsec<T, S>.Parser,
        sep:Parsec<SepType, S>.Parser)->Parsec<[T?], S>.Parser {
    return  {(state: BasicState<S>) -> ([T?]?, ParsecStatus) in
        return option(sepBy1(p, sep), [])(state)
    }
}

func sepBy1<T, SepType, S:CollectionType>(p: Parsec<T, S>.Parser,
        sep:Parsec<SepType, S>.Parser)->Parsec<[T?], S>.Parser {
    return {(state: BasicState<S>) -> ([T?]?, ParsecStatus) in
        var head = {(value: T?)->Parsec<[T?], S>.Parser in
            var tail = {(data:[T?]?)->Parsec<[T?], S>.Parser in
                var buf = data!
                buf.append(value)
                return pack(buf)
            }
            return (many(sep >> p) >>= tail)
        }
        return (p >>= head)(state)
    }
}