//
//  main.swift
//  day05
//
//  Created by Hans Kröner on 05/12/2022.
//

import Foundation
import RegexBuilder

func matches(forRegex regex: String!, inText text: String!) -> [String] {
    let regex = try! NSRegularExpression(pattern: regex)
    let nsString = text as NSString
    let results = regex.matches(in: text, range: NSMakeRange(0, nsString.length))
    
    return results.map({ nsString.substring(with: $0.range) })
}

func stacks(forInput inputStacks: [String]) -> [Int: [Character]] {
    let stacksArray = matches(forRegex: "\\d+", inText: inputStacks.last).map({ Int($0)! })
    
    var stacks = [Int: [Character]]()
    for (_, value) in stacksArray.enumerated() {
        stacks[value] = [Character]()
    }
    
    // The range's upped bound is `stacks.last!.count` and not `stacks.last!.count - 1` because the text
    // representation of the stacks has an extra character - `]` that needs to be accounted for.
    let lineLength = inputStacks.last!.count
    for (index, stack) in inputStacks.reversed().enumerated() {
        if (index == 0) { continue }
        
        // Since the input grid is a fixed size, characters can be read out at specific indexes to get
        // the containers - some stacks are taller than others.
        var stackRow = [Character]()
        for i in stride(from: 1, to: lineLength, by: 4) {
            if stack.count >= i {
                let index = stack.index(stack.startIndex, offsetBy: i)
                stackRow.append(stack[index])
            } else {
                stackRow.append(" ")
            }
        }
        
        // Exclude "ghost" stacks when creating the stacks dictionary.
        for (index, key) in stacksArray.enumerated() {
            guard stackRow[index] != " " else { continue }
            stacks[key]?.append(stackRow[index])
        }
    }
    
    return stacks
}

enum PuzzleStage {
    case first
    case second
}

func rearrangeStacks(_ inputStacks: [Int: [Character]], forOperations inputOperations: [String], stage: PuzzleStage) -> [Int: [Character]] {
    var stacks = inputStacks
    
    for stringOperation in inputOperations {
        // The input string with the moving instructions contains three numbers, always in the same order,
        // that describe the operation that needs to be performed.
        let operationsArray = matches(forRegex: "\\d+", inText: stringOperation).map({ Int($0)! })
        let operation = StackOperation(count: operationsArray[0], source: operationsArray[1], destination: operationsArray[2])
        
        var crane = [Character]()
        
        // Using a "crane" to perform the rearranging operations as described in both puzzles.
        if stage == .second {
            let sourceStack = stacks[operation.source]!
            crane = Array(sourceStack[sourceStack.count - operation.count...sourceStack.count - 1])
        }
        
        for _ in 0..<operation.count {
            if stage == .second {
                let _ = stacks[operation.source]!.popLast()
            } else {
                guard let container = stacks[operation.source]?.popLast() else { fatalError() }
                crane.append(container)
            }
        }
        
        stacks[operation.destination]?.append(contentsOf: crane)
    }
    
    return stacks
}

struct StackOperation {
    let count: Int
    let source: Int
    let destination: Int
}

let inputFilePath = "/Users/hans/Projects/advent_of_code_2022/day05/input"
let inputLines = try! String(contentsOfFile: inputFilePath).split(separator:"\n\n").map({ String($0) })
let inputStacks = inputLines.first!.split(separator:"\n").map({ String($0) })
let inputOperations = inputLines.last!.split(separator:"\n").map({ String($0) })

let stacksDict = stacks(forInput: inputStacks)

let stacks_1 = rearrangeStacks(stacksDict, forOperations: inputOperations, stage: .first)
let stacks_2 = rearrangeStacks(stacksDict, forOperations: inputOperations, stage: .second)

var topContainers_1 = ""
var topContainers_2 = ""
let sortedKeys = Array(stacks_1.keys).sorted(by: <)
for key in sortedKeys {
    print("\(key): \(stacksDict[key]!)")
    topContainers_1.append(stacks_1[key]!.last!)
    topContainers_2.append(stacks_2[key]!.last!)
}

print(topContainers_1)
print(topContainers_2)
