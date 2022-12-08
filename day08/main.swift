//
//  main.swift
//  day08
//
//  Created by Hans Kröner on 08/12/2022.
//

import Foundation

struct Grid {
    let columns: Int
    let rows: Int
    
    var _rows: [[Int]]
    var _columns: [[Int]]
    
    init?(rows: [[Int]]) {
        guard rows.indices.contains(0) else { return nil }
        self.columns = rows[0].count
        self.rows = rows.count
        
        self._rows = rows
        
        self._columns = [[Int]]()
        for i in 0 ..< self.columns {
            self._columns.append([Int]())
            for j in 0 ..< self.rows {
                self._columns[i].append(self._rows[j][i])
            }
        }
    }
    
    func isCellVisible(row: Int, column: Int) -> Bool {
        // All cells around the edge of the grid are visible
        if ((row == 0) || (row == self.rows - 1) || (column == 0) || (column == self.columns - 1)) { return true }
        
        let cell = self._rows[row][column]
        
        // Check for visibility along rows
        let leftSideMax = self._rows[row][..<column].max()!
        let rightSideMax = self._rows[row][(column + 1)...].max()!
        if ((cell > leftSideMax) || (cell > rightSideMax)) { return true }
        
        // Check for visibility along columns
        let topSideMax = self._columns[column][..<row].max()!
        let bottomSideMax = self._columns[column][(row + 1)...].max()!
        if ((cell > topSideMax) || (cell > bottomSideMax)) { return true }
        
        return false
    }
    
    var visibleCells: Int {
        var count = 0
        
        for i in 0 ..< self.columns {
            for j in 0 ..< self.rows {
                if (self.isCellVisible(row: j, column: i)) { count += 1 }
            }
        }
        
        return count
    }
    
    func scenicScore(forRow row: Int, column: Int) -> Int {
        var score = [0, 0, 0, 0]
        
        let cell = self._rows[row][column]
        
        // Build arrays for each direction a score needs to be calculated for
        let leftRow = Array(self._rows[row][..<column].reversed())
        let rightRow = Array(self._rows[row][(column + 1)...])
        let topColumn = Array(self._columns[column][..<row].reversed())
        let bottomColumn = Array(self._columns[column][(row + 1)...])
        
        // Calculate scenic scores in each direction
        let arrays: [[Int]] = [leftRow, rightRow, topColumn, bottomColumn]
        for (i, array) in arrays.enumerated() {
            for (j, value) in array.enumerated() {
                // Increment the score until the same value or an edge are found
                if ((value >= cell) || (j == array.count - 1)) {
                    score[i] = j + 1
                    break
                }
            }
        }
        
        // Scenic Score is a multiplication of all the directional scores
        return score.reduce(1, *)
    }
    
    var maxScenicScore: Int {
        var scores = [Int]()
        
        for i in 0 ..< self.columns {
            for j in 0 ..< self.rows {
                scores.append(self.scenicScore(forRow: j, column: i))
            }
        }
        
        return scores.max()!
    }
}

let inputFilePath = "/Users/hans/Projects/advent_of_code_2022/day08/input"
let inputTrees = try! String(contentsOfFile: inputFilePath).split(separator:"\n").map({ Array(String($0)).map({ $0.wholeNumberValue! }) })

let grid = Grid(rows: inputTrees)!

print("Trees that are visible \(grid.visibleCells)")
print("Maximum Scenic Score \(grid.maxScenicScore)")
