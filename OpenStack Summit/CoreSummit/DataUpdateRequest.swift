//
//  DataUpdateRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/8/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import AeroGearHttp
import AeroGearOAuth2

public extension Store {
    
    func dataUpdates(_ summit: Identifier? = nil, latestDataUpdate: Identifier, limit: Int = 100, completion: (ErrorValue<[DataUpdate]>) -> ()) {
        
        let summitID: String
        
        if let identifier = summit {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/" + summitID + "/entity-events?limit=\(limit)&last_event_id=\(latestDataUpdate)"
        
        dataUpdates(URI, completion: completion)
    }
    
    func dataUpdates(_ summit: Identifier? = nil, from date: Date, limit: Int = 50, completion: (ErrorValue<[DataUpdate]>) -> ()) {
        
        let summitID: String
        
        if let identifier = summit {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/" + summitID + "/entity-events?limit=\(limit)&from_date=\(Int(date.timeIntervalSince1970))"
        
        dataUpdates(URI, completion: completion)
    }
}

// MARK: - Private

private extension Store {
    
    func dataUpdates(_ URI: String, completion: (ErrorValue<[DataUpdate]>) -> ()) {
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.isLoggedIn ? self.createHTTP(.openIDJSON) : self.createHTTP(.serviceAccount)
        
        http.request(method: .get, path: url) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.error(error!)); return }
            
            // parse
            guard let json = try? JSON.Value(string: responseObject as! String),
                let jsonArray = json.arrayValue,
                let dataUpdates = DataUpdate.from(json: jsonArray)
                else { completion(.error(Error.invalidResponse)); return }
            
            completion(.value(dataUpdates))
        }
    }
}
