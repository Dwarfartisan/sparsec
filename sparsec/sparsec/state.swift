//
//  state.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/9.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Foundation

class BasicState<S:CollectionType> {
    typealias T = S.Generator.Element
    var container: S
    var pos : S.Index
    init(_ container: S) {
        self.container = container
        self.pos = container.startIndex
    }

    func next() -> T? {
        if self.pos == self.container.endIndex.successor() {
            return nil
        }
        let item = container[self.pos]
        self.pos = self.pos.successor()
        return item
    }

    func next(pred : Equal<T>.Pred) -> PredResult<T> {
        if self.pos == self.container.endIndex.successor() {
            return PredResult<T>.Eof
        }
        let item = container[self.pos]
        self.pos = self.pos.successor()
        let match = pred(item)
        if match {
            self.pos.successor()
            return PredResult.Success(item)
        }
        return PredResult.Failed
    }
    subscript(idx: S.Index) -> T? {
        get {
            return container[idx]
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
    var _pos: S.Index
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
        _pos = container.startIndex
        super.init(container)
        
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

