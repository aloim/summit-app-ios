//
//  Filter.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/22/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import CoreSummit

public enum FilterSectionType {
    
    case ActiveTalks, EventType, Track, TrackGroup, Tag, Level
}

public final class FilterSection {
    public var type : FilterSectionType!
    public var name = ""
    public var items = [FilterSectionItem]()
}

public final class FilterSectionItem {
    public var id = 0
    public var name = ""
}

public final class ScheduleFilter {
    
    // MARK: - Properties
    
    var selections = [FilterSectionType: [AnyObject]]()
    var filterSections = [FilterSection]()
    var hasToRefreshSchedule = true
    
    // MARK: - Initialization
    
    private init() { } // not public
    
    // MARK: - Private Methods
    
    private static func createSectionItem(id: Int, name: String, type: FilterSectionType) -> FilterSectionItem {
        
        let filterSectionItem = FilterSectionItem()
        
        filterSectionItem.id = id
        filterSectionItem.name = name
        
        return filterSectionItem
    }
    
    // MARK: - Methods
    
    func areAllSelectedForType(type: FilterSectionType) -> Bool {
        if (filterSections.count == 0) {
            return false
        }
        let filterSection = filterSections.filter() { $0.type == type }.first!
        return filterSection.items.count == selections[type]?.count
    }
    
    func hasActiveFilters() -> Bool {
        var hasActiveFilters = false
        for values in selections.values {
            if values.count > 0 {
                hasActiveFilters = true
                break
            }
        }
        return hasActiveFilters
    }
    
    func clearActiveFilters() {
        for key in selections.keys {
            selections[key] = []
        }
    }
    
    func shoudHidePastTalks() -> Bool {
        var hidePastTalks = false
        
        if let activeTalks = selections[FilterSectionType.ActiveTalks] as? [String] {
            if activeTalks.contains("Hide Past Talks") {
                hidePastTalks = true
            }
        }
        
        return hidePastTalks
    }
}

public extension ScheduleFilter {
    
    static var `default`: ScheduleFilter {
        
        let scheduleFilter = ScheduleFilter()
        
        let eventTypes = EventType.from(realm: Store.shared.realm.objects(RealmEventType).sort({ $0.name < $1.name }))
        let summitTrackGroups = TrackGroup.from(realm: Store.shared.realm.objects(RealmTrackGroup).sort({ $0.name < $1.name }))
        let levels = Array(Set(Store.shared.realm.objects(RealmPresentation).map({ $0.level }))).sort()
        
        var filterSectionItem: FilterSectionItem
        var filterSection: FilterSection
        
        filterSection = FilterSection()
        filterSection.type = FilterSectionType.ActiveTalks
        filterSection.name = "ACTIVE TALKS"
        let activeTalksFilters = ["Hide Past Talks"]
        
        if let summit = Summit.from(realm: Store.shared.realm.objects(RealmSummit)).first {
            
            let summitTimeZoneOffset = NSTimeZone(name: summit.timeZone)!.secondsFromGMT
            
            let startDate = summit.start.toFoundation().mt_dateSecondsAfter(summitTimeZoneOffset).mt_startOfCurrentDay()
            let endDate = summit.end.toFoundation().mt_dateSecondsAfter(summitTimeZoneOffset).mt_dateDaysAfter(1)
            let now = NSDate()
            
            if now.mt_isBetweenDate(startDate, andDate: endDate) {
                
                for activeTalkFilter in activeTalksFilters {
                    
                    filterSectionItem = createSectionItem(0, name: activeTalkFilter, type: filterSection.type)
                    filterSection.items.append(filterSectionItem)
                }
                
                scheduleFilter.selections[FilterSectionType.ActiveTalks] = activeTalksFilters
            }
        }
        
        scheduleFilter.filterSections.append(filterSection)
        
        filterSection = FilterSection()
        filterSection.type = FilterSectionType.TrackGroup
        filterSection.name = "SUMMIT CATEGORY"
        
        for trackGroup in summitTrackGroups {
            
            filterSectionItem = createSectionItem(trackGroup.identifier, name: trackGroup.name, type: filterSection.type)
            filterSection.items.append(filterSectionItem)
        }
        
        scheduleFilter.filterSections.append(filterSection)
        scheduleFilter.selections[FilterSectionType.TrackGroup] = [Int]()
        
        
        filterSection = FilterSection()
        filterSection.type = FilterSectionType.EventType
        filterSection.name = "EVENT TYPE"
        
        for eventType in eventTypes {
            
            filterSectionItem = createSectionItem(eventType.identifier, name: eventType.name, type: filterSection.type)
            filterSection.items.append(filterSectionItem)
        }
        
        scheduleFilter.filterSections.append(filterSection)
        scheduleFilter.selections[FilterSectionType.EventType] = [Int]()
        
        
        filterSection = FilterSection()
        filterSection.type = FilterSectionType.Level
        filterSection.name = "LEVEL"
        
        for level in levels {
            
            filterSectionItem = createSectionItem(0, name: level, type: filterSection.type)
            filterSection.items.append(filterSectionItem)
        }
        
        scheduleFilter.filterSections.append(filterSection)
        scheduleFilter.selections[FilterSectionType.Level] = [String]()
        
        scheduleFilter.selections[FilterSectionType.Tag] = [Int]()
        
        return scheduleFilter
    }
}
