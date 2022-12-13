//
//  main.swift
//  day11
//
//  Created by Hans Kröner on 11/12/2022.
//

import Foundation

struct Monkey: Hashable {
    var index: Int
    var items: [Int]
    
    var operationIsAdd: Bool
    var operatorIsOld: Bool
    var operatorLiteral: Int
    
    var test: Int
    var testTrue: Int
    var testFalse: Int
}

func parseMonkey(_ text: String) -> Monkey {
    let lines = text.split(separator: "\n")
    
    return Monkey(
        index: Int(lines[0].split(separator: " ").last!.dropLast(1))!,
        items: lines[1].split(whereSeparator: { $0.isNumber == false }).map { Int($0)! },
        operationIsAdd: lines[2].contains("+"),
        operatorIsOld: lines[2].hasSuffix("old"),
        operatorLiteral: lines[2].hasSuffix("old") ? 1 : Int(lines[2].split(separator: " ").last!)!,
        test: Int(lines[3].split(separator: " ").last!)!,
        testTrue: Int(lines[4].split(separator: " ").last!)!,
        testFalse: Int(lines[5].split(separator: " ").last!)!
    )
}

func monkeyBusiness(forMonkeys: [Monkey], rounds: Int, shouldReduceWorries: Bool) -> Int {
    var monkeys = forMonkeys
    let divisor = monkeys.map(\.test).reduce(1, *)
    
    var inspections: [Int: Int] = [:]
    
    for _ in 1...rounds {
        for i in monkeys.indices {
            while var item = monkeys[i].items.first {
                let c = monkeys[i]
                monkeys[i].items.removeFirst()
                
                item = {
                    let operand = c.operatorIsOld ? item : c.operatorLiteral
                    return c.operationIsAdd ? item + operand : item * operand
                }()
                
                item = shouldReduceWorries ? (item / 3) : (item % divisor)

                if item.isMultiple(of: c.test) {
                    monkeys[c.testTrue].items.append(item)
                } else {
                    monkeys[c.testFalse].items.append(item)
                }
                
                inspections[i, default: 0] += 1
            }
        }
    }
    
    var sortedValues = Array(inspections.values).sorted(by: {$0 > $1})
    return sortedValues.removeFirst() * sortedValues.removeFirst()
}

let inputFilePath = "/Users/hans/Projects/advent_of_code_2022/day11/input"
let inputMonkeys = try! String(contentsOfFile: inputFilePath).split(separator:"\n\n").map { parseMonkey(String($0)) }

print(monkeyBusiness(forMonkeys: inputMonkeys, rounds: 20, shouldReduceWorries: true))
print(monkeyBusiness(forMonkeys: inputMonkeys, rounds: 10000, shouldReduceWorries: false))

