// Playground - noun: a place where people can play

import Cocoa

var range: [Int] = [0, 1 ,2, 3, 4, 5, 6, 7, 8, 9]

for idx in range {
    print(idx)
}

for idx in 0...10 {
    print(idx)
}

var ustr = "abcdef".unicodeScalars
ustr.startIndex.successor()
ustr.endIndex

enum Result<T, E>{
    case Success(T)
    case Failed(E)
}

typealias Status = Result<String?, String>

let success:Status = Status.Success("Yes")
let failed = Status.Failed("Failed")
let eof = Status.Success(nil)

