//
//  state.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/9.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Foundation

protocol State {
    typealias T
    typealias I
    typealias Trans
    mutating func next() throws -> T
    var pos : I{get}
    mutating func begin() -> I
    mutating func commit(_: I)
    mutating func rollback(_: I)
}

class BasicState<S:CollectionType>{
    typealias T = S.Generator.Element
    typealias I = S.Index
    typealias Trans = S.Index
    var container: S
    
    init(_ container: S) {
        self.container = container
        self._pos = container.startIndex
    }
    var pos : S.Index {
        get {
            return _pos
        }
        set(value){
            _pos = value
        }
    }
    private var tran: S.Index? = nil
    private var _pos: S.Index
}

extension BasicState:State {
    func next() throws -> T {
        if self.pos == self.container.endIndex.successor() {
            throw ParsecError.Eof(pos: self.pos)
        }
        let item = container[self.pos]
        self.pos = self.pos.successor()
        return item
    }
    func begin() -> BasicState.Trans {
        if self.tran == nil {
            self.tran = self.pos
        }
        return self.pos
    }
    
    func commit(tran: BasicState.Trans) {
        if self.tran == tran {
            self.tran = nil
        }
    }
    func rollback(tran: Trans) {
        self._pos = tran
        if self.tran == tran {
            self.tran = nil
        }
    }
}

class LinesState<S:CollectionType where S.Index: IntegerArithmeticType>:
        BasicState<S> {
    typealias T = S.Generator.Element
    var newline:Equal<T>.Pred
    var lines:[S.Index] = []
    var row, col : S.Index
    var line: S.Index {
        get {
            return row
        }
    }
    var column: S.Index {
        get {
            return col
        }
    }
    //var _pos: S.Index
    init(_ container: S, newline: Equal<T>.Pred){
        self.newline = newline
        self.row = container.startIndex
        self.col = container.startIndex
        for index in container.startIndex ... container.endIndex {
            let item = container[index]
            if newline(item) {
                self.lines.append(index)
            }
        }
        super.init(container)
        self.pos = container.startIndex
    }
    override var pos:S.Index {
        get {
            return _pos
        }
        set(p) {
            assert((self.container.startIndex<=p) && (pos<=self.container.endIndex))
            _pos = pos
            let top = self.lines.endIndex
            for idx in self.lines.startIndex ... self.lines.endIndex {
                let start = self.lines[idx]
                var row = top - idx
                if start < _pos {
                    row = row + 2
                    col = pos - start
                    return
                }
            }
        }
    }
}

