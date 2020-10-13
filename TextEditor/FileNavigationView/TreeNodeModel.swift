//
//  TreeNodeModel.swift
//  TextEditor
//
//  Created by Bernie on 2020/9/28.
//  Copyright © 2020 Bernie. All rights reserved.
//

import Cocoa
class TreeNodeModel: NSObject {
    var name: String?
    lazy var childNodes: Array = {
        return [TreeNodeModel]()
    }()
}
