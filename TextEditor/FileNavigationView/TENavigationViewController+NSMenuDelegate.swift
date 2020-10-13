//
//  TENavigationViewController+NSMenuDelegate.swift
//  TextEditor
//
//  Created by jim on 2020/10/9.
//  Copyright © 2020 DiagDevTeam. All rights reserved.
//

import Cocoa

extension TENavigationViewController: NSMenuDelegate, NSTextFieldDelegate, NSControlTextEditingDelegate {
    // MARK: NSMenuDelegate
    func menuWillOpen(_ menu: NSMenu) {
        print(self.filesListOutlineView.clickedRow)
        if self.filesListOutlineView.clickedRow < 0 {
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
        self.filesListOutlineView.menu = self.outlineViewMenu
    }
    @objc func openInNewWindow(sender: NSMenuItem) {
        NSLog("openInNewWindow")

        if self.filesListOutlineView.clickedRow < 0 {
            return
        }
        if let selectedTreeNode = self.filesListOutlineView.item(atRow: self.filesListOutlineView.clickedRow) as? TreeNode {
            let url = selectedTreeNode.nodePath!
            NSLog("\(url)")
        }
        let storyboard1 = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController1 = storyboard1.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as? NSWindowController ?? NSWindowController.init()
        self.view.window?.windowController?.document?.addWindowController(windowController1)
        self.view.window?.windowController?.document?.makeWindowControllers()
    }
    @objc func newFolder(sender: NSMenuItem) {
        NSLog("newFolder")
    }
    @objc func newFile(sender: NSMenuItem) {
        NSLog("newFile")
    }

    // MARK: - NSControlTextEditingDelegate
//    @objc func controlTextDidBeginEditing(_ obj: Notification) {
//        print("\n+++++++++++++++++++++++", obj.name)
//        guard let textField = obj.object as? NSTextField else {
//            return
//        }
//        NSLog(textField.stringValue)
//        if let viewController = textField.delegate as? TENavigationViewController {
//            NSLog("\(viewController.filesListOutlineView.selectedRow)")
//            NSLog("\(self.theLastClickedRow)")
//        }
//    }
//    @objc func controlTextDidChange(_ obj: Notification) {
//        print("\n+++++++++++++++++++++++", obj.name)
//        guard let textField = obj.object as? NSTextField else {
//            return
//        }
//        NSLog(textField.stringValue)
//        if let viewController = textField.delegate as? TENavigationViewController {
//            NSLog("\(viewController.filesListOutlineView.selectedRow)")
//            NSLog("\(self.theLastClickedRow)")
//        }
//    }
    @objc func controlTextDidEndEditing(_ obj: Notification) {
        print("\n+++++++++++++++++++++++", obj.name)
        guard let textField = obj.object as? NSTextField else {
            return
        }
        textField.isEditable = false
        NSLog(textField.stringValue)
        if let treeNode = self.filesListOutlineView.item(atRow: self.theLastClickedRow) as? TreeNode {
            print(treeNode.nodePath)
        }
        print("At", self.theLastClickedRow, "row")
        self.theLastClickedRow = -1
    }
    @objc func rename(sender: NSMenuItem) {
        let clickedRowIndex = self.filesListOutlineView.clickedRow
        if clickedRowIndex < 0 {
            return
        }
        let view = self.filesListOutlineView.view(atColumn: 0, row: clickedRowIndex, makeIfNecessary: true)
        if let cellView = view as? NSTableCellView {
            cellView.textField?.isEditable = true
            cellView.textField?.selectText(nil)
            cellView.textField?.delegate = self
            if let treeNode = self.filesListOutlineView.item(atRow: self.theLastClickedRow) as? TreeNode {
                cellView.textField?.bind(NSBindingName.init("content"), to: self, withKeyPath: ".filesListOutlineView.item(atRow: clickedRowIndex) as? TreeNode", options: nil)
            }
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
            if itemsToRemove[0].nodePath != nil {
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
        let clickedRowIndex = self.filesListOutlineView.clickedRow
        if clickedRowIndex < 0 {
            return
        }
        let clickedItem = self.filesListOutlineView.item(atRow: clickedRowIndex)
        if let selectedTreeNode = clickedItem as? TreeNode {
            // Confirm the removal operation.
            let confirmAlert = removalConfirmAlert([selectedTreeNode])
            confirmAlert.beginSheetModal(for: view.window!) { returnCode in
                print(returnCode)
                if returnCode == NSApplication.ModalResponse.alertFirstButtonReturn {
                    // Remove the given set of node objects from the tree controller.
                    let url = selectedTreeNode.nodePath!
                    var staticURL: NSURL? = NSURL.init(string: "")
                    NSLog("mv \"\(url.path)\" ./Trash")
                    do {
                        try FileManager.default.trashItem(at: url, resultingItemURL: &staticURL)
                        NSLog((staticURL!.path)!)
                    } catch {
                        NSLog("Remove Failed")
                    }
                    // The following line of code may cause bug
                    //self.filesListOutlineView.removeItems(at: IndexSet.init(arrayLiteral: clickedRowIndex), inParent: nil, withAnimation: [])
                    self.filesListOutlineView.hideRows(at: IndexSet.init(arrayLiteral: clickedRowIndex), withAnimation: [])
                    print(returnCode)
                }
            }
        }
    }
    @objc func showInFinder(sender: NSMenuItem) {
        print("clicked row: \(self.filesListOutlineView.clickedRow)")
        if self.filesListOutlineView.clickedRow < 0 {
            return
        }
        if let selectedTreeNode = self.filesListOutlineView.item(atRow: self.filesListOutlineView.clickedRow) as? TreeNode {
            let url = selectedTreeNode.nodePath!
//            let urlArray = [url]
//            NSWorkspace.shared.open(urlArray,
//                withAppBundleIdentifier: "com.apple.Finder",
//                options: NSWorkspace.LaunchOptions.andHideOthers,
//                additionalEventParamDescriptor: nil,
//                launchIdentifiers: nil)
            NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: url.path)
        }
    }
    @objc func expandAllItem(sender: NSMenuItem) {
        print("expand all item..")
        self.filesListOutlineView.expandItem(nil, expandChildren: true)
    }
    @objc func collapseAllItem(sender: NSMenuItem) {
        print("collapse all item..")
        self.filesListOutlineView.collapseItem(nil, collapseChildren: true)
    }

}
