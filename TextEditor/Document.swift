//
//  Document.swift
//  TextEditor
//
//  Created by Bernie on 2020/10/7.
//  Copyright © 2020 Bernie. All rights reserved.
//

import Cocoa

class Document: NSDocument {

    /*
    override var windowNibName: String? {
        // Override returning the nib file name of the document
        // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
        return "Document"
    }
    */

//    override func windowControllerDidLoadNib(_ aController: NSWindowController) {
//        super.windowControllerDidLoadNib(aController)
//        // Add any code here that needs to be executed once the windowController has loaded the document's window.
//    }
    override init() {
        super.init()
    }
    override class var autosavesInPlace: Bool {
      return false
    }
    override func makeWindowControllers() {
        let storyboard=NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller"))
            as? NSWindowController ?? NSWindowController.init()
        windowController.window?.minSize=NSMakeSize(400, 300)
        self.addWindowController(windowController)
    }

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override fileWrapper(ofType:),
        //write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type,
        //throwing an error in case of failure.
        // Alternatively,you could remove this method and override read(from:ofType:) instead.
        //If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    //save as保存文件
    override func write(to url: URL, ofType typeName: String) throws {
            NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: url.path)
            if typeName == "public.plain-text" {
                var userInfo = [String: Any]()
                userInfo["url"] = url
                userInfo["typeName"] = typeName
                NotificationCenter.default.post(name: Notification.Name("saveDataViaObserve"),
                                                object: self, userInfo: userInfo)
            }
             if typeName == "public.rtf" {
                var userInfo = [String: Any]()
                userInfo["url"] = url
                userInfo["typeName"] = typeName
                NotificationCenter.default.post(name: Notification.Name("saveDataViaObserve"),
                                                object: self, userInfo: userInfo)
            }
        }
    override func read(from url: URL, ofType typeName: String) throws {
        self.showWindows()
        NSDocumentController.shared.addDocument(self)

        var userInfo = [String: Any]()
        userInfo["openURL"] = url
        let time = DispatchTimeInterval.milliseconds(3)
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            NotificationCenter.default.post(name: Notification.Name(FileNavigationViewController.NotificationNames.openURL),
                                            object: self.windowControllers.last?.window, userInfo: userInfo)
        }
    }
}
