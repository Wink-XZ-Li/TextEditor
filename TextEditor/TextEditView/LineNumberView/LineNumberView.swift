//
//  LineNumberView.swift
//  lineDemo
//
//  Created by Wink on 2020/10/12.
//  Copyright © 2020 Wink. All rights reserved.
//

import AppKit
import Foundation
import ObjectiveC
var lineNumberViewAssocObjKey: UInt8 = 0

var savepreferencesbool = true

extension NSTextView {
    var lineNumberView: LineNumberRulerView? {
        get {
            return objc_getAssociatedObject(self, &lineNumberViewAssocObjKey) as? LineNumberRulerView
        }
        set {
            objc_setAssociatedObject(self, &lineNumberViewAssocObjKey, newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    func lnv_setUpLineNumberView() {
        if font == nil {
            font = NSFont.systemFont(ofSize: 16)
        }
        if let scrollView = enclosingScrollView {
            lineNumberView = LineNumberRulerView(textView: self)
            scrollView.verticalRulerView = lineNumberView
            scrollView.hasVerticalRuler = true
            scrollView.rulersVisible = savepreferencesbool
        }
        postsFrameChangedNotifications = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(lnv_framDidChange),
                                               name: NSView.frameDidChangeNotification,
                                               object: self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(lnv_textDidChange),
                                               name: NSText.didChangeNotification,
                                               object: self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(lnv_rulersVisible),
                                               name: NSNotification.Name(
                                                            rawValue: "textView.enclosingScrollView?.rulersVisible"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(lnv_outlineViewSelectDidChange),
                                               name: NSNotification.Name(rawValue: "selectedNodeNotification"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(lnv_encodingDidChange),
                                               name: NSNotification.Name("Encoding"),
                                               object: nil)
    }
    @objc func lnv_framDidChange(notification: NSNotification) {
        lineNumberView?.needsDisplay = true
    }
    @objc func lnv_textDidChange(notification: NSNotification) {
        lineNumberView?.needsDisplay = true
    }
    @objc func lnv_outlineViewSelectDidChange(notification: Notification) {
        lineNumberView?.needsDisplay = true
    }
    @objc func lnv_rulersVisible(notification: NSNotification) {
        let dic = notification.userInfo! as Dictionary
        if let scrollView = enclosingScrollView {
            lineNumberView = LineNumberRulerView(textView: self)
            scrollView.verticalRulerView = lineNumberView
            scrollView.hasVerticalRuler = true
            scrollView.rulersVisible = dic["rulersvisible"]! as? Bool ?? Bool.init()
        }
        savepreferencesbool = dic["rulersvisible"]! as? Bool ?? Bool.init()
    }
    @objc func lnv_encodingDidChange(notification: Notification) {
        lineNumberView?.needsDisplay = true
    }
}

class LineNumberRulerView: NSRulerView {
    //observe the changed of font property
    var font: NSFont! {
        didSet { self.needsDisplay = true }
    }
   // var rulerViewWidth: CGFloat
    init(textView: NSTextView) {
        super.init(scrollView: textView.enclosingScrollView!, orientation: NSRulerView.Orientation.verticalRuler)
        self.font = NSFont.systemFont(ofSize: 12)
        //self.rulerViewWidth = NSFont.systemFont(ofSize: 12)
        self.clientView = textView
        self.ruleThickness = 40
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func drawHashMarksAndLabels(in rect: NSRect) {
        if let textView = self.clientView as? NSTextView {
            if let layoutManager = textView.layoutManager {
                guard
                    let textContainer = textView.textContainer
                    else { return }
                ///convert the origin
                let relativePoint = self.convert(NSPoint(x: 0, y: 0), from: textView)
                let lineNumberAttributes = [NSAttributedString.Key.font: textView.font ?? NSFont.systemFont(ofSize: 12),
                NSAttributedString.Key.foregroundColor: NSColor.gray] as [NSAttributedString.Key: Any]
                ///draw the line number on the specifying point
                let drawLineNumber = { (lineNumberString: String, yValue: CGFloat) -> Void in
                    let attributeString = NSAttributedString(string: lineNumberString, attributes: lineNumberAttributes)
                    let xValue: CGFloat = 35 - attributeString.size().width//5
                    attributeString.draw(at: NSPoint(x: xValue, y: relativePoint.y + yValue))
                }
                let visibleGlyphRange = layoutManager.glyphRange(forBoundingRect: textView.visibleRect,
                                                                 in: textContainer)
                let firstVisibleGlyphCharacterIndex = layoutManager.characterIndexForGlyph(at: visibleGlyphRange.location)
                let newLineRegex = try? NSRegularExpression(pattern: "\n", options: [])
                /// The numbers of line number
                var lineNumber = newLineRegex?.numberOfMatches(in: textView.string,
                                                               options: [],
                                                               range: NSMakeRange(0, firstVisibleGlyphCharacterIndex)) ?? 1
                lineNumber += 1
                //var digit = self.theDigitOfLineNumber(lineNumber)
                var glyphIndexForStringLine = visibleGlyphRange.location
                //go through each line of the string
                while glyphIndexForStringLine < NSMaxRange(visibleGlyphRange) {
                    ///range of current line in the string.
                    let characterRangeForStringline = (textView.string as NSString).lineRange(
                        for: NSMakeRange(layoutManager.characterIndexForGlyph(
                            at: glyphIndexForStringLine), 0))
                    let glyphRangeForStringLine = layoutManager.glyphRange(forCharacterRange:
                                                                                characterRangeForStringline,
                                                                           actualCharacterRange: nil)
                    var glyphIndexForGlyphLine = glyphIndexForStringLine
                    var glyphLineCount = 0
                    while glyphIndexForGlyphLine < NSMaxRange(glyphRangeForStringLine) {
                        var effectiveRange = NSMakeRange(0, 0)
                        let lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndexForGlyphLine,
                                                                      effectiveRange: &effectiveRange,
                                                                      withoutAdditionalLayout: true)
                        if glyphLineCount > 0 {
                            drawLineNumber("-", lineRect.minY)
                        } else {
                            drawLineNumber("\(lineNumber)", lineRect.minY)
                        }
                        //move to next glyph line
                        glyphLineCount += 1
                        glyphIndexForGlyphLine = NSMaxRange(effectiveRange)
                    }
                    glyphIndexForStringLine = NSMaxRange(glyphRangeForStringLine)
                    lineNumber += 1
                }
                ///calcute the digit of lineNumber
//                digit = self.theDigitOfLineNumber(lineNumber)
//                let attributeString = NSAttributedString(string: "8", attributes: lineNumberAttributes)
//                self.ruleThickness = (CGFloat(digit) * attributeString.size().width) + 10
                //self.ruleThickness = (1 * attributeString.size().width) + 5
                // Draw line number for the extra line at the end of the text
                if layoutManager.extraLineFragmentTextContainer != nil {
                    drawLineNumber("\(lineNumber)", layoutManager.extraLineFragmentRect.minY)
                }
            }
        }
    }
    func theDigitOfLineNumber(_ number: Int) -> Int {
        var digit: Int = 1
        var integer = number
        if (integer / 10) == 0 {
            return 1
        } else {
            while integer >= 10 {
                integer = (integer / 10)
                digit += 1
            }
            return digit
        }
    }
}
