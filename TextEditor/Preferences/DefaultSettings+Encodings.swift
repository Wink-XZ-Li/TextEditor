//
//  DefaultSettings+Encodings.swift
//  TextEditor
//
//  Created by X2000307 on 2020/10/10.
//  Copyright © 2020 Bernie. All rights reserved.
//

import Cocoa
import CoreFoundation.CFString

struct DefaultSettings {
    static let encodings: [UInt32] = [
        CFStringBuiltInEncodings.UTF8,  // Unicode (UTF-8)

        CFStringEncodings.shiftJIS,        // Japanese (Shift JIS)
        CFStringEncodings.EUC_JP,          // Japanese (EUC)
        CFStringEncodings.dosJapanese,     // Japanese (Windows, DOS)
        CFStringEncodings.shiftJIS_X0213,  // Japanese (Shift JIS X0213)
        CFStringEncodings.macJapanese,     // Japanese (Mac OS)
        CFStringEncodings.ISO_2022_JP,     // Japanese (ISO 2022-JP)
        CFStringBuiltInEncodings.macRoman,       // Western (Mac OS Roman)
        CFStringBuiltInEncodings.windowsLatin1,  // Western (Windows Latin 1)
        CFStringEncodings.GB_18030_2000,      // Chinese (GB18030)
        CFStringEncodings.big5_HKSCS_1999,    // Traditional Chinese (Big 5 HKSCS)
        CFStringEncodings.big5_E,             // Traditional Chinese (Big 5-E)
        CFStringEncodings.big5,               // Traditional Chinese (Big 5)
        CFStringEncodings.macChineseTrad,     // Traditional Chinese (Mac OS)
        CFStringEncodings.macChineseSimp,     // Simplified Chinese (Mac OS)
        CFStringEncodings.EUC_TW,             // Traditional Chinese (EUC)
        CFStringEncodings.EUC_CN,             // Simplified Chinese (EUC)
        CFStringEncodings.dosChineseTrad,     // Traditional Chinese (Windows, DOS)
        CFStringEncodings.dosChineseSimplif,  // Simplified Chinese (Windows, DOS)
        CFStringEncodings.macKorean,  // Korean (Mac OS)
        CFStringEncodings.EUC_KR,     // Korean (EUC)
        CFStringEncodings.dosKorean,  // Korean (Windows, DOS)
        CFStringEncodings.dosThai,       // Thai (Windows, DOS)
        CFStringEncodings.isoLatinThai,  // Thai (ISO 8859-11)
        CFStringEncodings.macArabic,           // Arabic (Mac OS)
        CFStringEncodings.isoLatinArabic,      // Arabic (ISO 8859-6)
        CFStringEncodings.windowsArabic,       // Arabic (Windows)
        CFStringEncodings.macGreek,            // Greek (Mac OS)
        CFStringEncodings.isoLatinGreek,       // Greek (ISO 8859-7)
        CFStringEncodings.windowsGreek,        // Greek (Windows)
        CFStringEncodings.macHebrew,           // Hebrew (Mac OS)
        CFStringEncodings.isoLatinHebrew,      // Hebrew (ISO 8859-8)
        CFStringEncodings.windowsHebrew,       // Hebrew (Windows)
        CFStringEncodings.macCyrillic,         // Cyrillic (Mac OS)
        CFStringEncodings.isoLatinCyrillic,    // Cyrillic (ISO 8859-5)
        CFStringEncodings.windowsCyrillic,     // Cyrillic (Windows)
        CFStringEncodings.macCentralEurRoman,  // Central European (Mac OS)
        CFStringEncodings.macTurkish,          // Turkish (Mac OS)
        CFStringEncodings.macIcelandic,        // Icelandic (Mac OS)
        CFStringBuiltInEncodings.isoLatin1,  // Western (ISO Latin 1)
        CFStringEncodings.isoLatin2,         // Central European (ISO Latin 2)
        CFStringEncodings.isoLatin3,         // Western (ISO Latin 3)
        CFStringEncodings.isoLatin4,         // Central European (ISO Latin 4)
        CFStringEncodings.isoLatin5,         // Turkish (ISO Latin 5)
        CFStringEncodings.isoLatin6,         // Nordic (ISO Latin 6)
        CFStringEncodings.isoLatin7,         // Baltic (ISO Latin 7)
        CFStringEncodings.isoLatin8,         // Celtic (ISO Latin 8)
        CFStringEncodings.isoLatin9,         // Western (ISO Latin 9)
        CFStringEncodings.isoLatin10,        // Romanian (ISO Latin 10)
        CFStringEncodings.dosLatinUS,            // Latin-US (DOS)
        CFStringEncodings.windowsLatin2,         // Central European (Windows Latin 2)
        CFStringBuiltInEncodings.nextStepLatin,  // Western (NextStep)
        CFStringBuiltInEncodings.ASCII,          // Western (ASCII)
        CFStringBuiltInEncodings.nonLossyASCII,  // Non-lossy ASCII
        CFStringBuiltInEncodings.UTF16,    // Unicode (UTF-16)
        CFStringBuiltInEncodings.UTF16BE,  // Unicode (UTF-16BE)
        CFStringBuiltInEncodings.UTF16LE,  // Unicode (UTF-16LE)
        CFStringBuiltInEncodings.UTF32,    // Unicode (UTF-32)
        CFStringBuiltInEncodings.UTF32BE,  // Unicode (UTF-32BE)
        CFStringBuiltInEncodings.UTF32LE  // Unicode (UTF-16LE)
        ]
        .map { encoding in
            switch encoding {
            case let encoding as CFStringBuiltInEncodings:
                    return encoding.rawValue
            case let encoding as CFStringEncodings:
                    return UInt32(encoding.rawValue)
//            case let encoding as UInt32 where encoding == kCFStringEncodingInvalidId:
//                    return encoding
            default:
                    preconditionFailure()
            }
        }
}
