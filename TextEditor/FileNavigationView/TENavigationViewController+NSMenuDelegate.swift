//
//  TENavigationViewController+NSMenuDelegate.swift
//  TextEditor
//
//  Created by jim on 2020/10/9.
//  Copyright © 2020 DiagDevTeam. All rights reserved.
//

import Cocoa

extension FileNavigationViewController: NSMenuDelegate, NSTextFieldDelegate, NSControlTextEditingDelegate {
    // MARK: NSMenuDelegate
    func menuWillOpen(_ menu: NSMenu) {
        print(self.treeView.clickedRow)
        if self.treeView.clickedRow < 0 {
            menu.item(withTitle: "Open in New Window")?.isEnabled = false
            menu.item(withTitle: "Rename")?.isEnabled = false
            menu.item(withTitle: "Delete")?.isEnabled = false
            menu.item(withTitle: "Show in Finder")?.isEnabled = false
        } else {
            menu.item(withTitle: "Open in New Window")?.isEnabled = true
            menu.item(withTitle: "Rename")?.isEnabled = true
            menu.item(withTitle: "Delete")?.isEnabled = true
            menu.item(withTitle: "Show in Finder")?.isEnabled = true
        }
    }
    func loadRightClickMenu() {
        self.outlineViewMenu = NSMenu()
        self.outlineViewMenu?.delegate = self
        let openItemInNewWindow = NSMenuItem(title: "Open in New Window",
                                  action: #selector(openInNewWindow),
                                  keyEquivalent: "")
        self.outlineViewMenu?.addItem(openItemInNewWindow)
        self.outlineViewMenu?.addItem(NSMenuItem.separator())
        let newFolderItem = NSMenuItem(title: "New Folder",
                                  action: #selector(newFolder),
                                  keyEquivalent: "")
        self.outlineViewMenu?.addItem(newFolderItem)
        let newFileItem = NSMenuItem(title: "New File",
                                  action: #selector(newFile),
                                  keyEquivalent: "")
        self.outlineViewMenu?.addItem(newFileItem)
        let renameItem = NSMenuItem(title: "Rename",
                                  action: #selector(rename),
                                  keyEquivalent: "")
        self.outlineViewMenu?.addItem(renameItem)
        self.outlineViewMenu?.addItem(NSMenuItem.separator())
        let deleteItem = NSMenuItem(title: "Delete",
                                  action: #selector(delete),
                                  keyEquivalent: "")
        self.outlineViewMenu?.addItem(deleteItem)
        self.outlineViewMenu?.addItem(NSMenuItem.separator())
        let showItemInFinder = NSMenuItem(title: "Show in Finder",
                                  action: #selector(showInFinder),
                                  keyEquivalent: "")
        self.outlineViewMenu?.addItem(showItemInFinder)
        self.outlineViewMenu?.addItem(NSMenuItem.separator())
        let expandMenuItem = NSMenuItem(title: "Expand all", action: #selector(expandAllItem), keyEquivalent: "")
        self.outlineViewMenu?.addItem(expandMenuItem)
        let collapseMenuItem = NSMenuItem(title: "Collapse all", action: #selector(collapseAllItem), keyEquivalent: "")
        self.outlineViewMenu?.addItem(collapseMenuItem)
        self.outlineViewMenu?.autoenablesItems = false
        showItemInFinder.isEnabled = true
        expandMenuItem.isEnabled = true
        collapseMenuItem.isEnabled = true
        self.treeView.menu = self.outlineViewMenu
    }
    @objc func openInNewWindow(sender: NSMenuItem) {
        NSLog("openInNewWindow")
        if self.treeView.clickedRow < 0 {
            return
        }
        guard let clickedTreeNode = self.treeView.item(atRow: self.treeView.clickedRow) as? TreeNode else {
            return
        }
        if clickedTreeNode.isFolder {
            let newUntitledDocument = try? NSDocumentController.shared.openUntitledDocumentAndDisplay(true)
            guard newUntitledDocument != nil else {
                NSLog("makeUntitledDocument failed!")
                return
            }
            NSDocumentController.shared.addDocument(newUntitledDocument!)
            NSLog("~~~~SWC~~~~~\(NSDocumentController.shared.documents.count)")
            var userInfo = [String: Any]()
            userInfo["openURL"] = clickedTreeNode.nodeURL!
            let time = DispatchTimeInterval.milliseconds(3)
            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                NotificationCenter.default.post(
                    name: Notification.Name(FileNavigationViewController.NotificationNames.openURL),
                    object: NSDocumentController.shared.documents.last!.windowControllers.last?.window,
                    userInfo: userInfo)
            }
        } else {
            NSDocumentController.shared.openDocument(withContentsOf: clickedTreeNode.nodeURL!, display: true) {newDoc, _, _ in
                if newDoc == nil {
                    NSLog("Document could not be opened!")
                    // 1. Document has been opened
                    // 2. Document is not the sported file type
                }
                NSLog("OpenInNewWindow sucess!")
                print("OpenedDocumentsCount:", NSDocumentController.shared.documents.count)
            }
        }
    }
    func repositionItemInThisDatalogTree(for url: URL) {
        var nodeSet = self.currentNode?.subNodes
        var indexArray = [Int]()
        //print(url.pathComponents.count)

        let rootPathDepth =  (currentNode?.nodeURL?.pathComponents.count)!
        var nodeNameArray = [String]()
        for iii in (rootPathDepth)...(url.pathComponents.count-1) {
            nodeNameArray.append(url.pathComponents[iii])
        }
        //print(nodeNameArray)

        for jjj in 0..<nodeNameArray.count {
            for iii in 0..<nodeSet!.count where nodeNameArray[jjj] == nodeSet![iii].nodeURL!.lastPathComponent {
                //print("AtRow:", iii, (nodeSet![iii].nodeURL?.path)!, url.path)
                indexArray.append(iii)
                nodeSet = nodeSet![iii].subNodes
                break
            }
        }
        if indexArray.isEmpty {
            NSLog("No such element")
            return
        }
        //print(indexArray)

        let outline = self.treeView
        outline!.collapseItem(nil, collapseChildren: true)
        var rowIndex = indexArray[0]
        var itemForItration = outline!.item(atRow: rowIndex)
        outline!.expandItem(itemForItration)
        indexArray.remove(at: 0)
        for iii in indexArray {
            rowIndex += iii + 1
            itemForItration = outline!.child(iii, ofItem: itemForItration)
            outline!.expandItem(itemForItration)
        }
        let indexes = IndexSet.init(arrayLiteral: rowIndex)
        outline?.selectRowIndexes(indexes, byExtendingSelection: false)
        let time = DispatchTimeInterval.milliseconds(100)
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            outline?.scroll(NSPoint(x: 0, y: (outline?.rect(ofRow: rowIndex).midY)!-self.view.visibleRect.height*0.5))
            if let node = outline?.item(atRow: rowIndex) as? TreeNode {
                print("Scroll to row:", rowIndex, node.nodeName)
            }
        }
    }
    @objc func newFolder(sender: NSMenuItem) {
        NSLog("newFile")
        let clickedRowIndex = self.treeView.clickedRow
        if clickedRowIndex < 0 {
            return
        }
        let clickedItem = self.treeView.item(atRow: clickedRowIndex)
        guard let clickedTreeNode = clickedItem as? TreeNode else {
            NSLog("Error in: Item converting")
            return
        }
        if clickedTreeNode.isFolder {
            NSLog("clickedTreeNode.isFolder")
            var newFileName = "未命名文件夹"
            var newFileURL = clickedTreeNode.nodeURL!.appendingPathComponent(newFileName)
            var directoryExists = ObjCBool.init(false)
            for iii in 2...INT64_MAX {
                if FileManager.default.fileExists(atPath: newFileURL.path, isDirectory: &directoryExists) {
                    newFileName = "未命名文件夹 " + "\(iii)"
                    newFileURL = clickedTreeNode.nodeURL!.appendingPathComponent(newFileName)
                } else {
                    break
                }
            }
            do {
                try FileManager.default.createDirectory(at: newFileURL, withIntermediateDirectories: false, attributes: nil)
            } catch {
                NSLog("mkdir failed")
                return
            }
            clickedTreeNode.subNodes.insert(TreeNode.init(newFileURL), at: 0)
            self.treeView.reloadData()
            self.treeView.expandItem(clickedItem)
        } else {
            NSLog("clickedTreeNode.isNotFolder")
            var newFileName = "未命名文件夹"
            var newFileURL = clickedTreeNode.nodeURL!.deletingLastPathComponent().appendingPathComponent(newFileName)
            var directoryExists = ObjCBool.init(false)
            for iii in 2...INT64_MAX {
                if FileManager.default.fileExists(atPath: newFileURL.path, isDirectory: &directoryExists) {
                    newFileName = "未命名文件夹 " + "\(iii)"
                    newFileURL = clickedTreeNode.nodeURL!.deletingLastPathComponent().appendingPathComponent(newFileName)
                } else {
                    break
                }
            }
            do {
                try FileManager.default.createDirectory(at: newFileURL, withIntermediateDirectories: false, attributes: nil)
            } catch {
                NSLog("mkdir failed")
                return
            }
            let childIndex = self.treeView.childIndex(forItem: clickedItem!)
            let parent = self.treeView.parent(forItem: clickedItem)
            if let parent = parent as? TreeNode {
                parent.subNodes.insert(TreeNode.init(newFileURL), at: childIndex + 1)
            } else {
                currentNode?.subNodes.insert(TreeNode.init(newFileURL), at: childIndex + 1)
            }
            self.treeView.reloadData()
        }
    }
    @objc func newFile(sender: NSMenuItem) {
        NSLog("newFile")
        let clickedRowIndex = self.treeView.clickedRow
        if clickedRowIndex < 0 {
            return
        }
        let clickedItem = self.treeView.item(atRow: clickedRowIndex)
        guard let clickedTreeNode = clickedItem as? TreeNode else {
            NSLog("Error in: Item converting")
            return
        }
        if clickedTreeNode.isFolder {
            NSLog("clickedTreeNode.isFolder")
            var newFileName = "未命名文件"
            var newFileURL = clickedTreeNode.nodeURL!.appendingPathComponent(newFileName)
            var directoryExists = ObjCBool.init(false)
            for iii in 2...INT64_MAX {
                if FileManager.default.fileExists(atPath: newFileURL.path, isDirectory: &directoryExists) {
                    newFileName = "未命名文件 " + "\(iii)"
                    newFileURL = clickedTreeNode.nodeURL!.appendingPathComponent(newFileName)
                } else {
                    break
                }
            }
            if FileManager.default.createFile(atPath: newFileURL.path, contents: nil, attributes: nil) {
//                self.itemShouldBeUsed = TreeNode.init(newFileURL) as Any
                let indexSet = IndexSet(arrayLiteral: 0)
                self.treeView.insertItems(at: indexSet, inParent: clickedItem, withAnimation: [])
//                let childIndex = self.treeView.childIndex(forItem: clickedItem!)
//                let indexSet = IndexSet(arrayLiteral: childIndex)
//                let parent = self.treeView.parent(forItem: clickedItem)
//                self.treeView.insertItems(at: indexSet, inParent: parent, withAnimation: [])
                clickedTreeNode.subNodes.insert(TreeNode.init(newFileURL), at: 0)
                self.treeView.reloadData()
                self.treeView.expandItem(clickedItem)
                // Reset the varible "itemShouldBeUsed"
//                self.itemShouldBeUsed = nil
            }
        } else {
            NSLog("clickedTreeNode.isNotFolder")
            var newFileName = "未命名文件"
            var newFileURL = clickedTreeNode.nodeURL!.deletingLastPathComponent().appendingPathComponent(newFileName)
            var directoryExists = ObjCBool.init(false)
            for iii in 2...INT64_MAX {
                if FileManager.default.fileExists(atPath: newFileURL.path, isDirectory: &directoryExists) {
                    newFileName = "未命名文件 " + "\(iii)"
                    newFileURL = clickedTreeNode.nodeURL!.deletingLastPathComponent().appendingPathComponent(newFileName)
                } else {
                    break
                }
            }
            if FileManager.default.createFile(atPath: newFileURL.path, contents: nil, attributes: nil) {
//                self.itemShouldBeUsed = TreeNode.init(newFileURL) as Any
                let childIndex = self.treeView.childIndex(forItem: clickedItem!)
//                let indexSet = IndexSet(arrayLiteral: childIndex)
                let parent = self.treeView.parent(forItem: clickedItem)
//                self.treeView.insertItems(at: indexSet, inParent: parent, withAnimation: [])
                if let parent = parent as? TreeNode {
                    parent.subNodes.insert(TreeNode.init(newFileURL), at: childIndex + 1)
                } else {
                    currentNode?.subNodes.insert(TreeNode.init(newFileURL), at: childIndex + 1)
                }
                self.treeView.reloadData()
                // Reset the varible "itemShouldBeUsed"
//                self.itemShouldBeUsed = nil
            }
        }
    }

// MARK: - NSControlTextEditingDelegate
    // MARK: Rename Item
    func renameItem(_ item: Any, _ newName: String) {
        guard let clickedTreeNode = item as? TreeNode else {
            NSLog("Error in: Item converting")
            return
        }
        print("New Name: ", newName)
        let newURL = clickedTreeNode.nodeURL?.deletingLastPathComponent().appendingPathComponent(newName)
        NSLog("Rename");print("mv", clickedTreeNode.nodeURL!.path, newURL!.path)
        // Update local data.
        do {
            try FileManager.default.moveItem(at: clickedTreeNode.nodeURL!, to: newURL!)
        } catch {
            NSLog("rename Failed!")
            return
        }
//        self.itemShouldBeUsed = TreeNode.init(newURL!) as Any
        let childIndex = self.treeView.childIndex(forItem: item)
//        var indexSet = IndexSet(arrayLiteral: childIndex)
        let parent = self.treeView.parent(forItem: item)
//        self.treeView.insertItems(at: indexSet, inParent: parent, withAnimation: [])
        // Reset the varible "itemShouldBeUsed"
//        self.itemShouldBeUsed = nil
//        indexSet = IndexSet(arrayLiteral: childIndex + 1)
//        self.treeView.removeItems(at: indexSet, inParent: parent, withAnimation: [])
        if let parent = parent as? TreeNode {
            parent.subNodes[childIndex] = TreeNode.init(newURL!)
        } else {
            currentNode?.subNodes[childIndex] = TreeNode.init(newURL!)
        }
        print(parent as Any)
        self.treeView.reloadData()
        NSLog("rename success!")
    }
    @objc func controlTextDidEndEditing(_ obj: Notification) {
        NSLog(obj.name.rawValue)
        guard let textField = obj.object as? NSTextField else {
            return
        }
        textField.isEditable = false
        let clickedRowIndex = self.theLastClickedRow
        let clickedItem = self.treeView.item(atRow: clickedRowIndex)
        renameItem(clickedItem!, textField.stringValue)
        textField.stringValue = (clickedItem as? TreeNode)!.nodeName
        print("theLastClickedRow: ", self.theLastClickedRow)
        self.theLastClickedRow = -1
    }
    @objc func rename(sender: NSMenuItem) {
        let clickedRowIndex = self.treeView.clickedRow
        if clickedRowIndex < 0 {
            return
        }
//        let clickedItem = self.treeView.item(atRow: clickedRowIndex)
        let view = self.treeView.view(atColumn: 0, row: clickedRowIndex, makeIfNecessary: true)
        if let cellView = view as? NSTableCellView {
            cellView.textField?.isEditable = true
            cellView.textField?.selectText(nil)
            cellView.textField?.delegate = self
            self.theLastClickedRow = clickedRowIndex
        }
    }
    // MARK: Removal and Addition
    private func removalConfirmAlert(_ itemsToRemove: [TreeNode]) -> NSAlert {
        let alert = NSAlert()
        var messageStr: String
        if itemsToRemove.count > 1 {
            // Remove multiple items.
            alert.messageText = NSLocalizedString("Are you sure you want to remove these items?", comment: "")
        } else {
            // Remove the single item.
            if itemsToRemove[0].nodeURL != nil {
                messageStr = NSLocalizedString("Are you sure you want to remove the reference to \"%@\"?", comment: "")
            } else {
                messageStr = NSLocalizedString("Are you sure you want to remove \"%@\"?", comment: "")
            }
            print("removalConfirmAlert", itemsToRemove[0].nodeName)
            alert.messageText = String(format: messageStr, itemsToRemove[0].nodeName)
        }
        alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
        return alert
    }
    @objc func delete(sender: NSMenuItem) {
        let clickedRowIndex = self.treeView.clickedRow
        if clickedRowIndex < 0 {
            return
        }
        let clickedItem = self.treeView.item(atRow: clickedRowIndex)
        if let selectedTreeNode = clickedItem as? TreeNode {
            // Confirm the removal operation.
            let confirmAlert = removalConfirmAlert([selectedTreeNode])
            confirmAlert.beginSheetModal(for: view.window!) { returnCode in
                if returnCode == NSApplication.ModalResponse.alertFirstButtonReturn {
                    // Remove the given set of node objects from the tree controller.
                    let url = selectedTreeNode.nodeURL!
                    var staticURL: NSURL? = NSURL.init(string: "")
                    NSLog("mv \"\(url.path)\" ./Trash")
                    do {
                        try FileManager.default.trashItem(at: url, resultingItemURL: &staticURL)
                        NSLog((staticURL!.path)!)
                    } catch {
                        NSLog("Remove Failed")
                    }
                    let childIndex = self.treeView.childIndex(forItem: clickedItem as Any)
                    let indexSet = IndexSet(arrayLiteral: childIndex)
                    let parent = self.treeView.parent(forItem: clickedItem)
                    self.treeView.removeItems(at: indexSet, inParent: parent, withAnimation: .effectFade)
//                    self.refreshModel()
                    // Update to Model
                    if let parent = parent as? TreeNode {
                        parent.subNodes.remove(at: childIndex)
                    } else {
                        self.currentNode?.subNodes.remove(at: childIndex)
                    }
                    self.treeView.reloadItem(parent)
                }
            }
        }
    }
    func refreshModel() {
        currentNode = TreeNode.init((currentNode?.nodeURL)!)
    }
        @objc func showInFinder(sender: NSMenuItem) {
            print("clicked row: \(self.treeView.clickedRow)")
            if self.treeView.clickedRow < 0 {
                return
            }
            if let selectedTreeNode = self.treeView.item(atRow: self.treeView.clickedRow) as? TreeNode {
                let url = selectedTreeNode.nodeURL!
                NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: url.path)
            }
        }
        @objc func expandAllItem(sender: NSMenuItem) {
            NSLog("expand all item..")
            self.treeView.expandItem(nil, expandChildren: true)
        }
        @objc func collapseAllItem(sender: NSMenuItem) {
            NSLog("collapse all item..")
            self.treeView.collapseItem(nil, collapseChildren: true)
        }

    }
