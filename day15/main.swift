//
//  main.swift
//  day15
//
//  Created by Hans Kröner on 15/12/2022.
//

import Foundation

struct Position: Hashable, CustomStringConvertible {
    let x: Int
    let y: Int
    
    var description: String { "(\(x), \(y))" }
    
    var up: Self { .init(x: x, y: y - 1) }
    var down: Self { .init(x: x, y: y + 1) }
    var left: Self { .init(x: x - 1, y: y) }
    var right: Self { .init(x: x + 1, y: y) }
    var upLeft: Self { .init(x: x - 1, y: y - 1) }
    var upRight: Self { .init(x: x + 1, y: y - 1) }
    var downLeft: Self { .init(x: x - 1, y: y + 1) }
    var downRight: Self { .init(x: x + 1, y: y + 1) }
    
    func manhattanDistance(to position: Self) -> Int {
        return abs(position.x - self.x) + abs(position.y - self.y)
    }
}

extension ClosedRange<Int>  {
    public func count() -> Int {
        return abs(upperBound - lowerBound)
    }
}

struct Sensor {
    let position: Position
    let closestBeacon: Position
    
    var manhattanRadius: Int {
        position.manhattanDistance(to: closestBeacon)
    }
    
    var horizontalCoverage: ClosedRange<Int> {
        (position.x - manhattanRadius)...(position.x + manhattanRadius)
    }
    
    func coverage(atRow y: Int) -> ClosedRange<Int>? {
        let dy = abs(position.y - y)
        let radius = manhattanRadius
        
        if (dy > radius) { return nil }
        
        return (position.x - (radius - dy))...(position.x + (radius - dy))
    }
    
    func contains(_ position: Position) -> Bool {
        return self.position.manhattanDistance(to: position) <= manhattanRadius
    }
}

struct Circumference: Sequence, IteratorProtocol {
    let center: Position
    let radius: Int
    
    private var position: Position
    private var keypath: KeyPath<Position, Position>
    
    init(center: Position, radius: Int) {
        self.center = center
        self.radius = radius
        
        self.position = Position(x: center.x, y: center.y - radius)
        self.keypath = \Position.downRight
    }
    
    mutating func next() -> Position? {
        if position.y == center.y && keypath == \Position.downRight {
            keypath = \Position.downLeft
        } else if position.x == center.x && keypath == \Position.downLeft {
            keypath = \Position.upLeft
        } else if position.y == center.y && keypath == \Position.upLeft {
            keypath = \Position.upRight
        } else if position.x == center.x && keypath == \Position.upRight {
            position = position[keyPath: keypath]
            return nil
        }
        
        return position[keyPath: keypath]
    }
}

//

func matches(forRegex regex: String, inText text: String) -> [String] {
    let regex = try! NSRegularExpression(pattern: regex)
    let nsString = text as NSString
    let results = regex.matches(in: text, range: NSMakeRange(0, nsString.length))
    
    return results.map({ nsString.substring(with: $0.range) })
}

//

let inputFilePath = "/Users/hans/Projects/advent_of_code_2022/day15/input"
let inputLines = try! String(contentsOfFile: inputFilePath).split(separator:"\n").map({ String($0) })

var sensors = [Sensor]()
for inputLine in inputLines {
    let numbers = matches(forRegex: "-?\\d+", inText: inputLine).map({ Int($0) })
    sensors.append(Sensor(position: Position(x: numbers[0]!, y: numbers[1]!),
                          closestBeacon: Position(x: numbers[2]!, y: numbers[3]!)))
}

var beacons = Set(sensors.map(\.closestBeacon))

// MARK: - Puzzle 1
// The example for the first puzzle looks at row `10`, while the puzzle itself looks at row `2000000`
//let row = 10
let row = 2000000
var ranges_1 = [ClosedRange<Int>]()
for sensor in sensors {
    guard let horizontalCoverage = sensor.coverage(atRow: row) else { continue }
    
    // Exclude beacons themselves
    if sensor.closestBeacon.y == row && horizontalCoverage.contains(sensor.closestBeacon.x) {
        if horizontalCoverage.lowerBound < sensor.closestBeacon.x {
            let rangeBefore = (horizontalCoverage.lowerBound)...(sensor.closestBeacon.x - 1)
            ranges_1.append(rangeBefore)
        }
        
        if horizontalCoverage.upperBound > sensor.closestBeacon.x {
            let rangeAfter = (sensor.closestBeacon.x + 1)...(horizontalCoverage.upperBound)
            ranges_1.append(rangeAfter)
        }

        continue
    }

    ranges_1.append(horizontalCoverage)
}

ranges_1 = ranges_1.sorted(by: {$0.lowerBound < $1.lowerBound} )

var count = 0
var running_1 = 0
for i in 0..<ranges_1.count {
    var lower = ranges_1[i].lowerBound
    var upper = ranges_1[i].upperBound

    if i > 0 {
        lower = max(running_1 + 1, lower)
        upper = max(running_1, upper)
    }

    count += upper - lower + 1
    running_1 = upper
}

print("\(count) positions cannot contain a beacon")

// MARK: - Puzzle 2
let limit = 4000000
var beacon: Position!
outter: for i in 0...limit {
    var ranges_2 = [ClosedRange<Int>]()
    for sensor in sensors {
        if let horizontalCoverage = sensor.coverage(atRow: i) {
            ranges_2.append(horizontalCoverage)
        }
    }
    
    ranges_2 = ranges_2.sorted(by: {$0.lowerBound < $1.lowerBound} )
    
    var running_2 = -1
    for range in ranges_2 {
        if range.lowerBound > running_2 + 1 {
            beacon = Position(x: running_2 + 1, y: i)
            break outter
        }
        
        running_2 = max(running_2, range.upperBound)
    }
}

let tuningFrequency = beacon.x * limit + beacon.y
print("Tuning Frequency = \(tuningFrequency)")
