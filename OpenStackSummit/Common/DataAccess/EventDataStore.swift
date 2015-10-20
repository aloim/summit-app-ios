//
//  EventDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/28/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IEventDataStore {
    func getByIdLocal(id: Int) -> SummitEvent?
    func getByFilterLocal(startDate: NSDate, endDate: NSDate, eventTypes: [Int]?, summitTypes: [Int]?, tracks: [Int]?)->[SummitEvent]
    func getFeedback(eventId: Int, page: Int, objectsPerPage: Int, completionBlock : ([Feedback]?, NSError?) -> Void)
}

public class EventDataStore: GenericDataStore, IEventDataStore {
    var eventRemoteDataStore: IEventRemoteDataStore!
    
    public override init() {
        super.init()
    }
    
    public func getByIdLocal(id: Int) -> SummitEvent? {
        return super.getByIdLocal(id)
    }
    
    public func getByFilterLocal(startDate: NSDate, endDate: NSDate, eventTypes: [Int]?, summitTypes: [Int]?, tracks: [Int]?)->[SummitEvent]{
        var events = realm.objects(SummitEvent).filter("start >= %@ and end <= %@", startDate, endDate).sorted("start")
        if (eventTypes != nil && eventTypes!.count > 0) {
            events = events.filter("eventType.id in %@", eventTypes!)
        }
        if (tracks != nil && tracks!.count > 0) {
            events = events.filter("presentation.track.id in %@", tracks!)
        }

        var eventArray = events.map{$0}
        if (summitTypes != nil) {
            eventArray = eventArray.filter() {
                for summitTypeId in summitTypes! {
                    print($0.summitTypes.map{$0.id})
                    guard ($0.summitTypes.map{$0.id}.contains(summitTypeId)) else {
                        return false
                    }
                }
                return true
            }
        }
    
        return eventArray
    }
    
    public func getFeedback(eventId: Int, page: Int, objectsPerPage: Int, completionBlock : ([Feedback]?, NSError?) -> Void) {
        eventRemoteDataStore.getFeedbackForEvent(eventId, page: page, objectsPerPage: objectsPerPage, completionBlock: completionBlock)
    }
}
