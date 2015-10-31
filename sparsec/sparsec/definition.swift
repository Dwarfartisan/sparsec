//
//  utils.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/10.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Foundation

struct Equal<T> {
    typealias Pred = (T)->Bool
    typealias Curry = (T)->(T)->Bool
}

func equals<T:Equatable>(a:T)->Equal<T>.Pred{
    return {(x:T)->Bool in
        return a==x
    }
}

// extension String: CollectionType {}

//extension String.UnicodeScalarView:CollectionType{}


