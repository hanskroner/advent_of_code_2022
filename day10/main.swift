//
//  main.swift
//  day10
//
//  Created by Hans Kröner on 10/12/2022.
//

import Foundation

let inputFilePath = "/Users/hans/Projects/advent_of_code_2022/day10/input"
let inputInstructions = try! String(contentsOfFile: inputFilePath).split(separator:"\n")

var history: [Int] = [Int]()
history.append(1)

for instruction in inputInstructions {
    let previousRegister = history[history.count - 1]
    
    if instruction.starts(with: "noop") {
        history.append(previousRegister)
    }
    
    if instruction.starts(with: "addx") {
        let value = Int(instruction.split(separator:" ")[1])!
        history.append(previousRegister)
        history.append(previousRegister + value)
    }
}

let indexes = [20, 60, 100, 140, 180, 220]

var tally = 0
for index in indexes {
    tally += history[index - 1] * index
}

print(tally)

var screenOutput = [Character]()
// Loop through the register history, ignoring the initial value
var spriteRange = 0...2
for i in 1..<history.count {
    if spriteRange.contains((i - 1) % 40) {
        screenOutput.append("#")
    } else {
        screenOutput.append(".")
    }
    
    spriteRange = (history[i] - 1)...(history[i] + 1)
    
    if (i % 40 == 0) { screenOutput.append("\n") }
}

let output = String(screenOutput)
print(output)
