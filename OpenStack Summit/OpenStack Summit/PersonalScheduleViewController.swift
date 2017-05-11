//
//  PersonalScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import CoreSummit
import Foundation

final class PersonalScheduleViewController: ScheduleViewController, IndicatorInfoProvider {
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // MARK: - Methods
    
    override func scheduleAvailableDates(from startDate: Date, to endDate: Date) -> [Date] {
        
        guard let attendeeRole = Store.shared.authenticatedMember?.attendeeRole
            else { return [] }
        
        let events = attendeeRole.schedule
            .filter({ $0.start >= startDate && $0.end <= endDate })
            .sorted(by: { $0.0.start < $0.1.start })
        
        var activeDates: [Date] = []
        for event in events {
            let timeZone = NSTimeZone(name: event.summit.timeZone)!
            let startDate = event.start.mt_dateSecondsAfter(timeZone.secondsFromGMT).mt_startOfCurrentDay()
            if !activeDates.contains(startDate) {
                activeDates.append(startDate)
            }
            
        }
        return activeDates
    }
    
    override func scheduledEvents(_ filter: DateFilter) -> [ScheduleItem] {
        
        guard let attendeeRole = Store.shared.authenticatedMember?.attendeeRole,
            case .interval(let interval) = filter
            else { return [] }
        
        let events = attendeeRole.schedule
            .filter({ $0.start >= interval.start
                && $0.end <= interval.end })
            .sorted(by: { $0.0.start < $0.1.start })
        
        return ScheduleItem.from(managedObjects: events)
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(_ pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Schedule")
    }
}
