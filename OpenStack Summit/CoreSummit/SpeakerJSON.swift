//
//  PresentationSpeakerJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import JSON

public extension Speaker {
    
    enum JSONKey: String {
        
        case id, first_name, last_name, email, title, bio, irc, twitter, pic, affiliations
    }
}

extension Speaker: JSONDecodable {
    
    public init?(json JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.integerValue,
            let firstName = JSONObject[JSONKey.first_name.rawValue]?.rawValue as? String,
            let lastName = JSONObject[JSONKey.last_name.rawValue]?.rawValue as? String,
            let picture = JSONObject[JSONKey.pic.rawValue]?.urlValue
            else { return nil }
        
        self.identifier = identifier
        self.firstName = firstName
        self.lastName = lastName
        self.picture = picture
        
        // optional
        self.title = JSONObject[JSONKey.title.rawValue]?.rawValue as? String
        self.biography = JSONObject[JSONKey.bio.rawValue]?.rawValue as? String
        self.irc = JSONObject[JSONKey.irc.rawValue]?.rawValue as? String
        self.twitter = JSONObject[JSONKey.twitter.rawValue]?.rawValue as? String
        
        if let affiliationsJSONArray = JSONObject[JSONKey.affiliations.rawValue]?.arrayValue {
            
            guard let affiliations = Affiliation.from(json: affiliationsJSONArray)
                else { return nil }
            
            self.affiliations = Set(affiliations)
            
        } else {
            
            self.affiliations = []
        }
    }
}
