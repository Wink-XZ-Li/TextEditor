//
//  DefaultTextEncoding.swift
//  TextEditor
//
//  Created by Bernie on 2020/10/12.
//  Copyright © 2020 Bernie. All rights reserved.
//
import Cocoa

class DefaultTextEncoding: NSViewController {

    @IBOutlet weak var popUpButton: NSPopUpButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dynamicDataConfig()
        // Do view setup here.
    }
    func dynamicDataConfig() {
        let nnnn = ["Unicode (UTF-8)", "日文(Shift JIS)", "日文(EUC)", "日文(Windows, DOS)", "日文(Shift JIS X0213)",
                    "日文(Mac OS)", "日文(ISO 2022-JP)",  "西文(Mac OS Roman)", "西文(Windows Latin 1)", "中文(GB 18030)",
                    "繁体中文(Big 5 HKSCS)", "繁体中文(Big 5-E)", "繁体中文(Big 5)", "繁体中文(Mac OS)", "简体中文(Mac OS)",
                    "繁体中文(EUC)", "简体中文(GB 2312)", "繁体中文(Windows, DOS)", "简体中文(Windows, DOS)", "韩文(Mac OS)",
                    "韩文(EUC)", "韩文(Windows, DOS)", "泰文(Windows, DOS)", "泰文(ISO 8859-11)", "阿拉伯文(Mac OS)",
                    "阿拉伯文(ISO 8859-6)", "阿拉伯文(Windows)", "希腊文(Mac OS)", "希腊文(ISO 8859-7)", "希腊文(Windows)",
                    "希伯来文(Mac OS)", "希伯来文(ISO 8859-8)", "希伯来文(Windows)", "西里尔文(Mac OS)", "西里尔文(ISO 8859-5)",
                    "西里尔文(Windows)", "中欧语系(Mac OS)", "土耳其文(Mac OS)", "冰岛文(Mac OS)", "西文(ISO Latin 1)",
                    "中欧语系(ISO Latin 2)", "西文(ISO Latin 3)", "中欧语系(ISO Latin 4)", "土耳其文(ISO Latin 5)",
                    "北日耳曼语支(ISO Latin 6)", "波罗的海文(ISO Latin 7)", "凯尔特文(ISO Latin 8)", "西文(ISO Latin 9)",
                    "罗马尼亚文(ISO Latin 10)",  "美国拉丁文(DOS)", "中欧语系(Windows Latin 2)", "西文(NextStep)", "西文(ASCII)",
                    "无损ASCII", "Unicode (UTF-16)", "Unicode (UTF-16BE)", "Unicode (UTF-16LE)", "Unicode (UTF-32)",
                    "Unicode (UTF-32BE)", "Unicode (UTF-32LE)"]
//       print(nnnn)
        //删除默认的初始数据
        self.popUpButton.removeAllItems()
        //增加数据items
        self.popUpButton.addItems(withTitles: nnnn)
        //设置第一行数据为当前选中的数据
        self.popUpButton.selectItem(at: 0)
    }
    @IBAction func popUpBtnAction(_ sender: NSPopUpButton) {
//        let items = sender.itemTitles
        let index = sender.indexOfSelectedItem
//        print("index",index)
//        let title = items[index]
//        print("select title \(title)")
        var userInfo = [String: Any]()
        userInfo["item"] = index
//        print("userinfo",userInfo["item"] as Any)
//        userInfo["isSelected"] = sender.isSelected(forSegment: index)
        NotificationCenter.default.post(name: Notification.Name("Encoding"),
                                        object: self.view.window, userInfo: userInfo)
    }
}
