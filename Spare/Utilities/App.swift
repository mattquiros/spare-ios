//
//  App.swift
//  Spare
//
//  Created by Matt Quiros on 20/04/2016.
//  Copyright © 2016 Matt Quiros. All rights reserved.
//

import UIKit
import BNRCoreDataStack

private let kSharedState = App()

private enum SettingKey: String {
    case SelectedPeriodization = "Settings-SelectedPeriodization"
    case SelectedStartOfWeek = "Settings-SelectedStartOfWeek"
}

class App {
    
    class var state: App {
        return kSharedState
    }
    
    private init() {}
    
    var coreDataStack: CoreDataStack!
    
    static var mainQueueContext: NSManagedObjectContext {
        return kSharedState.coreDataStack.mainQueueContext
    }
    
    var selectedPeriodization: Periodization {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            if let rawValue = defaults.valueForKey(SettingKey.SelectedPeriodization.rawValue) as? Int,
                let periodization = Periodization(rawValue: rawValue) {
                return periodization
            } else {
                defaults.setValue(Periodization.Day.rawValue, forKey: SettingKey.SelectedPeriodization.rawValue)
                defaults.synchronize()
                return .Day
            }
        }
        set {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setValue(newValue.rawValue, forKey: SettingKey.SelectedPeriodization.rawValue)
            defaults.synchronize()
        }
    }
    
    var selectedStartOfWeek: StartOfWeek {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            if let rawValue = defaults.valueForKey(SettingKey.SelectedPeriodization.rawValue) as? Int,
                let startOfWeek = StartOfWeek(rawValue: rawValue) {
                return startOfWeek
            } else {
                defaults.setValue(StartOfWeek.Sunday.rawValue, forKey: SettingKey.SelectedStartOfWeek.rawValue)
                defaults.synchronize()
                return .Sunday
            }
        }
        set {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setValue(newValue.rawValue, forKey: SettingKey.SelectedStartOfWeek.rawValue)
            defaults.synchronize()
        }
    }
    
}