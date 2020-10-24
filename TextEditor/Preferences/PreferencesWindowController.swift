//
//  PreferencesWindowController.swift
//  TextEditor
//
//  Created by X2000307 on 2020/10/8.
//  Copyright © 2020 X2000307. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {
        var showLineNumber: ShowLineNumber?
        var selectnumber = 1
        @IBOutlet weak var toolBar: NSToolbarItem!
        @IBOutlet weak var toolBar1: NSToolbarItem!
        override func windowDidLoad() {
            super.windowDidLoad()
            //maybe send a noticfation
            //it will be deal later
        }
        @IBAction func toolbarItemClicked(_ sender: NSToolbarItem) {
            selectnumber = 0
            let myNotification = Notification.init(name: Notification.Name(rawValue: "ShowLineNumber"),
                                                   object: self.window?.windowController?.document,
                                                   userInfo: ["selectnumber" : selectnumber])
            NotificationCenter.default.post(myNotification)
        }
        @IBAction func toolbar1(_ sender: Any) {
            selectnumber = 1
            let myNotification = Notification.init(name: Notification.Name(rawValue: "DefaultTextEncoding"),
                                                   object: self.window?.windowController?.document,
                                                   userInfo: ["selectnumber" : selectnumber])
            NotificationCenter.default.post(myNotification)
        }
}
