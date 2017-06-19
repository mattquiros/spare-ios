//
//  DateFormatter.swift
//  Spare
//
//  Created by Matt Quiros on 04/07/2016.
//  Copyright © 2016 Matt Quiros. All rights reserved.
//

import Foundation
import Mold

private let kSharedFormatter: Foundation.DateFormatter = {
    let formatter = Foundation.DateFormatter()
    formatter.timeZone = TimeZone.autoupdatingCurrent
    return formatter
}()

class DateFormatter {
    
    class func displayTextForExpenseEditorDate(_ date: Date?) -> String {
        guard let date = date
            else {
                return ""
        }
        
        kSharedFormatter.dateFormat = "EEE, d MMM yyyy"
        
        let currentDate = Date()
        if date.isSameDayAsDate(currentDate) {
            kSharedFormatter.dateFormat = "d MMM yyyy"
            return "Today, " + kSharedFormatter.string(from: date)
        }
        return kSharedFormatter.string(from: date)
    }
    
    class func displayText(for dateRange: DateRange) -> String {
        let currentDate = Date()
        
        switch App.selectedPeriodization {
        case .day:
            if dateRange.start.isSameDayAsDate(currentDate) {
                kSharedFormatter.dateFormat = "'Today,' MMM d"
            } else {
                kSharedFormatter.dateFormat = "EEE, MMM d"
            }
            return kSharedFormatter.string(from: dateRange.start)
            
        case .week:
            if dateRange.start.isSameWeekAsDate(Date(), whenFirstWeekdayIs: App.selectedStartOfWeek.rawValue) {
                return "This week"
            } else {
                let formatter = kSharedFormatter
                switch (dateRange.start.isSameYearAsDate(currentDate), dateRange.end.isSameYearAsDate(currentDate)) {
                case (true, true):
                    formatter.dateFormat = "MMM d"
                    
                default:
                    formatter.dateFormat = "MMM d ''yy"
                }
                return "\(formatter.string(from: dateRange.start)) to \(formatter.string(from: dateRange.end))"
            }
            
        case .month:
            if dateRange.start.isSameMonthAsDate(currentDate) {
                return "This month"
            }
            
            let formatter = kSharedFormatter
            formatter.dateFormat = "MMM yyyy"
            return formatter.string(from: dateRange.start)
            
        case .year:
            if dateRange.start.isSameYearAsDate(currentDate) {
                return "This year"
            }
            
            let formatter = kSharedFormatter
            formatter.dateFormat = "yyyy"
            return formatter.string(from: dateRange.start)
        }
    }
    
}