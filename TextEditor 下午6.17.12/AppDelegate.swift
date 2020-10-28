//
//  AppDelegate.swift
//  TextEditor
//
//  Created by Bernie on 2020/9/28.
//  Copyright © 2020 Bernie. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        print(12)
    }
    
    //显示PreferencesWindowController.storyboard窗口
       lazy var preferencesWindowController:PreferencesWindowController = {
        let sb = NSStoryboard(name: NSStoryboard.Name("PreferencesWindowController"), bundle: Bundle.main)
        let pWVC = sb.instantiateController(withIdentifier:NSStoryboard.SceneIdentifier("Preferences")) as? PreferencesWindowController ?? PreferencesWindowController.init()
        return pWVC
        }()
        @IBAction func showPreferenceWindowController(_ sender: AnyObject) {
            self.preferencesWindowController.window?.center()
            self.preferencesWindowController.showWindow(self)
        }
}
