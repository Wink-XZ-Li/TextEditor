//
//  TreeNodeModel.swift
//  TextEditor
//
//  Created by Bernie on 2020/9/28.
//  Copyright © 2020 Bernie. All rights reserved.
//

import Cocoa
class TreeNode {
    // Imagine what will happen if you change "class" to "struct"
    // use NSOutlineView.reloadData() to catch the difference
    var nodeURL: URL?
    var nodeName: String
    var isFolder: Bool
    var subNodes = [TreeNode]()
    init() {
        self.nodeURL = nil
        self.nodeName = ""
        self.isFolder = false
    }
    init(_ url: URL) {
        var directoryExists = ObjCBool.init(false)
        var folderContents: [URL]?
        // Advance execution for avoiding wrong judgment.
        do {
            // Asking user for the R/W root may cause exception!
            folderContents = try FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles)
        } catch {
            // Therefore, we shall repeat this operation.
            folderContents = try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles)
        }
        if !FileManager.default.fileExists(atPath: url.path, isDirectory: &directoryExists) {
            // If the path dosen't exists.
            self.nodeURL = nil
            self.nodeName = ""
            self.isFolder = false
            return
        }
        if !FileManager.default.isReadableFile(atPath: url.path) {
            // If the file isn't readable.
            self.nodeURL = url
            self.nodeName = url.lastPathComponent
            self.isFolder = false
            return
        }
        self.nodeURL = url
        self.nodeName = url.lastPathComponent
        if directoryExists.boolValue {
            // If the file is a directory.
            self.isFolder = true
            if folderContents != nil {
                // If the directory has contents
                for subURL in folderContents! {
                    self.subNodes.append(TreeNode(subURL))
                }
            }
        } else {
            self.isFolder = false
        }
    }
}
