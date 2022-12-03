//
//  main.swift
//  day01
//
//  Created by Hans Kröner on 01/12/2022.
//

import Foundation

struct Elf {
    let calories: [Int]
    
    var caloriesTotal: Int {
        calories.reduce(0) { $0 + $1 }
    }
}

// Split the contents of the input file at double newlines. This groups the string of calories each ELf
// is carrying.
let inputFilePath = "/Users/hans/Projects/AoC22/day01/input"
let inputElfs = try! String(contentsOfFile: inputFilePath).split(separator:"\n\n").map({ String($0) })

// Split the string with each Elf's grouped calories at newlines. This separates the individual calorie
// values, which can then be converted into `Int`s and stored in an `Elf` struct - which provides a
// convenient way of getting the sum of the calories carried by the Elf.
var elfs = [Elf]()

for inputElf in inputElfs {
    let inputCalories = inputElf.split(separator: "\n").compactMap({ Int($0) })
    elfs.append(Elf(calories: inputCalories))
}

print("--- ELFS ---")
for elf in elfs {
    print("\(elf.caloriesTotal) - \(elf)")
}

// Sort the `Elf` array by descending total calories. The 'n' Elfs with the highest total calories can
// be subscripted out into a new array to get the puzzle's solution.
let n = 3
let sortedElfs = elfs.sorted(by: {$0.caloriesTotal > $1.caloriesTotal} )
let topElfs = sortedElfs[...(n - 1)]

print("\n--- TOP \(n) ELFS ---")
for elf in topElfs {
    print("\(elf.caloriesTotal) - \(elf)")
}

print("\n--- TOP ELFS TOTAL ---")
let topCaloriesSum = topElfs.reduce(0, { $0 + $1.caloriesTotal })
print(topCaloriesSum)
