//
//  TextView.swift
//  TextEditor
//
//  Created by Bernie on 2020/9/30.
//  Copyright © 2020 Bernie. All rights reserved.
//

import Cocoa

class TextView: NSTextView {
    var fontSize: CGFloat = 12
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
            if checkFileTypeWhetherText(filePath: filePath) {
                do {
                    print(filePath)
                    var textValue: String?
                    textValue = try String(contentsOfFile: filePath)
                    let readHandler = try? FileHandle(forReadingFrom: URL(fileURLWithPath: filePath))
                    let data = readHandler!.readDataToEndOfFile()
                    textValue = String(data: data, encoding: String.Encoding.utf8) ?? ""
                    let textStorage = self.textStorage!
                    textStorage.beginEditing()
                    textStorage.replaceCharacters(in: .init(location: 0, length: textStorage.length), with: textValue!)
                    textStorage.endEditing()
                    let maxHeightForTextRect = CGFloat(1000_000_000) // 大约最多能承载 30_000_000 行
                    self.frame.size.height = maxHeightForTextRect
                    self.textContainer?.size.height = maxHeightForTextRect
                    var userInfo = [AnyHashable: Any]()
                    userInfo["filePath"] = filePath
                    //let aaaa = filePath
                    NotificationCenter.default.post(name: Notification.Name("dragFileIntoTextEditorView"),
                                                    object: self.window,
                                                    userInfo: userInfo)
                } catch {}
            } else {
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
    func checkFileTypeWhetherText(filePath: String) -> Bool {
         if filePath==""{
         } else {
         let res = docTypeAndCharset(filePath: filePath)
         return res.docType.hasPrefix("text")
         }
         return false
     }
    func docTypeAndCharset(filePath: String) -> (docType: String, charset: String) {
         let command = "file '\(filePath)' --mime -b"
         let task = Process()
         let pipe = Pipe()
         task.standardOutput = pipe
         task.arguments = ["-c", command]
         task.executableURL = URL(fileURLWithPath: "/bin/bash")
         task.launch()
         let data = pipe.fileHandleForReading.readDataToEndOfFile()
         let output = String(data: data, encoding: .utf8)!.trimmingCharacters(in: .newlines)
         let docType = output[output.startIndex..<output.firstIndex(of: ";")!]
         let charset = output[output.index(after: output.firstIndex(of: "=")!)..<output.endIndex]
         return (String(docType), String(charset))
     }
}
