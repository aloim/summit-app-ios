//
//  CompanyDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/15/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class CompanyDeserializer: NamedEntityDeserializer, IDeserializer {
    var deserializerStorage: DeserializerStorage!
    
    public func deserialize(json : JSON) throws -> RealmEntity {
        let company : Company
        
        if let companyId = json.int {
            guard let check: Company = deserializerStorage.get(companyId) else {
                throw DeserializerError.EntityNotFound("Company with id \(companyId) not found on deserializer storage")
            }
            company = check
        }
        else {
            company = super.deserialize(json) as Company
            if(!deserializerStorage.exist(company)) {
                deserializerStorage.add(company)
            }
        }
        
        return company
    }
}