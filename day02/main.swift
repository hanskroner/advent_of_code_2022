//
//  main.swift
//  day02
//
//  Created by Hans Kröner on 02/12/2022.
//

import Foundation

enum Outcome {
    case win
    case draw
    case lose
}

enum Move {
    case rock
    case paper
    case scissors
    
    var points: Int {
        switch self {
        case .rock: return 1
        case .paper: return 2
        case .scissors: return 3
        }
    }
    
    func move(forOutcome outcome: Outcome) -> Move {
        switch outcome {
        case .win:
            switch self {
            case .rock: return .paper
            case .paper: return .scissors
            case .scissors: return .rock
            }
        case .draw:
            return self
        case .lose:
            switch self {
            case .rock: return .scissors
            case .paper: return .rock
            case .scissors: return .paper
            }
        }
    }
}

func outcome(forString string: String) -> Outcome? {
    switch string {
    case "X": return .lose
    case "Y": return .draw
    case "Z": return .win
    default: return nil
    }
}

func move(forString string: String) -> Move? {
    switch string {
    case "A", "X": return .rock
    case "B", "Y": return .paper
    case "C", "Z": return .scissors
    default: return nil
    }
}

func pointsForMatch(_ p1: Move, _ p2: Move) -> Int {
    switch p1 {
    case .rock:
        switch p2 {
        case .rock: return 3
        case .paper: return 6
        case .scissors: return 0
        }
        
    case .paper:
        switch p2 {
        case .rock: return 0
        case .paper: return 3
        case .scissors: return 6
        }
        
    case .scissors:
        switch p2 {
        case .rock: return 6
        case .paper: return 0
        case .scissors: return 3
        }
    }
}

// Split the contents of the input file at newlines. This separates each individual rock, paper, scissors
// match.
let inputFilePath = "/Users/hans/Projects/AoC22/day02/input"
let inputMatches = try! String(contentsOfFile: inputFilePath).split(separator:"\n").map({ String($0) })

var tally_1 = 0
for match in inputMatches {
    let moves = match.split(separator: " ").map({ String($0) })
    // For each match, add the points obtained from the match's outcome to the points the move used by
    // the "player" gets - and add that to the tally.
    guard let p1 = move(forString: moves[0]), let p2 = move(forString: moves[1]) else { continue }
    tally_1 += pointsForMatch(p1, p2) + p2.points
}

print(tally_1)

var tally_2 = 0
for match in inputMatches {
    // The running tally is similar to what was done above, but this time the second column encodes the
    // ourcome of the match, not the move the "player" used, so first we need to determine the move that
    // would lead to the outcome given.
    let inputs = match.split(separator: " ").map({ String($0) })
    guard let p1 = move(forString: inputs[0]), let outcome = outcome(forString: inputs[1]) else { continue }
    
    let p2 = p1.move(forOutcome: outcome)
    tally_2 += pointsForMatch(p1, p2) + p2.points
}

print(tally_2)
