//
//  TENavigationViewController.swift
//  TextEditor
//
//  Created by jim on 2020/9/29.
//  Copyright © 2020 DiagDevTeam. All rights reserved.
//

import Cocoa
// Something could be improved such as:
// 1.
class TENavigationViewController: NSViewController {
    // MARK: Constants
    struct NotificationNames {
        // Notification that the tree controller's selection has changed (used by SplitViewController).
        static let selectionChanged = "selectionChangedNotification"
        static let renameItem = "renameItemNotification"
    }
    // MARK: Outlets
    @IBOutlet weak var filesListOutlineView: NSOutlineView!
    @IBOutlet weak var filePath: NSPathControl!
    var outlineViewMenu: NSMenu?
    // Note: close SandBox before you use “ProcessInfo.processInfo.environment”
    let defaultOpenedURL = URL.init(fileURLWithPath: ProcessInfo.processInfo.environment["HOME"]!+"/Downloads/")
    var currentNode = TreeNode()
    // Recorde clickedRow for the operation of renameItem.
    var theLastClickedRow = -1
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        print(ProcessInfo.processInfo.environment["HOME"]!)
//        filesListOutlineView.reloadData()
        loadRightClickMenu()
        // Setup observers for the outline view's selection, adding items, and removing items.
//        setupObservers()
    }
    

    // MARK: Notifications
//    private func setupObservers() {
//        // Notification to add a folder.
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(renameItem(_:)),
//            name: Notification.Name(TENavigationViewController.NotificationNames.renameItem),
//            object: nil)
//
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(renameItem1(_:)),
//            name: Notification.Name(rawValue: "textDidBeginEditing"),
//            object: nil)
//
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(renameItem2(_:)),
//            name: Notification.Name(rawValue: "textDidEndEditing"),
//            object: nil)
//
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(renameItem3(_:)),
//            name: Notification.Name(rawValue: "textDidChange"),
//            object: nil)
//    }
//    @objc private func renameItem1(_ notif: Notification) {
//        NSLog("\n++++++++++++++++++++++++++++++++++++++++++\(notif.name)")
//    }
//    @objc private func renameItem3(_ notif: Notification) {
//        NSLog("\n++++++++++++++++++++++++++++++++++++++++++\(notif.name)")
//    }
//    @objc private func renameItem2(_ notif: Notification) {
//        NSLog("\n++++++++++++++++++++++++++++++++++++++++++\(notif.name)")
//    }
//    // Notification sent from TENavigationViewController+NSMenuDelegate class, to rename the treeNode.
//    @objc private func renameItem(_ notif: Notification) {
//        // Add the folder with "untitled" title.
//        let selectedRow = filesListOutlineView.selectedRow
//        if let folderToAddNode = self.filesListOutlineView.item(atRow: selectedRow) as? TreeNode {
//            NSLog("\n++++++++++++++++++++++++++++++++++++++++++\(notif.name)")
//        }
//        // Flag the row we are adding (for later renaming after the row was added).
//        NSLog("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
//    }
}
// MARK: - OutlineView dataSource
extension TENavigationViewController: NSOutlineViewDataSource {
    // The first step.
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? TreeNode {
            return item.subNodes.count
        }
        currentNode = TreeNode(defaultOpenedURL)
        return currentNode.subNodes.count
    }
    // The third step.
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let item = item as? TreeNode else {
            return false
        }
        return item.isFolder
    }
    // The second step.
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? TreeNode {
            return item.subNodes[index]
        }
        return currentNode.subNodes[index]
    }
}
// MARK: - OutlineView delegate
extension TENavigationViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let columnId = tableColumn?.identifier.rawValue else {
            return nil
        }
        var cell: NSTableCellView?
        cell = outlineView.makeView(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: columnId),
            owner: self
            ) as? NSTableCellView
        guard let item = item as? TreeNode else {
            return cell
        }
        if columnId == "AutomaticTableColumnIdentifier.0" {
            cell?.textField?.stringValue = item.nodeName
        }
        // MARK: Icon
        var icon: NSImage!
        if let iconValues = try? item.nodePath?.resourceValues(forKeys: [.customIconKey, .effectiveIconKey]) {
            if let customIcon = iconValues.customIcon {
                icon = customIcon
            } else if let effectiveIcon = iconValues.effectiveIcon as? NSImage {
                icon = effectiveIcon
            }
        } else {
            // Failed to not find the icon from the URL, make a generic one.
            let osType = item.isFolder ? kGenericFolderIcon : kGenericDocumentIcon
            let iconType = NSFileTypeForHFSTypeCode(OSType(osType))
            icon = NSWorkspace.shared.icon(forFileType: iconType!)
        }
        cell?.imageView?.image = icon
        return cell
    }
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = self.filesListOutlineView.selectedRow
        if selectedRow < 0 { return }
        var treeNode: TreeNode?
        if let selectedTreeNode = self.filesListOutlineView.item(atRow: selectedRow) as? TreeNode {
            treeNode = selectedTreeNode
        }
        // 由于使用后台解析log，当用户可以点击 test item 时，解析可能没有结束
        // 若这个test item解析完成，testItem?.rangesOfFailType 不为 nil
        if treeNode?.nodePath != nil {
            NSLog((treeNode?.nodePath?.path)!+"\nat \(selectedRow) row")
            var info = [String: TreeNode]()
            info["selectedTestItem"] = treeNode
            NotificationCenter.default.post(name:  Notification.Name(TENavigationViewController.NotificationNames.selectionChanged),
                                            object: self.view.window,
                                            userInfo: info)
        } else {
            let alert = NSAlert()
            alert.messageText = "Please Wait"
            alert.informativeText = "is on parsing..."
            alert.alertStyle = NSAlert.Style.informational
            alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
        }
    }
}
// MARK: - Node Model
struct TreeNode {
    var nodePath: URL?
    var nodeName: String
    var isFolder: Bool
    var subNodes = [TreeNode]()
    init() {
        self.nodePath = nil
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
            self.nodePath = nil
            self.nodeName = ""
            self.isFolder = false
            return
        }
        if !FileManager.default.isReadableFile(atPath: url.path) {
            // If the file isn't readable.
            self.nodePath = url
            self.nodeName = url.lastPathComponent
            self.isFolder = false
            return
        }
        self.nodePath = url
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
