//
//  main.swift
//  day09
//
//  Created by Hans Kröner on 09/12/2022.
//

import Foundation
import RegexBuilder

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
    
    public func distance(toPoint point: CGPoint) -> CGFloat {
        let dx = self.x - point.x
        let dy = self.y - point.y
        
        return sqrt(pow(dx, 2) + pow(dy, 2))
    }
}

public func ==(lhs: CGPoint, rhs: CGPoint) -> Bool {
    return lhs.distance(toPoint: rhs) < 0.000001 // Call it close enough
}

public func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

public func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

enum Motion {
    case left
    case right
    case up
    case down
    
    init?(direction: Character) {
        switch direction {
        case "L": self = .left
        case "R": self = .right
        case "U": self = .up
        case "D": self = .down
        default: return nil
        }
    }
    
    var position: CGPoint {
        switch self {
        case .left: return CGPoint(x: -1, y: 0)
        case .right: return CGPoint(x: 1, y: 0)
        case .up: return CGPoint(x: 0, y: -1)
        case .down: return CGPoint(x: 0, y: 1)
        }
    }
}

struct Knot {
    private var positions: [CGPoint]
    private var motions: [Motion]
    
    var currenPosition: CGPoint {
        return positions.last!
    }
    
    init(position: CGPoint, motions: [Motion] = [Motion]()) {
        self.positions = [CGPoint]()
        self.positions.append(position)
        
        self.motions = motions
    }
    
    var visitedPositions: Set<CGPoint> {
        return Set(self.positions)
    }
    
    func distance(toKnot knot: Knot) -> CGFloat {
        let selfPosition = self.currenPosition
        let otherPosition = knot.currenPosition
        
        return selfPosition.distance(toPoint: otherPosition)
    }
    
    mutating func doNextMotion() -> Bool {
        if self.motions.isEmpty { return false }
        
        let motion = motions.removeFirst()
        let newPosition = CGPoint(x: self.currenPosition.x + motion.position.x,
                                  y: self.currenPosition.y + motion.position.y)
        self.move(toPosition: newPosition)
        
        return true
    }
    
    mutating func move(toPosition position: CGPoint) {
        self.positions.append(position)
    }
    
    mutating func chase(knot: Knot) {
        let delta = self.distance(toKnot: knot)
        
        // If the two knots aren't "touching" (horizontally, vertically, or diagonally), move this knot
        // closer to the knot being chased. The knot can't move more than one unit in each direction at a
        // time, so its movement is constrained by clamping the move values.
        if (delta > 1.5) {
            let moveToMatch = knot.currenPosition - self.currenPosition
            let clampedMove = CGPoint(x: moveToMatch.x.clamped(to: -1...1), y: moveToMatch.y.clamped(to: -1...1))
            let newPosition = self.currenPosition + clampedMove
            self.move(toPosition: newPosition)
        }
    }
}

let inputFilePath = "/Users/hans/Projects/advent_of_code_2022/day09/input"
let inputInstructions = try! String(contentsOfFile: inputFilePath).split(separator:"\n")

let direction = Reference(Substring.self)
let count = Reference(Int.self)

let search = Regex {
    Capture(as: direction) {
        OneOrMore(.word)
    }
    
    " "
    
    TryCapture(as: count) {
        OneOrMore(.digit)
    } transform: { match in
        Int(match)
    }
}

// Parse the input as a series of motions the `head` knot will perform. This also expands instructions that
// have multiple consecutive movements in the same direction.
var motions = [Motion]()
for instruction in inputInstructions {
    if let result = instruction.firstMatch(of: search) {
        for _ in 0..<result[count] {
            motions.append(Motion(direction: String(result[direction]).first!)!)
        }
    }
}

// The start location doesn't really matter for the puzzle, but it can be changed here to match the example
let start = CGPoint(x: 0, y: 0)
var head = Knot(position: start, motions: motions)
var tail = Knot(position: start)

while head.doNextMotion() {
    tail.chase(knot: head)
}

print("Tail moved to \(tail.visitedPositions.count) unique positions")

// Make a `head` (`k0`) knot and 9 followers knots for the second puzzle. Like before, all knots have the
// same start position (which doesn't really make a difference in the puzzle, but can also be changed to
// match the example
var followerKnots = [Knot]()
followerKnots.append(Knot(position: start, motions: motions))

for _ in 1...9 {
    followerKnots.append(Knot(position: start))
}

while followerKnots[0].doNextMotion() {
    for i in 1...9 {
        followerKnots[i].chase(knot: followerKnots[i - 1])
    }
}

let k9 = followerKnots.last!
print("K9 moved to \(k9.visitedPositions.count) unique positions")
