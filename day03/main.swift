//
//  main.swift
//  day03
//
//  Created by Hans Kröner on 03/12/2022.
//

import Foundation

// Convert ASCII values to the priorities given by the puzzle
func priority(forCharacter char: Character) -> Int? {
    guard let value = char.asciiValue else { return nil }
    let asciiValue = Int(value)
    
    if (65...90).contains(asciiValue) {
        return asciiValue - 38
    }
    
    if (97...122).contains(asciiValue) {
        return asciiValue - 96
    }
    
    return nil
}

let inputFilePath = "/Users/hans/Projects/AoC22/day03/input"
let inputPacks = try! String(contentsOfFile: inputFilePath).split(separator:"\n").map({ String($0) })

var pacKPrioritySum = 0
for pack in inputPacks {
    // Split the input string in half - each substring represents the contents of one of the compartments
    // of the backpack.
    let middleIndex = pack.index(pack.startIndex, offsetBy: pack.count/2)
    
    // Convert the substrings into a `Set` of `Character`s. This makes finding the common item between them
    // easy - it's just the instersection between the two sets.
    let compartmentA: Set<String> = Set(pack[..<middleIndex].map({ String($0) }).enumerated().map({ $0.1 }))
    let compartmentB: Set<String> = Set(pack[middleIndex...].map({ String($0) }).enumerated().map({ $0.1 }))
    
    // Calculate the prioity of the shared item and add it to the tally.
    guard let sharedItem = compartmentA.intersection(compartmentB).first,
          let sharedCharacter = sharedItem.first,
          let priority = priority(forCharacter: sharedCharacter)else { continue }
    
    pacKPrioritySum += priority
}

print(pacKPrioritySum)

var groupPrioritySum = 0
for i in stride(from: 0, to: (inputPacks.count - 1), by: 3) {
    // Similarly to how it was done above, each input string is converted to a `Set` of `Character`s. The
    // intersection operation is used again, this time to find the item that is shared across all three sets.
    let groupA: Set<String> = Set(inputPacks[i].map({ String($0) }).enumerated().map({ $0.1 }))
    let groupB: Set<String> = Set(inputPacks[i + 1].map({ String($0) }).enumerated().map({ $0.1 }))
    let groupC: Set<String> = Set(inputPacks[i + 2].map({ String($0) }).enumerated().map({ $0.1 }))
    
    // Calculate the prioity of the shared item and add it to the tally.
    guard let sharedItem = groupA.intersection(groupB).intersection(groupC).first,
          let sharedCharacter = sharedItem.first,
          let priority = priority(forCharacter: sharedCharacter)else { continue }
    
    groupPrioritySum += priority
}

print(groupPrioritySum)
