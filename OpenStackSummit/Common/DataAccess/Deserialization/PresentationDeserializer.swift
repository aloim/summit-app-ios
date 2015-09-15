//
//  Presentation.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/17/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class PresentationDeserializer: NSObject, IDeserializer {
    var deserializerFactory: DeserializerFactory!
    
    public func deserialize(json: JSON) -> BaseEntity {
        let presentation = Presentation()
        presentation.id = json["id"].intValue
        
        var deserializer = deserializerFactory.create(DeserializerFactories.Track)
        let track = deserializer.deserialize(json["track_id"]) as! Track
        presentation.track = track
        
        deserializer = deserializerFactory.create(DeserializerFactories.Member)
        var speaker : Member
        for (_, memberJSON) in json["speakers"] {
            speaker = deserializer.deserialize(memberJSON) as! Member
            presentation.speakers.append(speaker)
        }
        
        deserializer = deserializerFactory.create(DeserializerFactories.Tag)
        var tag : Tag
        for (_, tagsJSON) in json["tags"] {
            tag = deserializer.deserialize(tagsJSON) as! Tag
            presentation.tags.append(tag)
        }
        
        return presentation
    }
}
