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
    let saveShowLineNumber = "saveshowlinenumber"
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    func application(_ sender: NSApplication, openFiles filenames: [String]) {
//        print(filenames[0])
        var userInfo=[String: [String]]()
        userInfo["dragFileToIcon"] = filenames
//        print(userInfo["dragFileToIcon"]![0])
        NotificationCenter.default.post(name: Notification.Name(rawValue: "dragFileToIcon"),
                                        object: self,
                                      userInfo: userInfo)
    }
    //保存用户修改配置
    override init() {
              super.init()
        let defaults = [saveShowLineNumber: 6, "saveEncoding": 0, "saveFonts": 1]
              UserDefaults.standard.register(defaults: defaults)
              NSUserDefaultsController.shared.initialValues = defaults
          }
    //显示PreferencesWindowController.storyboard窗口
       lazy var preferencesWindowController:PreferencesWindowController = {
        let sb = NSStoryboard(name: NSStoryboard.Name("PreferencesWindowController"), bundle: Bundle.main)
        let pWVC = sb.instantiateController(withIdentifier:NSStoryboard.SceneIdentifier("Preferences"))
            as? PreferencesWindowController ?? PreferencesWindowController.init()
        return pWVC
        }()
        @IBAction func showPreferenceWindowController(_ sender: AnyObject) {
            self.preferencesWindowController.window?.center()
            self.preferencesWindowController.showWindow(self)
        }
}
