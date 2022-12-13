//
//  main.swift
//  day13
//
//  Created by Hans Kröner on 13/12/2022.
//

import Foundation

enum Packet: Equatable {
    case number(Int)
    indirect case list([Packet])
    
    init(_ input: inout ArraySlice<Character>) {
        var packets = [Packet]()
        var characters = [Character]()
        
        while let character = input.popFirst() {
            switch character {
            case "[":
                packets.append(.init(&input))
                
            case "]":
                if characters.isEmpty == false {
                    let value = Int(String(characters))!
                    packets.append(.number(value))
                }
                self = .list(packets)
                return
                
            case ",":
                if !characters.isEmpty {
                    let value = Int(String(characters))!
                    characters.removeAll()
                    packets.append(.number(value))
                }
                
            default:
                characters.append(character)
            }
        }
        
        self = .list(packets)
    }
    
    static func compare(lhs: Self, rhs: Self) -> ComparisonResult {
        switch (lhs, rhs) {
        case let (.number(left), .number(right)):
            return left < right ? .orderedAscending : left > right ? .orderedDescending : .orderedSame
            
        case let (.number, .list(right)):
            return compare(lhs: [lhs], rhs: right)
            
        case let (.list(left), .number):
            return compare(lhs: left, rhs: [rhs])
            
        case let (.list(left), .list(right)):
            return compare(lhs: left, rhs: right)
        }
    }
    
    static func compare(lhs: [Packet], rhs: [Packet]) -> ComparisonResult {
        for (index, packet) in lhs.enumerated() {
            guard index < rhs.count else { return .orderedDescending }
            
            let result = compare(lhs: packet, rhs: rhs[index])
            guard result != .orderedSame else { continue }
                
            return result
        }
        
        return lhs.count == rhs.count ? .orderedSame : .orderedAscending
    }
}

struct PacketPair {
    let lhs: Packet
    let rhs: Packet
    
    init(lines: ArraySlice<String>) {
        var line = Array(lines.first!)[...]
        self.lhs = .init(&line)
        
        line = Array(lines.last!)[...]
        self.rhs = .init(&line)
    }
}

let inputFilePath = "/Users/hans/Projects/advent_of_code_2022/day13/input"
let inputStrings = try! String(contentsOfFile: inputFilePath).components(separatedBy: .newlines)

// MARK: - First Puzzle
let inputPairs: [ArraySlice<String>] = inputStrings.split(separator: "")
let pairs = inputPairs.map(PacketPair.init(lines:))
let count = pairs.map({ Packet.compare(lhs: $0.lhs, rhs: $0.rhs) })
    .enumerated()
    .map({ $1 == .orderedAscending ? $0 + 1 : 0 })
    .reduce(0, +)

print(count)

// MARK: - Second Puzzle
let dividerPackets = ["[[2]]", "[[6]]"].map {
    var line = Array($0)[...]
    return Packet(&line)
}

let packets = inputStrings.compactMap { line -> Packet? in
    guard line.isEmpty == false else { return nil }
    var line = Array(line)[...]
    return Packet(&line)
}

let sorted = (packets + dividerPackets).sorted { lhs, rhs in
    return Packet.compare(lhs: lhs, rhs: rhs) == .orderedAscending
}

let firstDivider = sorted.firstIndex(of: dividerPackets[0])! + 1
let secondDivider = sorted.firstIndex(of: dividerPackets[1])! + 1

print(firstDivider * secondDivider)
