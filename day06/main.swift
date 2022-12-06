//
//  main.swift
//  day06
//
//  Created by Hans Kröner on 06/12/2022.
//

import Foundation

func lengthBeforeUnique(forCharacters characters: [Character], length: Int) -> Int? {
    for i in 0 ..< (characters.count - length) {
        // Make a Set out of a substring of `length` length. Sets only contain unique items, so if the Set's
        // count is `length` the current substring is Unique.
        if (Set(characters[i ..< i + length]).count == length) {
            return i + length
        }
    }
    
    return nil
}

let inputFilePath = "/Users/hans/Projects/advent_of_code_2022/day06/input"
let input = try! String(contentsOfFile: inputFilePath)

let characters = Array(input)
let count_1 = lengthBeforeUnique(forCharacters: characters, length: 4)!
let count_2 = lengthBeforeUnique(forCharacters: characters, length: 14)!

print("SOF complete after \(count_1) characters")
print("SOM complete after \(count_2) characters")
