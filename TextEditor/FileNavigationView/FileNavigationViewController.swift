//
//  FileNavigationViewController.swift
//  TextEditor
//
//  Created by Bernie on 2020/9/28.
//  Copyright © 2020 Bernie. All rights reserved.
//

import Cocoa
class FileNavigationViewController: NSViewController {
    static func alertInvalidPath(window: NSWindow)  {
     let alert=NSAlert()
        alert.messageText="Invalid Path!"
        alert.informativeText="Error: Current path you selceted is Invalid!"
        alert.alertStyle=NSAlert.Style.critical
        alert.beginSheetModal(for: window, completionHandler: nil)
    }
    
    @IBOutlet weak var treeView: NSOutlineView!
    @IBOutlet weak var filePath: NSPathControl!
    var treeModel: TreeNodeModel = TreeNodeModel()
    var preURL: URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
//        self.configData()
    }
    func configData()  {
        let rootNode=TreeNodeModel()
        rootNode.name="文件夹1"
        let rootNode2=TreeNodeModel()
        rootNode2.name="文件夹2"

        self.treeModel.childNodes.append(rootNode)
        self.treeModel.childNodes.append(rootNode2)

        let level11Node=TreeNodeModel()
        level11Node.name="level11"
        let level12Node=TreeNodeModel()
        level12Node.name="level12"
        rootNode.childNodes.append(level11Node)
        rootNode2.childNodes.append(level12Node)

        let level21Node=TreeNodeModel()
        level21Node.name="levl21"
        let level22Node=TreeNodeModel()
        level22Node.name="level22"

        level11Node.childNodes.append(level21Node)
        level12Node.childNodes.append(level22Node)
        self.treeView.reloadData()
    }
// MARK: select File from pathcontrol
    @IBAction func filePathAction(_ sender: NSPathControl) {
        guard let url=sender.clickedPathItem?.url else {
            return
        }
//        if let logURLs = LVLogPathValidator.isValid(logPath: url) {
//            self.view.window?.title = url.path
//            self.FilePath.url = url
//            self.preURL=url
              print(url.path)
        var fileNameArray: [String]=[]
        do {
            fileNameArray=try FileManager.default.contentsOfDirectory(atPath: url.path)
        } catch let error as NSError {
            print("get file path error:\(error)")
        }
        for index in fileNameArray {
                    let rootNode=TreeNodeModel()
                    rootNode.name=index
                    self.treeModel.childNodes.append(rootNode)
            self.treeView.reloadData()
        }
//            self.parseLogs(from: logURLs)
//            self.show(logs: logViewer?.logs)
//            return
//        }
//        self.FilePath.url = self.preURL
//    FileNavigationViewController.alertInvalidPath(window: self.view.window!)
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
        let view = outlineView.makeView(withIdentifier: (tableColumn?.identifier)!, owner: self)
        let subviews = view?.subviews
        let imageView=subviews?[1] as? NSImageView ?? NSImageView.init()
        let field=subviews?[0] as? NSTextField ?? NSTextField.init()
        let model=item as? TreeNodeModel ?? TreeNodeModel.init()
        field.stringValue=model.name!
        if model.childNodes.count<=0 {
            imageView.image=NSImage(named: NSImage.listViewTemplateName)
        }
        return view
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 20
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let treeView=notification.object as? NSOutlineView else {return}
        let row=treeView.selectedRow
        let model=treeView.item(atRow: row)
        let pppp = treeView.parent(forItem: model)

        print("model:\(String(describing: model))")
        print("p:\(String(describing: pppp))")
    }

}

// MARK: - NSOutlineViewDataSource
extension FileNavigationViewController: NSOutlineViewDataSource {

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        let rootNode: TreeNodeModel
        if item != nil {
            rootNode=item as? TreeNodeModel ?? TreeNodeModel.init()
        } else {
            rootNode=self.treeModel
        }
        return rootNode.childNodes.count
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        let rootNode: TreeNodeModel
        if item != nil {
            rootNode=item as? TreeNodeModel ?? TreeNodeModel.init()
        } else {
            rootNode=self.treeModel
        }
        return rootNode.childNodes[index]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        let rootNode: TreeNodeModel = item as? TreeNodeModel ?? TreeNodeModel.init()
        return rootNode.childNodes.count>0
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
