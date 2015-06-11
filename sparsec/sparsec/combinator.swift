//
//  combinator.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/16.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Foundation

func `try`<T, S:CollectionType>(parsec: Parsec<T, S>.Parser) -> Parsec<T, S>.Parser {
    return {(state: BasicState<S>) -> Result<T, SimpleError<S.Index>> in
        let p = state.pos
        let result = parsec(state)
        switch result {
        case .Failed:
            state.pos = p
            fallthrough
        default:
            return result
        }
    }
}

func either<T, S:CollectionType>(x: Parsec<T, S>.Parser, y: Parsec<T, S>.Parser) -> Parsec<T, S>.Parser {
        return {(state: BasicState<S>) -> Result<T, SimpleError<S.Index>> in
            let p = state.pos
            let re = x(state)
            switch re {
            case .Success:
                return re
            default:
                if state.pos == p {
                    return y(state)
                } else {
                    return re
                }
            }

        }
}

infix operator <|> { associativity left }
func <|><T, S:CollectionType >(left: Parsec<T, S>.Parser,
        right: Parsec<T, S>.Parser)  -> Parsec<T, S>.Parser {
    return either(left, y: right)
}

func otherwise<T, S:CollectionType >(x:Parsec<T, S>.Parser, message:String)->Parsec<T, S>.Parser {
    return {(state: BasicState<S>) -> Result<T, SimpleError<S.Index>> in
        let re = x(state)
        switch re {
        case .Success:
            return re
        default:
            return Result.Failed(SimpleError(pos:state.pos, message:message))
        }
    }
}

infix operator <?> { associativity left }
func <?><T, S:CollectionType>(x: Parsec<T, S>.Parser, message: String)  -> Parsec<T, S>.Parser {
    return otherwise(x, message: message)
}

func option<T, S:CollectionType>(parsec:Parsec<T, S>.Parser, value:T) -> Parsec<T, S>.Parser {
        return parsec <|> pack(value)
}

func optional<T, S:CollectionType>(parsec:Parsec<T, S>.Parser) -> Parsec<T?, S>.Parser {
    return {(state: BasicState<S>)->Result<T?, SimpleError<S.Index>> in
        let re = parsec(state)
        switch re {
        case let .Success(data):
            return Result.Success(data)
        case let .Failed(err):
            return Result.Failed(err)
        }
    }
}

func oneOf<T:Equatable, Es:SequenceType, S:CollectionType
    where S.Generator.Element==T, Es.Generator.Element==T>(elements:Es)->Parsec<T, S>.Parser {
    return {(state: BasicState<S>) -> Result<T, SimpleError<S.Index>> in
        let re = state.next()
        if re == nil {
            return Result.Failed(SimpleError(pos:state.pos, message:"Expect one of [\(elements)] but eof."))
        } else {
            let data = re!
            for e in elements {
                if e == data {
                    return Result.Success(data)
                }
            }
        }

        return Result.Failed(SimpleError(pos:state.pos, message:"Missmatch any one of [\(elements)]."))
    }
}

func noneOf<T:Equatable, Es:SequenceType, S:CollectionType
        where Es.Generator.Element==T, S.Generator.Element==T>(elements:Es)->Parsec<T, S>.Parser {
    return {(state: BasicState<S>) -> Result<T, SimpleError<S.Index>> in
        let re = state.next()
        if re == nil {
            return Result.Failed(SimpleError(pos:state.pos, message:"Expect one of [\(elements)] but eof."))
        } else {
            let data = re!
            for e in elements {
                if e == data {
                    return Result.Failed(SimpleError(pos:state.pos, message:"Expect none of [\(elements)] but got \(e)"))
                }
            }
            return Result.Success(data)
        }
    }
}

func bind<T, R, S:CollectionType >(x:Parsec<T, S>.Parser, binder:(T)->Parsec<R, S>.Parser) -> Parsec<R, S>.Parser {
    return {(state: BasicState<S>) -> Result<R, SimpleError<S.Index>> in
        let re = x(state)
        switch re {
        case let .Success(data):
            return binder(data)(state)
        case let .Failed(err):
            return Result<R, SimpleError<S.Index>>.Failed(err)
        }
    }
}
infix operator >>= { associativity left }
func >>= <T, R, S:CollectionType>(x: Parsec<T, S>.Parser, binder:(T)->Parsec<R, S>.Parser) -> Parsec<R, S>.Parser {
    return bind(x, binder: binder)
}

func bind_<T, R, S:CollectionType >(x: Parsec<T, S>.Parser,
        y:Parsec<R, S>.Parser) -> Parsec<R, S>.Parser {
    return {(state: BasicState<S>) -> Result<R, SimpleError<S.Index>> in
        let re = x(state)
        switch re {
        case .Success:
            return y(state)
        case let .Failed(err):
            return Result.Failed(err)
        }
    }
}
infix operator >> { associativity left }
func >> <T, R, S:CollectionType>(x: Parsec<T, S>.Parser, y: Parsec<R, S>.Parser)  -> Parsec<R, S>.Parser {
    return bind_(x, y: y)
}

func between<B, E, T, S:CollectionType>(b:Parsec<B, S>.Parser, e:Parsec<E, S>.Parser,
        p:Parsec<T, S>.Parser)->Parsec<T, S>.Parser{
    return {(state: BasicState<S>) -> Result<T, SimpleError<S.Index>> in
        let keep = {(data:T)->Parsec<T, S>.Parser in
            return (e >> pack(data))
        }
        return (b >> (p>>=keep))(state)
    }
}

func many<T, S:CollectionType >(p:Parsec<T, S>.Parser) -> Parsec<[T], S>.Parser {
    return {(state: BasicState<S>) -> Result<[T], SimpleError<S.Index>> in
        return (many1(`try`(p)) <|> pack([]))(state)
    }
}

postfix operator >* { }
postfix func >* <T, S:CollectionType>(p: Parsec<T, S>.Parser)  -> Parsec<[T], S>.Parser {
    return many(p)
}

func many1<T, S:CollectionType>(p: Parsec<T, S>.Parser)->Parsec<[T], S>.Parser {
    let helper = {(start:T)->Parsec<[T], S>.Parser in
        return {(state:BasicState<S>)->Result<[T], SimpleError<S.Index>> in
            var res:[T] = [start]
            while true {
                let re = `try`(p)(state)
                switch re {
                case let .Success(data):
                    res.append(data)
                case .Failed:
                    return Result.Success(res)
                }
            }
        }
    }
    return p >>= helper
}

postfix operator >+ { }
postfix func >+ <T, S:CollectionType>(p: Parsec<T, S>.Parser)  -> Parsec<[T], S>.Parser {
    return many1(p)
}

func manyTil<T, TilType, S:CollectionType>(p:Parsec<T, S>.Parser,
        end:Parsec<TilType, S>.Parser)->Parsec<[T], S>.Parser{
    let term = `try`(end) >> pack([T]())
    return term <|> (many1(p) >>= {(re:[T])->Parsec<[T], S>.Parser in
        return term >> pack(re)
    })
}

func zeroOrOnce<T, S>(p:Parsec<T, S>.Parser)->Parsec<T?, S>.Parser{
    return optional(`try`(p))
}

postfix operator >? { }
postfix func >? <T, S:CollectionType>(x: Parsec<T, S>.Parser)  -> Parsec<T?, S>.Parser {
    return zeroOrOnce(x)
}

func maybe<T, X, S:CollectionType>(m:T, p:Parsec<X, S>.Parser, f:(X)->T) -> Parsec<T, S>.Parser {
    return {(state:BasicState<S>)-> Result<T, SimpleError<S.Index>> in
        let re = p(state)
        switch re {
        case let .Success(val):
            return Result.Success(f(val))
        case let .Failed(err):
            return Result.Failed(err)
        }
    }
}

func sepBy<T, SepType, S:CollectionType>(p: Parsec<T, S>.Parser,
        sep:Parsec<SepType, S>.Parser)->Parsec<[T], S>.Parser {
            return sepBy1(`try`(p), sep:`try`(sep)) <|> pack([])
}

func sepBy1<T, SepType, S:CollectionType>(p: Parsec<T, S>.Parser,
        sep:Parsec<SepType, S>.Parser)->Parsec<[T], S>.Parser {
    let helper = {(start:T)->Parsec<[T], S>.Parser in
        return {(state:BasicState<S>)->Result<[T], SimpleError<S.Index>> in
            var res:[T] = [start]
            let parser = `try`(sep)>>`try`(p)
            while true {
                let re = parser(state)
                switch re {
                case let .Success(data):
                    res.append(data)
                case .Failed:
                    return Result.Success(res)
                }
            }
        }
    }
    return (p >>= helper)
}

infix operator <- { associativity left }
func <- <T, S:CollectionType>(inout x: T?, p: Parsec<T, S>.Parser) -> Parsec<T, S>.Parser {
    return {(state:BasicState<S>)->Result<T, SimpleError<S.Index>> in
        let re = p(state)
        switch re {
        case let .Success(data):
            x=data
        case .Failed:
            x=nil
        }
        return re
    }
}

