//
//  String.swift
//  TextEditor
//
//  Created by Wink on 2020/10/24.
//  Copyright © 2020 Bernie. All rights reserved.
//

import Cocoa
extension String {
    func checkFileTypeWhetherText(filePath: String) -> Bool {
         if filePath==""{
         } else {
         let res = docTypeAndCharset(filePath: filePath)
         return res.docType.hasPrefix("text")
         }
         return false
     }
    func checkFileTypeWhetherFolder(filePath: String) -> Bool {
        if filePath==""{
        } else {
        let res = docTypeAndCharset(filePath: filePath)
            return res.docType.hasPrefix("inode")
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
}
