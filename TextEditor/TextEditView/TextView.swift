//
//  TextView.swift
//  TextEditor
//
//  Created by Bernie on 2020/9/30.
//  Copyright © 2020 Bernie. All rights reserved.
//

import Cocoa

@objcMembers class TextView: NSTextView {
    var fontSize: CGFloat = 12
    var grainSize = 100
    var grainArray = [Int]()
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    // MARK: - override menu
    override func menu(for event: NSEvent) -> NSMenu? {
        guard let menu = super.menu(for: event) else { return nil }
        // add "Find" "Select All" menu item
        // pasteIndex + 1
        let pasteIndex = menu.indexOfItem(withTarget: nil, andAction: #selector(paste(_:)))
        if pasteIndex >= 0 {  // -1 == not found
            menu.insertItem(withTitle: "Find",
            action: #selector(openSearchBar),
            keyEquivalent: "",
            at: 0)
            menu.insertItem(withTitle: "Select All",
                            action: #selector(selectAll),
                            keyEquivalent: "",
                            at: pasteIndex + 1)
            menu.insertItem(withTitle: "Copy File Path",
            action: #selector(copyFilePath),
            keyEquivalent: "",
            at: pasteIndex + 1)
        }
        return menu
    }
    @objc func copyFilePath() {
            let pboard = NSPasteboard.general
            pboard.clearContents()
            pboard.setString(TextEditViewController.Information.textPath ?? "", forType: .string)
    }
    @objc func openSearchBar() {
        NotificationCenter.default.post(name: Notification.Name("openSearchBar"),
                                        object: self.window, userInfo: nil)
    }
    // MARK: Manage drag file
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let NSFilenamesPboardType = NSPasteboard.PasteboardType("NSFilenamesPboardType")
        if let board = sender.draggingPasteboard.propertyList(forType: NSFilenamesPboardType) as? NSArray,
            let filePath = board[0] as? String {
            if filePath.checkFileTypeWhetherText(filePath: filePath) {
                if filePath.checkFileTypeWhetherText(filePath: filePath) {
                        displayText_Wink(from: filePath)
                        print(filePath)
                        var userInfo = [AnyHashable: Any]()
                        userInfo["filePath"] = filePath
                        //let aaaa = filePath
                        NotificationCenter.default.post(name: Notification.Name("dragFileIntoTextEditorView"),
                                                        object: self.window,
                                                        userInfo: userInfo)
                }
            } else if filePath.checkFileTypeWhetherFolder(filePath: filePath) {
                let alert = NSAlert()
                alert.addButton(withTitle: "OK")
                alert.informativeText = "This is not a text type!"
                alert.messageText = "Alert"
                alert.alertStyle = .informational
                alert.beginSheetModal(for: self.window!, completionHandler: nil)
            }
        }
        return true
    }
    func displayText_Wink(from file: String) {
        var textValue: String?
        do {
            textValue=try String(contentsOfFile: file)
        } catch {
            print("Unable to read \(file)")
        }
        let textStorage=self.textStorage!
        textStorage.beginEditing()
        textStorage.replaceCharacters(in: .init(location: 0, length: textStorage.length), with: textValue!)
        textStorage.endEditing()
        let maxHeightForTextRect = CGFloat(1000_000_000) // 大约最多能承载 30_000_000 行
        self.frame.size.height = maxHeightForTextRect
        self.textContainer?.size.height = maxHeightForTextRect
        self.calculateLineCount()
    }
    ///计算行数
    func calculateLineCount() {
        let grainSize = 100
        var newLineCount = 1
        var grainArray = [0] //[Int]()
        let fieldScanner = Scanner(string: self.string)
        while !fieldScanner.isAtEnd {
            if !(fieldScanner.scanString("\n") != nil) {
                newLineCount += 1
            }
            fieldScanner.scanUpToCharacters(from: .newlines, into: nil)
            if (newLineCount % grainSize) == 0 {
                let location = fieldScanner.scanLocation
                grainArray.append(location)
            }
        }
        //print(grainArray)
        self.grainSize = grainSize
        self.grainArray = grainArray
        self.lnv_setUpLineNumberView()
    }
}
