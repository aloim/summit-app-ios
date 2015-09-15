//
//  SummitDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//
import UIKit
import SwiftyJSON

public class SummitDeserializer: NSObject, IDeserializer {
    var deserializerStorage: DeserializerStorage!
    var deserializerFactory: DeserializerFactory!
    
    public init(deserializerStorage: DeserializerStorage, deserializerFactory: DeserializerFactory) {
        self.deserializerStorage = deserializerStorage
        self.deserializerFactory = deserializerFactory
    }

    public override init() {
        super.init()
    }
    
    public func deserialize(json : JSON) -> BaseEntity {
        let summit = Summit()
        var deserializer : IDeserializer!
        
        deserializer = deserializerFactory.create(DeserializerFactories.Company)
        for (_, companyJSON) in json["sponsors"] {
            deserializer.deserialize(companyJSON)
        }
        
        deserializer = deserializerFactory.create(DeserializerFactories.SummitType)
        var summitType : SummitType
        for (_, summitTypeJSON) in json["summit_types"] {
            summitType = deserializer.deserialize(summitTypeJSON) as! SummitType
            summit.types.append(summitType)
        }
        
        deserializer = deserializerFactory.create(DeserializerFactories.EventType)
        for (_, eventTypeJSON) in json["event_types"] {
            deserializer.deserialize(eventTypeJSON)
        }
        
        deserializer = deserializerFactory.create(DeserializerFactories.Track)
        for (_, presentationCategoryJSON) in json["presentation_categories"] {
            deserializer.deserialize(presentationCategoryJSON)
        }

        deserializer = deserializerFactory.create(DeserializerFactories.Venue)
        var venue: Venue
        for (_, venueJSON) in json["locations"] {
            venue = deserializer.deserialize(venueJSON) as! Venue
            summit.venues.append(venue)
        }
        
        var event : SummitEvent
        for (_, eventJSON) in json["schedule"] {

            deserializer = deserializerFactory.create(DeserializerFactories.SummitEvent)
            event = deserializer.deserialize(eventJSON) as! SummitEvent
            
            summit.events.append(event)
        }
        
        summit.name = json["name"].stringValue
        summit.id = json["id"].intValue
        summit.startDate = NSDate(timeIntervalSince1970: NSTimeInterval(json["start_date"].intValue))
        summit.endDate = NSDate(timeIntervalSince1970: NSTimeInterval(json["end_date"].intValue))
        return summit

    }
}
