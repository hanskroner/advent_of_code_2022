//
//  main.swift
//  day07
//
//  Created by Hans Kröner on 07/12/2022.
//

import Foundation

enum TreeNodeType {
    case directory
    case file
}

class TreeNode {
    let name: String
    let type: TreeNodeType
    var size: Int?
    var parent: TreeNode?
    var children: [TreeNode]?
    
    init(name: String, type: TreeNodeType, size: Int? = nil, parent: TreeNode? = nil, children: [TreeNode]? = nil) {
        self.name = name
        self.type = type
        self.size = size
        self.parent = parent
        self.children = children
    }
    
    func childNode(withName name: String) -> TreeNode? {
        guard let children = self.children else { return nil }
        for child in children {
            if child.name == name { return child}
        }
        
        return nil
    }
}

func add(filesize size: Int, toParentNode node: TreeNode) {
    if (node.size == nil) { node.size = 0 }
    node.size! += size
    
    guard let parent = node.parent else { return }
    add(filesize: size, toParentNode: parent)
}

func atMost(_ size: Int, in node: TreeNode, nodes: inout [TreeNode]) {
    guard let children = node.children else { return }
    for child in children {
        if ((child.type == .directory) && (child.size! <= size)) {
            nodes.append(child)
        }
        
        if (child.type == .directory) {
            atMost(size, in: child, nodes: &nodes)
        }
    }
}

func atLeast(_ size: Int, in node: TreeNode, nodes: inout [TreeNode]) {
    guard let children = node.children else { return }
    for child in children {
        if ((child.type == .directory) && (child.size! > size)) {
            nodes.append(child)
        }
        
        if (child.type == .directory) {
            atLeast(size, in: child, nodes: &nodes)
        }
    }
}

let inputFilePath = "/Users/hans/Projects/advent_of_code_2022/day07/input"
let inputLines = try! String(contentsOfFile: inputFilePath).split(separator:"\n").map({ String($0) })

// Build a directory tree structure from the input
var tree = TreeNode(name: "/", type: .directory)
var currentNode = tree
for inputLine in inputLines {
    //MARK: Handle `$ cd`
    if inputLine.starts(with: "$ cd") {
        let directoryName = inputLine.replacing("$ cd ", with: "")
        
        // Handle `/` special case
        if directoryName == "/" {
            currentNode = tree
            continue
        }
        
        // Handle `..` special case
        if directoryName == ".." {
            guard let directory = currentNode.parent else { fatalError("Node \(currentNode) has no parent") }
            currentNode = directory
            continue
        }
        
        guard let directory = currentNode.childNode(withName: directoryName) else { fatalError("Node \(directoryName) is not a child of \(currentNode.name)") }
        currentNode = directory
        continue
    }
    
    //MARK: Handle `$ ls`
    if inputLine.starts(with: "$ ls") { continue }
    
    //MARK: Handle `filesize`
    if inputLine.range(of: "^[0-9]* ", options: .regularExpression) != nil {
        let regex = try! NSRegularExpression(pattern: "^[0-9]* ")
        let fileName = regex.stringByReplacingMatches(in: inputLine, range: NSMakeRange(0, inputLine.count), withTemplate: "")
        
        let fileSizeRange = regex.matches(in: inputLine, range: NSMakeRange(0, inputLine.count)).first!.range
        let fileSize = Int((inputLine as NSString).substring(with: fileSizeRange).trimmingCharacters(in: [" "]))!
        
        let fileNode = TreeNode(name: fileName, type: .file, size: fileSize)
        if (currentNode.children == nil) { currentNode.children = [TreeNode]() }
        currentNode.children!.append(fileNode)
        
        // Recursively increase `size` up to the parent node
        add(filesize: fileSize, toParentNode: currentNode)
        continue
    }
    
    //MARK: Handle `dir`
    if inputLine.starts(with: "dir") {
        let directoryName = inputLine.replacing("dir ", with: "")
        let directoryNode = TreeNode(name: directoryName, type: .directory, parent: currentNode)
        if (currentNode.children == nil) { currentNode.children = [TreeNode]() }
        currentNode.children!.append(directoryNode)
        continue
    }
}

// Traverse the tree looking for directories with sizes greater than 100000
var matching_nodes_1 = [TreeNode]()
atMost(100000, in: tree, nodes: &matching_nodes_1)

var tally  = 0
for node in matching_nodes_1 {
    tally += node.size!
}

print("Total for directories over 100000: \(tally)")

// Traverse the tree looking for directories with sizes at least the size needed to be freed to accomodate
// the update
let needToFree = 30000000 - (70000000 - tree.size!)
var matching_nodes_2 = [TreeNode]()
atLeast(needToFree, in: tree, nodes: &matching_nodes_2)

// Pick the smallest of the directories that, if deleted, would allow the update to be installed
let sortedAscending = matching_nodes_2.sorted(by: { $0.size! < $1.size! })
let deleteNode = sortedAscending.first!
print("To free \(needToFree) delete '\(deleteNode.name)' (\(deleteNode.size!))")
