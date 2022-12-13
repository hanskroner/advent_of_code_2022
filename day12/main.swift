//
//  main.swift
//  day12
//
//  Created by Hans Kröner on 12/12/2022.
//

import Foundation

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
    
    public func neighbors() -> [CGPoint] {
        return [
            CGPoint(x: self.x + 1, y: self.y),
            CGPoint(x: self.x - 1, y: self.y),
            CGPoint(x: self.x, y: self.y + 1),
            CGPoint(x: self.x, y: self.y - 1)
        ]
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

enum Direction {
    case up
    case down
}

func grid(forInput inputGrid: [Substring]) -> ([CGPoint: Int], CGPoint, CGPoint) {
    var grid = [CGPoint: Int]()
    var start: CGPoint!
    var end: CGPoint!
    
    for (y, line) in inputGrid.enumerated() {
        for (x, character) in line.enumerated() {
            let point = CGPoint(x: Double(x), y: Double(y))
            
            if character.isLowercase {
                grid[point] = Int(character.asciiValue!)
            } else if character == "S" {
                // Elevation of `S` is defined as "a"
                grid[point] = Int(Character("a").asciiValue!)
                start = point
            } else if character == "E" {
                // Elevation of `S` is defined as "z"
                grid[point] = Int(Character("z").asciiValue!)
                end = point
            } else {
                fatalError()
            }
        }
    }
    
    return (grid, start, end)
}

func pathLength(from start: CGPoint, endCondition condition: (CGPoint) -> Bool, direction: Direction, in grid: [CGPoint: Int]) -> Int {
    var positions: [Int: Set<CGPoint>] = [0: [start]]
    var visited: Set<CGPoint> = []
    
    while let elevation = positions.keys.min() {
        let position = positions[elevation, default: []].removeFirst()
        
        if positions[elevation]!.isEmpty {
            positions.removeValue(forKey: elevation)
        }
        
        for next in position.neighbors() {
            if visited.contains(next) || grid[next] == nil { continue }
            
            let delta = grid[next]! - grid[position]!
            
            switch direction {
            case .up:
                if delta > 1 { continue }
            case .down:
                if delta < -1 { continue }
            }
            
            visited.insert(next)
            
            positions[elevation + 1, default: []].insert(next)
            if condition(next) { return elevation + 1 }
        }
    }
    
    return 0
}

let inputFilePath = "/Users/hans/Projects/advent_of_code_2022/day12/input"
let inputGrid = try! String(contentsOfFile: inputFilePath).split(separator:"\n")

let (gridPoints, start, end) = grid(forInput: inputGrid)

let length_1 = pathLength(from: start, endCondition: { $0 == end }, direction: .up, in: gridPoints)
print(length_1)

let length_2 = pathLength(from: end, endCondition: { gridPoints[$0] == gridPoints[start] }, direction: .down, in: gridPoints)
print(length_2)
