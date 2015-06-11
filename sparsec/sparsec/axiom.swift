//
//  axiom.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/22.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Foundation

enum Result<T, E>{
    case Success(T)
    case Failed(E)
}

struct SimpleError<I> {
    let pos:I
    let message:String
}

struct Parsec<T, S:CollectionType> {
    typealias Parser = (BasicState<S>)->Result<T, SimpleError<S.Index>>
}
