//
//  main.swift
//  day04
//
//  Created by Hans Kröner on 04/12/2022.
//

import Foundation

extension ClosedRange {
    public func isSubset(of range: ClosedRange) -> Bool {
        return lowerBound <= range.lowerBound && range.upperBound <= upperBound || range.isEmpty
    }
}

let inputFilePath = "/Users/hans/Projects/advent_of_code_2022/day04/input"
let inputRanges = try! String(contentsOfFile: inputFilePath).split(separator:"\n").map({ String($0) })

var subsetTally = 0
var overlapTally = 0
// Split the input string in half at the ',' separator, each half containing a range. Each range can be
// further at the '-' separator to get the lower and upper bounds of the ranges.
for rangePair in inputRanges {
    let ranges = rangePair.split(separator:",").map({ String($0) })
    let boundsA = ranges[0].split(separator:"-").map({ Int($0)! })
    let boundsB = ranges[1].split(separator:"-").map({ Int($0)! })
    
    let rangeA = boundsA[0]...boundsA[1]
    let rangeB = boundsB[0]...boundsB[1]
    
    // ClosedRange doesn't have a built-in way of determining whether another Range is a subset of it but, in
    // this specific case, it's not complicated to determine it.
    if ((rangeA.isSubset(of: rangeB)) || (rangeB.isSubset(of: rangeA))) {
        subsetTally += 1
    }
    
    // ClosedRange does have a way of determining whether any item in the range is present in another range.
    if(rangeA.overlaps(rangeB)) {
        overlapTally += 1
    }
}

print("SUBSET count: \(subsetTally)")
print("OVERLAP count: \(overlapTally)")
