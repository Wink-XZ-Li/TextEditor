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
            action: #selector(delete),
            keyEquivalent: "",
            at: 0)
            menu.insertItem(withTitle: "Select All",
                            action: #selector(selectAll),
                            keyEquivalent: "",
                            at: pasteIndex + 1)
            menu.insertItem(withTitle: "Copy File Path",
            action: #selector(selectAll),
            keyEquivalent: "",
            at: pasteIndex + 1)
        }
        return menu
    }
}
