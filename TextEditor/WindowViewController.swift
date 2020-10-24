//
//  WindowViewController.swift
//  TextEditor
//
//  Created by Bernie on 2020/10/7.
//  Copyright © 2020 Bernie. All rights reserved.
//

import Cocoa

class WindowViewController: NSWindowController {
    struct NotificationNames {
        static let collapseView="collapseViewNotfication"
        static let WindowViewDidLoad="WindowDidLoadNotification"
    }
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization
        //after your window controller's window has been loaded from its nib file.
            // Implement this method to handle any initialization
        //after your window controller's window has been loaded from its nib file.
//        let window = self.window as! Win
//            window.action=#selector(hotKeyToggleCollapseButrton(_:))
//            window.target=self
//
//            NotificationCenter.default.post(name: Notification.Name(WindowViewController.NotificationNames.WindowViewDidLoad), object: self.window)
    }
//    @IBOutlet weak var collapseControll: NSSegmentedControl!
//    @objc func  hotKeyToggleCollapseButrton(_ sender: Win){
//        var item:Int?
//        if sender.hotKeyOfEvent == Win.HotKey.cmdN1{
//            item=0
//        }
//        if let item = item{
//            sender.hotKeyOfEvent=nil
//            let status=collapseControll.isSelected(forSegment: item)
//            collapseControll.setSelected(!status, forSegment: item)
//
//            var userInfo=[String:Any]()
//            userInfo["item"]=item
//            userInfo["isSelected"] = !status
//            NotificationCenter.default.post(name:Notification.Name(NotificationNames.collapseView), object: self.window, userInfo: userInfo)
//        }
//    }

    @IBAction func collapseView(_ sender: NSSegmentedControl) {
    for index in 0..<sender.segmentCount {
            var userInfo = [String: Any]()
            userInfo["item"] = index
            userInfo["isSelected"] = sender.isSelected(forSegment: index)
            NotificationCenter.default.post(name: Notification.Name(NotificationNames.collapseView),
                                            object: self.window, userInfo: userInfo)
        }
        }
}
// MARK: - add HotKey
//class Win:NSWindow{
//    var action:Selector?
//    var target:WindowViewController?
//    enum HotKey{
//        case cmdN1
//    }
//    var hotKeyOfEvent:HotKey?
//
//override func performKeyEquivalent(with event: NSEvent) -> Bool {
//    let cmdTypeWriteKey1=18
//    let cmdNumericKey1=83
//    let cmdKeyMask=NSEvent.ModifierFlags.command.rawValue
//
//    if(event.type == .keyDown)&&(event.modifierFlags.rawValue & cmdKeyMask) == cmdKeyMask{
//        if event.keyCode == cmdTypeWriteKey1 || event.keyCode == cmdNumericKey1{
//            hotKeyOfEvent=HotKey.cmdN1
//        }
//        if hotKeyOfEvent != nil{
//            NSApp.sendAction(action!, to: target, from: self)
//            return true
//        }
//    }
//    return super.performKeyEquivalent(with: event)
//    }
//}
