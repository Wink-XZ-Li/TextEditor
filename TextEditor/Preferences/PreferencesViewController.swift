//
//  ViewController.swift
//  TextEditor
//
//  Created by X2000307 on 2020/9/28.
//  Copyright © 2020 X2000307. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {

    var currentController: NSViewController?
    override func viewDidLoad() {
        super.viewDidLoad()  // Do any additional setup after loading the view.
        //print(UserDefaults.standard.object(forKey: "preferences")!)
        self.initiateControllers()
        self.changeViewController(0)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showLineNumberValue(notification:)),
                                               name: NSNotification.Name(rawValue: "ShowLineNumber"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(defaultTextEncodingValue(notification:)),
                                               name: NSNotification.Name(rawValue: "DefaultTextEncoding"),
                                               object: nil)
    }
    @objc func showLineNumberValue(notification: Notification) {
        let dic = notification.userInfo! as Dictionary
        self.changeViewController(dic["selectnumber"]! as? Int ?? Int.init())
    }
    @objc func defaultTextEncodingValue(notification: Notification) {
        let dic = notification.userInfo! as Dictionary
        self.changeViewController(dic["selectnumber"]! as? Int ?? Int.init())
    }
    func initiateControllers() {
        let vc1 = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("FirstVC"))
            as? NSViewController ?? NSViewController.init()
        let vc2 = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("SecondVC"))
            as? NSViewController ?? NSViewController.init()
        self.addChild(vc1)
        self.addChild(vc2)
    }
    func changeViewController(_ index:NSInteger) {
        if currentController != nil{
            currentController?.view.removeFromSuperview()
        }
        //数组越界保护
        guard index >= 0 && index <= self.children.count-1 else {
            return
        }
        currentController = self.children[index]
        self.view.addSubview((currentController?.view)!)
    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}
