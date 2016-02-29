//
//  NSDateExtensions.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 04.02.16.
//  Copyright © 2016 Tomas Scavnicky. All rights reserved.
//

import Foundation


public func matchesForRegexInText(regex: String!, text: String!) -> [String] {
    
    do {
        let regex = try NSRegularExpression(pattern: regex, options: [])
        let nsString = text as NSString
        let results = regex.matchesInString(text,
            options: [], range: NSMakeRange(0, nsString.length))
        return results.map { nsString.substringWithRange($0.range)}
    } catch let error as NSError {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

public var loggedIn: Bool {
    let defaults = NSUserDefaults.standardUserDefaults()
    let tmpLoggedIn = defaults.boolForKey("loggedIn")
    return tmpLoggedIn
}


enum Class: String {
    case BIA1 = "170"
    case BIB1 = "171"
    case BIA2 = "174"
    case BIB2 = "175"
    case BIT3 = "177"
    case Osobný = "https://wis.fit.vutbr.cz/FIT/st/studyps-l.php"
    static let allValues = [BIA1.rawValue, BIB1.rawValue, BIA2.rawValue, BIB2.rawValue, BIT3.rawValue, Osobný.rawValue]
}

extension String {
    
    var html2AttributedString: NSAttributedString? {
        guard
            let data = dataUsingEncoding(NSUTF8StringEncoding)
            else { return nil }
        do {
            return try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding], documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}


extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), color.CGColor)
        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, forState: forState)
    }
}


extension NSDate {
        
    func localTime(date: NSDate = NSDate()) -> NSDate {
        return date.addHours(1)
    }
    
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        var isGreater = false
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending {
            isGreater = true
        }
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        var isLess = false
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
            isLess = true
        }
        return isLess
    }
    
    func equalToDate(dateToCompare: NSDate) -> Bool {
        var isEqualTo = false
        if self.compare(dateToCompare) == NSComparisonResult.OrderedSame {
            isEqualTo = true
        }
        return isEqualTo
    }
    
    func addDays(daysToAdd: Int) -> NSDate {
        let secondsInDays: NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: NSDate = self.dateByAddingTimeInterval(secondsInDays)
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd: Int) -> NSDate {
        let secondsInHours: NSTimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: NSDate = self.dateByAddingTimeInterval(secondsInHours)
        return dateWithHoursAdded
    }
    
    func addMinutes(minutesToAdd: Int) -> NSDate {
        let secondsInMinutes: NSTimeInterval = Double(minutesToAdd) * 60
        let dateWithMinutesAdded: NSDate = self.dateByAddingTimeInterval(secondsInMinutes)
        return dateWithMinutesAdded
    }
    
}