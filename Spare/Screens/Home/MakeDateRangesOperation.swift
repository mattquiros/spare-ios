//
//  MakeDateRangesOperation.swift
//  Spare
//
//  Created by Matt Quiros on 13/06/2016.
//  Copyright © 2016 Matt Quiros. All rights reserved.
//

import Foundation
import Mold
import CoreData

/**
 Makes an array of date ranges. Each date range represents a single page
 in the home screen.
 */
class MakeDateRangesOperation: MDOperation {
    
    var currentDate: Date
    var periodization: Periodization
    var startOfWeek: StartOfWeek
    var count: Int
    var pageOffset: Int
    
    /**
     - parameters:
        - currentDate: The current date, which will be the basis date of computation.
        - periodization: Defines whether summaries will be daily, weekly, monthly, or yearly.
        - startOfWeek: The user's definition of when a week starts (Saturday, Sunday, or Monday).
        - count: The number of summaries to be generated.
        - pageOffset: The number of pages to skip. Each page is assumed to have as many items as indicated in the `count` parameter.
     */
    init(currentDate: Date, periodization: Periodization, startOfWeek: StartOfWeek, count: Int, pageOffset: Int) {
        self.currentDate = currentDate
        self.periodization = periodization
        self.startOfWeek = startOfWeek
        self.count = count
        self.pageOffset = pageOffset
    }
    
    override func makeResult(fromSource source: Any?) throws -> Any? {
        var dateRanges = [DateRange]()
        for i in 0 ..< self.count {
            let dateRange = self.dateRangeForPage(self.pageOffset + i)
            dateRanges.insert(dateRange, at: 0)
            
            if self.isCancelled {
                return nil
            }
        }
        
        return dateRanges
    }
    
    func dateRangeForPage(_ page: Int) -> DateRange {
        var calendar = Calendar.current
        
        switch self.periodization {
        case .day:
            // Offset the baseDate by page, then return the start and end of day.
            let offsetDate = calendar.date(byAdding: .day, value: page * -1, to: self.currentDate)!
            return DateRange(start: offsetDate.startOfDay(), end: offsetDate.endOfDay())
            
        case .week:
            calendar.firstWeekday = self.startOfWeek.rawValue
            
            let offsetDate = calendar.date(byAdding: .weekOfYear, value: page * -1, to: self.currentDate)!
            var startDate = Date.distantPast
            var interval = TimeInterval(0)
            let _ = calendar.dateInterval(of: .weekOfYear, start: &startDate, interval: &interval, for: offsetDate)
            let endDate = startDate.addingTimeInterval(interval - 1)
            return DateRange(start: startDate.startOfDay(), end: endDate.endOfDay())
            
        case .month:
            let offsetDate = calendar.date(byAdding: .month, value: page * -1, to: self.currentDate)!
            var components = calendar.dateComponents([.month, .day, .year], from: offsetDate)
            
            components.day = 1
            let startDate = calendar.date(from: components)!
            
            let lastDayInMonth = calendar.range(of: .day, in: .month, for: offsetDate)!.upperBound - 1
            components.day = lastDayInMonth
            let endDate = calendar.date(from: components)!
            
            return DateRange(start: startDate.startOfDay(), end: endDate.endOfDay())
            
        case .year:
            let offsetDate = calendar.date(byAdding: .year, value: page * -1, to: self.currentDate)!
            var components = calendar.dateComponents([.month, .day, .year], from: offsetDate)
            
            components.month = 1
            components.day = 1
            let startDate = calendar.date(from: components)!
            
            components.month = calendar.range(of: .month, in: .year, for: offsetDate)!.upperBound
            let lastMonthInYear = calendar.date(from: components)!
            let dayRange = calendar.range(of: .day, in: .month, for: lastMonthInYear)!
            components.day = dayRange.upperBound
            let endDate = calendar.date(from: components)!
            
            return DateRange(start: startDate.startOfDay(), end: endDate.endOfDay())
        }
    }
    
}
