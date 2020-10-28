//
//  TextEditViewController.swift
//  TextEditor
//
//  Created by Bernie on 2020/9/28.
//  Copyright © 2020 Bernie. All rights reserved.
//

import Cocoa

class TextEditViewController: NSViewController {
    var fileReadPath: String = ""
    @IBOutlet weak var fileImage: NSImageView!
    @IBOutlet weak var label: NSTextField!
    @IBOutlet var textView: TextView!
    var url: URL?
    //获取设置中的编码格式
    var saveEncoding = CFStringConvertEncodingToNSStringEncoding(UInt32(
        DefaultSettings.encodings[UserDefaults.standard.object(forKey: "saveEncoding") as? Int ?? Int.init()]))

    struct Information {
        static var textPath: String? = ""
    }
    //var myfont: NSFont?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        //保存修改字体字号、颜色配置
//         if(myfont == nil){
//             //myfont = textview.font
//             myfont = self.textView.font
//             print(self.textView.font)
//         }else{
//             //textview.font = myfont
//             myfont = self.textView.font
//             self.textView.font = myfont
//             print(self.textView.font)
//         }
//         //let abc = self.textview.font
//        // let def = self.
//         //print(self.textview.font)
        setupObservers()
        textView.calculateLineCount()
        NotificationCenter.default.addObserver(self, selector: #selector(dealSelectedEncoding(notice:)),
                                               name: NSNotification.Name(rawValue: "Encoding"),
                                               object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(dealOpenSearchBar),
                                               name: NSNotification.Name(rawValue: "openSearchBar"),
                                               object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(dealSelectedNode(notif:)),
                                               name: NSNotification.Name(rawValue: "selectedNodeNotification"),
                                               object: self.view.window)
        //获取来自Document.swift的消息
        NotificationCenter.default.addObserver(self, selector: #selector(saveDataViaObserve),
                                               name: NSNotification.Name(rawValue: "saveDataViaObserve"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dealWithDragFileIntoTextEditorView(notification:)),
                                               name: NSNotification.Name("dragFileIntoTextEditorView"),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dragOntoPathControl),
                                               name: Notification.Name(rawValue: "dragFolderOntoPathControl"),
                                               object: nil)
}
    //******************************************************************************************
    // MARK: Notifications
    private func setupObservers() {
        // Notification to add a folder.
        NotificationCenter.default.addObserver(self, selector: #selector(showTextFile), name:
            NSNotification.Name(rawValue: FileNavigationViewController.NotificationNames.selectionChanged), object: nil)
    }
    //receive the notification of drag onto path control
    @objc private func dragOntoPathControl(notification: Notification) {
        textView.string=""
        fileImage.image=NSImage.init(named: NSImage.multipleDocumentsName)
        label.stringValue="文件名字"
    }
    //receive the notification of drag onto text edit view
    @objc private func dealWithDragFileIntoTextEditorView(notification: Notification) {
        let filePath = notification.userInfo?["filePath"]
        let labelImageURL = URL(fileURLWithPath: filePath as? String ?? "")
        if let iconValues = try? labelImageURL.resourceValues(forKeys: [.customIconKey, .effectiveIconKey]) {
            if let customIcon = iconValues.customIcon {
                fileImage.image = customIcon
            } else if let effectiveIcon = iconValues.effectiveIcon as? NSImage {
                fileImage.image = effectiveIcon
            }
            label.stringValue = labelImageURL.lastPathComponent
        } else {
        fileImage.image=NSImage.init(named: NSImage.iconViewTemplateName)
        }
    }
    // Notification sent from TENavigationViewController+NSMenuDelegate class, to rename the treeNode.
    @objc private func showTextFile(_ notif: Notification) {
        guard let userInfo = notif.userInfo as? [String: Any],
            let getNode = userInfo["selectedTestItem"] as? TreeNode,
            let window = notif.object as? NSWindow
        else {
            return
        }
        if window != self.view.window! {
            return
        }
        if ((userInfo["selectedTestItem"] as? TreeNode) != nil) {
            try? textView.textStorage?.read(from: getNode.nodeURL!, options: [:], documentAttributes: nil, error: ())
        }
    }
   //********************************************************************************************
     @objc func dealSelectedEncoding(notice: NSNotification) {
        guard let receiveInfo=notice.userInfo?["item"] as? Int else {return}
    //           print("observer",receiveInfo)
         changeEncoding(receiveInfo: receiveInfo)
           }
        @objc func dealOpenSearchBar() {
              let selectedRange = textView.selectedRange()
            let selectedCharacters = textView.accessibilityString(for:selectedRange)
              let pboard=NSPasteboard(name: .find)
              pboard.clearContents()
              pboard.setString((selectedCharacters ?? "") as String, forType: .string)
              let button=NSButton()
              button.tag=NSTextFinder.Action.showFindInterface.rawValue
              textView.performFindPanelAction(button)
              pboard.clearContents()
            }
        @objc func dealSelectedNode(notif: NSNotification) {
            guard let userInfo = notif.userInfo as? [String: Any],
                let getNode = userInfo["selectedNode"] as? TreeNode,
                let window = notif.object as? NSWindow
            else {
                return
            }
            if window != self.view.window! {
                return
            }
            let readPath = getNode.nodeURL!.path
            fileReadPath = readPath
            let labelImageURL = getNode.nodeURL
            if let iconValues = try? labelImageURL?.resourceValues(forKeys: [.customIconKey, .effectiveIconKey]) {
                if let customIcon = iconValues.customIcon {
                    fileImage.image = customIcon
                } else if let effectiveIcon = iconValues.effectiveIcon as? NSImage {
                    fileImage.image = effectiveIcon
                }
            } else {
            fileImage.image=NSImage.init(named: NSImage.iconViewTemplateName)
            }
//           print(info?["selectedNode"]?.url?.lastPathComponent)
            let labeName:String = getNode.nodeURL?.lastPathComponent ?? ""
//            print(labeName)
            label.stringValue = labeName
            url = URL.init(fileURLWithPath: readPath)
            if checkFileTypeWhetherText(filePath: readPath ?? "/Users") {
              displayText(from: readPath)
//                self.textView.string = ""
//                try? textView.textStorage?.read(from: url!, options: [:], documentAttributes: nil, error: ())
                TextEditViewController.self.Information.textPath = readPath
    //            print("display")
            } else {
                TextEditViewController.self.Information.textPath = readPath
                textView.string=""
    //            TextEditViewController.self.Information.textPath = ""
            }
        }
        func checkFileTypeWhetherText(filePath: String) -> Bool {
            if filePath==""{
            } else {
            let res = docTypeAndCharset(filePath: filePath)
            return res.docType.hasPrefix("text")
            }
            return false
        }
       func docTypeAndCharset(filePath: String) -> (docType: String, charset: String) {
            let command = "file '\(filePath)' --mime -b"
            let task = Process()
            let pipe = Pipe()
            task.standardOutput = pipe
            task.arguments = ["-c", command]
            task.executableURL = URL(fileURLWithPath: "/bin/bash")
            task.launch()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!.trimmingCharacters(in: .newlines)
            let docType = output[output.startIndex..<output.firstIndex(of: ";")!]
            let charset = output[output.index(after: output.firstIndex(of: "=")!)..<output.endIndex]
            return (String(docType), String(charset))
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
        let maxHeightForTextRect = CGFloat(1000_000_000) // 大约最多能承载 30_000_000 行
        self.textView.frame.size.height = maxHeightForTextRect
        self.textView.textContainer?.size.height = maxHeightForTextRect
        self.textView.calculateLineCount()
        let receiveInfo = UserDefaults.standard.object(forKey: "saveEncoding") as? Int ?? Int.init()
        changeEncoding(receiveInfo: receiveInfo)
    }

    func changeEncoding(receiveInfo: Int) {
        if checkFileTypeWhetherText(filePath: fileReadPath) {
            var textValue: String?
            do {
                textValue=try String(contentsOfFile:fileReadPath)
                let readHandler = try? FileHandle(forReadingFrom: URL(fileURLWithPath: fileReadPath))
                let data = readHandler!.readDataToEndOfFile()
                saveEncoding = CFStringConvertEncodingToNSStringEncoding(UInt32(DefaultSettings.encodings[receiveInfo]))
                do {
                    textValue = try String(data: data, encoding: String.Encoding(rawValue: saveEncoding)) ?? ""
                } catch {
                        print("cano not revert")
                        }
            } catch {
               print("Unable to read ")
            }
            let textStorage=textView.textStorage!
            textStorage.beginEditing()
            textStorage.replaceCharacters(in: .init(location: 0, length: textStorage.length), with: textValue!)
            textStorage.endEditing()
            } else {
        }
    }
    // 菜单栏save as的方法
    @objc func saveDataViaObserve(notice: Notification) {
        guard let url = notice.userInfo?["url"] as? URL,
            let typeName = notice.userInfo?["typeName"] as? String else {
                return
        }
        print(typeName)
        if typeName == "public.plain-text" {
            let info = textView.textStorage?.string
            do {
                try info?.write(to: url, atomically: true, encoding: String.Encoding(rawValue: saveEncoding))
            } catch {
                print("error")
            }
        }
        if typeName == "public.rtf" {
        print(notice)
        let textcontent = self.textView.attributedString()
            let data = try? textcontent.fileWrapper(from: NSRange.init(location: 0, length: textcontent.length),
            documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
        saveData(data: data!, url: url)
        }
    }
    func saveData (data: FileWrapper, url: URL) {
        let filename = url
        do {
                 try data.write(to: filename, options: .atomic, originalContentsURL: nil)
                 print(filename)
            } catch {
            }
    }

    // 菜单栏save的方法
    @IBAction func saveFile(_ sender: Any) {
        let  fileExtension = url?.pathExtension
        let fileManager = FileManager.default
        if url != nil {
        let exist = fileManager.fileExists(atPath: url!.path)
        // 查看文件夹是否存在，如果存在就直接读取，不存在就直接反空
        if exist {
             if fileExtension == "rtf" {
                let textcontent = self.textView.attributedString()
                    let data = try? textcontent.fileWrapper(
                        from: NSRange.init(location: 0, length: textcontent.length),
                        documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
                saveData(data: data!, url: url!)
            } else {
                let info = textView.textStorage?.string
                do {
                     try info?.write(to: url!, atomically: true, encoding: String.Encoding(rawValue: saveEncoding))
                } catch {
                    print("error")
                }
            }
        } else {
          print("Save failed")
        }
    } else {
            self.view.window?.windowController?.document?.saveAs(nil)
        }
    }
}
