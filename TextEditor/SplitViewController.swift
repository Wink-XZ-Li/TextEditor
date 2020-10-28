//
//  SplitViewController.swift
//  TextEditor
//
//  Created by Bernie on 2020/10/7.
//  Copyright © 2020 Bernie. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
         NotificationCenter.default.addObserver(self, selector: #selector(collapseView), name: NSNotification.Name(rawValue: WindowViewController.NotificationNames.collapseView), object: nil)
    }
    @objc func collapseView(notice: Notification) {
        guard let userInfo = notice.userInfo as? [String: Any],
            let item = userInfo["item"] as? Int,
            let isSelected = userInfo["isSelected"] as? Bool,
            let window = notice.object as? NSWindow
        else {
            return
        }
        if window != self.view.window! {
            return
        }
        if self.splitViewItems[item].isCollapsed == isSelected {
            self.splitViewItems[item].animator().isCollapsed = !isSelected
        }
    }
}
