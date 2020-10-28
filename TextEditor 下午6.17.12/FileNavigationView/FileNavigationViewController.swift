//
//  FileNavigationViewController.swift
//  TextEditor
//
//  Created by Bernie on 2020/9/28.
//  Copyright © 2020 Bernie. All rights reserved.
//

import Cocoa
class FileNavigationViewController: NSViewController {
    // MARK: Constants
    struct NotificationNames {
        // Notification that the tree controller's selection has changed (used by SplitViewController).
        static let selectionChanged = "selectionChangedNotification"
        static let openURL = "openURLNotification"
    }
    var outlineViewMenu: NSMenu?
    // Note: close SandBox before you use “ProcessInfo.processInfo.environment”
    // Recorde clickedRow for the operation of renameItem.
    var theLastClickedRow = -1
    // Necessary for the operation of renameItem.
    var itemShouldBeUsed: Any?
//***************************************
    static func alertInvalidPath(window: NSWindow) {
     let alert=NSAlert()
        alert.messageText="Invalid Path!"
        alert.informativeText="Error: Current path you selceted is Invalid!"
        alert.alertStyle=NSAlert.Style.critical
        alert.beginSheetModal(for: window, completionHandler: nil)
}
    @IBOutlet weak var treeView: NSOutlineView!
    @IBOutlet weak var filePath: NSPathControl!
//    var treeModel = TreeNode()
//    var currentURL: URL = URL.init(fileURLWithPath: "")
    var defaultOpenedURL = URL.init(fileURLWithPath: ProcessInfo.processInfo.environment["HOME"]!+"/Downloads/")
    var currentNode: TreeNode?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
//        self.configData()
        setupObservers()
        self.filePath.url=defaultOpenedURL
        print(ProcessInfo.processInfo.environment["HOME"]!)
        loadRightClickMenu()
    }
    // MARK: Notifications
    private func setupObservers() {
        // Notification to add a folder.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(openURL(_:)),
            name: Notification.Name(FileNavigationViewController.NotificationNames.openURL),
            object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dealWithDragFileIntoTextEditorView(notification:)),
                                               name: NSNotification.Name("dragFileIntoTextEditorView"),
                                               object: nil)
    }
    // Notification sent from Document class, to openNewDocument.
    @objc private func openURL(_ notif: Notification) {
        guard let userInfo = notif.userInfo as? [String: Any],
            let openURL = userInfo["openURL"] as? URL,
            let window = notif.object as? NSWindow
        else {
            return
        }
        if window != self.view.window! {
            return
        }
        repositionItemInThisDatalogTree(for: URL.init(fileURLWithPath: openURL.path))
        //print("I am newDocumentOf:", openURL.path)
    }
    ///manage drag text file onto text editor view
    @objc private func dealWithDragFileIntoTextEditorView(notification: Notification) {
        let filePath = notification.userInfo?["filePath"]
        let fileUrl = URL(fileURLWithPath: filePath as? String ?? "")
        let deletedUrl = fileUrl.deletingLastPathComponent()
        let deletedPath = deletedUrl.path
        print("deletedPath:\(deletedPath)")
        defaultOpenedURL = deletedUrl
        print(deletedUrl.lastPathComponent)
        currentNode = nil
        self.treeView.reloadData()
        self.filePath.url = deletedUrl
    }
// MARK: select File from pathcontrol
    @IBAction func filePathAction(_ sender: NSPathControl) {
        guard let url=sender.clickedPathItem?.url else {
            return
        }
        defaultOpenedURL=url
        print(url.lastPathComponent)
        currentNode = nil
        self.treeView.reloadData()
}
    @objc func revealInFinder() {
        if let url = filePath.url {
            let urlArray=[url]
            NSWorkspace.shared.open(urlArray,
            withAppBundleIdentifier: "com.apple.Finder",
            options: NSWorkspace.LaunchOptions.andHideOthers,
            additionalEventParamDescriptor: nil,
            launchIdentifiers: nil)
        }
    }
}
// MARK: - NSPathControlDelegate
extension FileNavigationViewController: NSPathControlDelegate {
    func pathControl(_ pathControl: NSPathControl, willPopUp menu: NSMenu) {
        let menuItem=NSMenuItem(title: "Reval in finder", action: #selector(revealInFinder), keyEquivalent: "")
        menuItem.target=self
        menu.addItem(.separator())
        menu.addItem(menuItem)
    }
    func pathControl(_ pathControl: NSPathControl, validateDrop info: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.copy
    }
    func pathControl(_ pathControl: NSPathControl, acceptDrop info: NSDraggingInfo) -> Bool {
        let nsUrl=NSURL(from: info.draggingPasteboard)
        if let url=nsUrl?.filePathURL {
            print(url.absoluteURL)
//            return true
        }
        FileNavigationViewController.alertInvalidPath(window: self.view.window!)
        return false
    }
}
// MARK: - NSOutlineViewDelegate
extension FileNavigationViewController: NSOutlineViewDelegate {

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
               if let iconValues = try? item.nodeURL?.resourceValues(forKeys: [.customIconKey, .effectiveIconKey]) {
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

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 20
    }
    func outlineViewSelectionDidChange(_ notification: Notification) {
            let selectedRow = treeView.selectedRow
            if selectedRow < 0 { return }
            var treeNode: TreeNode?
            if let selectedTreeNode = treeView.item(atRow: selectedRow) as? TreeNode {
                treeNode = selectedTreeNode
            }
            // 由于使用后台解析log，当用户可以点击 test item 时，解析可能没有结束
            // 若这个test item解析完成，testItem?.rangesOfFailType 不为 nil
            if treeNode?.nodeURL != nil {
//                NSLog((treeNode?.nodeURL?.path)!+"\nat \(selectedRow) row")
                guard let selectedTreeNode = treeView.item(atRow: treeView.selectedRow) as? TreeNode else {
                //           treeNode1 = selectedTreeNode
                //            print(selectedTreeNode.url)
                            return
                        }
                var info = [String: TreeNode]()
                info["selectedNode"] = selectedTreeNode
                NotificationCenter.default.post(name: Notification.Name(rawValue: "selectedNodeNotification"),
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
// MARK: - NSOutlineViewDataSource
extension FileNavigationViewController: NSOutlineViewDataSource {
    // The first step.
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? TreeNode {
            return item.subNodes.count
        }
        if currentNode == nil {
            currentNode = TreeNode(defaultOpenedURL)
        }
        return (currentNode?.subNodes.count)!
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
//        if self.itemShouldBeUsed != nil {
//            return itemShouldBeUsed!
//        }
        if let item = item as? TreeNode {
            return item.subNodes[index]
        }
        return currentNode!.subNodes[index]
    }
}
// MARK: - Extension FileManager
extension FileManager {
    static func directoryIsExists(url: URL) -> Bool {
        var directoryExists = ObjCBool.init(false)
        let fileExists = FileManager.default.fileExists(atPath: url.path, isDirectory: &directoryExists)
        return fileExists && directoryExists.boolValue
    }
    static func listDir(url: URL) -> [URL]? {
        if let contentsOfPath = try? FileManager.default.contentsOfDirectory(at: url,
                                                                        includingPropertiesForKeys: nil,
                                                                        options: .skipsHiddenFiles) {
            return contentsOfPath
        }
        return nil
    }
}
