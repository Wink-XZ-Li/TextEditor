//
//  ShowLineNumber.swift
//  TextEditor
//
//  Created by X2000307 on 2020/9/29.
//  Copyright © 2020 X2000307. All rights reserved.
//

import Cocoa

class ShowLineNumber: NSViewController {
    @IBAction func isShowLineNumberView(_ sender: NSButton) {
        var rulersvisible = true
        //let textView = NSTextView()
        let state = sender.state
        if state == .on {
            rulersvisible = true
            NotificationCenter.default.post(name: Notification.Name(rawValue: "textView.enclosingScrollView?.rulersVisible"),
                                        object: self.view.window?.windowController?.document,
                                        userInfo: ["rulersvisible": rulersvisible])
        } else {
            rulersvisible = false
            NotificationCenter.default.post(
            name: Notification.Name(rawValue: "textView.enclosingScrollView?.rulersVisible"),
            object: self.view.window?.windowController?.document,
            userInfo: ["rulersvisible": rulersvisible])
        }
    }
}
