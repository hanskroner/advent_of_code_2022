//
//  main.swift
//  day14
//
//  Created by Hans Kröner on 14/12/2022.
//

import Foundation

// MARK: Point

struct Point: Hashable {
    let x: Double
    let y: Double
    
    var down: Self { .init(x: self.x, y: self.y + 1) }
    var downLeft: Self { .init(x: self.x - 1, y: self.y + 1) }
    var downRight: Self { .init(x: self.x + 1, y: self.y + 1) }
    
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    init?<S: StringProtocol>(commaSeparatedPair: S) {
        let components = commaSeparatedPair.trimmingCharacters(in: .whitespaces).components(separatedBy: ",")
        guard let x = Double(components[0]),
              let y = Double(components[1])
        else { return nil }
        
        self.init(x: x, y: y)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
    
    public func distance(toPoint point: Point) -> Double {
        let dx = self.x - point.x
        let dy = self.y - point.y
        
        return sqrt(pow(dx, 2) + pow(dy, 2))
    }
}

func ==(lhs: Point, rhs: Point) -> Bool {
    return lhs.distance(toPoint: rhs) < 0.000001 // Call it close enough
}

// MARK: Grid

enum Tile: String, CustomStringConvertible {
    case air    = "."
    case rock   = "#"
    case source = "+"
    case sand   = "o"
    
    var description: String { self.rawValue }
}

typealias Grid = Dictionary<Point, Tile>

extension Collection where Element: Comparable {
    func range() -> ClosedRange<Element> {
        precondition(count > 0)
        let sorted = self.sorted()
        
        return sorted.first!...sorted.last!
    }
}

extension Grid where Key == Point {
    var xRange: ClosedRange<Int> { keys.map { Int($0.x) }.range() }
    var yRange: ClosedRange<Int> { keys.map { Int($0.y) }.range() }

    var lowestRock: Int {
        Int(self.filter { $0.value == .rock }.keys.map(\.y).max()!)
    }
}

func grid(forPoints input: [[Point]], source: Point) -> Grid {
    var grid: Grid = [source: .source]
    
    for points in input {
        // Get an array of the `lines` represented by the list of points provided
        let lines: [(start: Point, end: Point)] = points.dropLast().enumerated().map { index, start in
            return (start: start, end: points[index + 1])
        }
        
        // Get all the `points` that make up each of the lines. Each of these points is
        // represented as a `.rock` in the Grid.
        for line in lines {
            let pointsInLine: [Point] = {
                if line.start.x == line.end.x {
                    return (Int(min(line.start.y, line.end.y))...Int(max(line.start.y, line.end.y))).map {
                        .init(x: line.start.x, y: Double($0))
                    }
                } else {
                    return (Int(min(line.start.x, line.end.x))...Int(max(line.start.x, line.end.x))).map {
                        .init(x: Double($0), y: line.start.y)
                    }
                }
            }()
            
            pointsInLine.forEach { grid[$0] = .rock }
        }
    }
    
    return grid
}

func produceUnitOfSand(grid: inout Grid, source: Point, limits: (x: ClosedRange<Int>, y: ClosedRange<Int>)) -> Bool {
    var sand = source
    
    while true {
        if grid[sand.down, default: .air] == .air {
            sand = sand.down
        } else if grid[sand.downLeft, default: .air] == .air {
            sand = sand.downLeft
        } else if grid[sand.downRight, default: .air] == .air {
            sand = sand.downRight
        } else {
            guard limits.x.contains(Int(sand.x)) && limits.y.contains(Int(sand.y)) else { return false }
            
            grid[sand] = .sand
            
            return true
        }
        
        guard limits.x.contains(Int(sand.x)) && limits.y.contains(Int(sand.y)) else { return false }
    }
}

func produceUnitOfSand(grid: inout Grid, source: Point, floor: Int) -> Bool {
    var sand = source
    
    while true {
        if Int(sand.down.y) == floor {
            grid[sand] = .sand
            
            return true
        }
        
        if grid[sand.down, default: .air] == .air {
            sand = sand.down
        } else if grid[sand.downLeft, default: .air] == .air {
            sand = sand.downLeft
        } else if grid[sand.downRight, default: .air] == .air {
            sand = sand.downRight
        } else {
            grid[sand] = .sand
            
            return sand != source
        }
    }
}

func matches(forRegex regex: String, inText text: String) -> [String] {
    let regex = try! NSRegularExpression(pattern: regex)
    let nsString = text as NSString
    let results = regex.matches(in: text, range: NSMakeRange(0, nsString.length))
    
    return results.map({ nsString.substring(with: $0.range) })
}

let inputFilePath = "/Users/hans/Projects/advent_of_code_2022/day14/input"
let inputLines = try! String(contentsOfFile: inputFilePath).split(separator:"\n").map({ String($0) })

var points = [[Point]]()
for inputLine in inputLines {
    points.append(matches(forRegex: "\\d+,\\d+", inText: inputLine).compactMap(Point.init(commaSeparatedPair:)))
}

let sandSource = Point(commaSeparatedPair: "500,0")!
let _grid = grid(forPoints: points, source: sandSource)

// MARK: - Puzzle 1
var grid_1 = _grid
let extents = (grid_1.xRange, grid_1.yRange)
var keepProducing = true
while keepProducing {
    keepProducing = produceUnitOfSand(grid: &grid_1, source: sandSource, limits: extents)
}

let count_1 = grid_1.values.filter { $0 == .sand }.count
print(count_1)

//MARK: - Puzzle 2
var grid_2 = _grid
let floor = grid_2.lowestRock + 2
keepProducing = true
while keepProducing {
    keepProducing = produceUnitOfSand(grid: &grid_2, source: sandSource, floor: floor)
}

let count_2 = grid_2.values.filter { $0 == .sand }.count
print(count_2)
