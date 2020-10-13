//
//  TextEditViewController.swift
//  TextEditor
//
//  Created by Bernie on 2020/9/28.
//  Copyright © 2020 Bernie. All rights reserved.
//

import Cocoa

class TextEditViewController: NSViewController{

    @IBOutlet var textView: TextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupObservers()
        textView.lnv_setUpLineNumberView()
//        NotificationCenter.default.addObserver(self, selector: #selector(dealSelectedText), name:NSNotification.Name(rawValue: FileNavigationViewController), object: self.view.window)
}
    // MARK: Notifications
    private func setupObservers() {
        // Notification to add a folder.
        NotificationCenter.default.addObserver(self, selector: #selector(showTextFile), name: NSNotification.Name(rawValue: TENavigationViewController.NotificationNames.selectionChanged), object: nil)
    }
    // Notification sent from TENavigationViewController+NSMenuDelegate class, to rename the treeNode.
    @objc private func showTextFile(_ notif: Notification) {
        guard let userInfo = notif.userInfo as? [String: Any] else {
            return
        }
        guard let getNode = userInfo["selectedTestItem"] as? TreeNode else {
            return
        }
        if ((userInfo["selectedTestItem"] as? TreeNode) != nil) {
            let readHandler = try? FileHandle(forReadingFrom: getNode.nodePath!)
            let data=readHandler?.readDataToEndOfFile() ?? Data()
            let readdString = String(data: data, encoding: .utf8)
            self.textView.string = readdString ?? ""
        }
    }
    @objc func dealSelectedText(notice: NSNotification) {
        print("dealSelectedText")
    }
    func displayText(from file: String) {
        var textValue: String?
        do {
            textValue=try String(contentsOfFile: file)
        } catch {
            print("Unable to read \(file)")
        }
        let textStorage=textView.textStorage!
        textStorage.beginEditing()
        textStorage.replaceCharacters(in: .init(location: 0, length: textStorage.length), with: textValue!)
        textStorage.endEditing()
    }
}
