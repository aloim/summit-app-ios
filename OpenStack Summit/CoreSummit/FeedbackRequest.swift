//
//  EventFeedbackRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 7/12/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import AeroGearHttp
import AeroGearOAuth2

public extension Store {
    
    func feedback(_ summit: Identifier, event: Identifier, page: Int, objectsPerPage: Int, completion: (ErrorValue<Page<Feedback>>) -> ()) {
        
        let URI = "/api/v1/summits/\(summit)/events/\(event)/feedback?expand=owner&page=\(page)&per_page=\(objectsPerPage)"
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.serviceAccount)
        
        let context = privateQueueManagedObjectContext
        
        http.GET(URL) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.error(error!)); return }
            
            guard let json = try? JSON.Value(string: responseObject as! String),
                let page = Page<Feedback>(json: json)
                else { completion(.error(Error.invalidResponse)); return }
            
            // cache
            try! context.performErrorBlockAndWait {
                
                // only cache if event exists
                guard let _ = try EventManagedObject.find(event, context: context)
                    else { return }
                
                try page.items.save(context)
                
                try context.validateAndSave()
            }
            
            // success
            completion(.value(page))
        }
    }
    
    func averageFeedback(_ summit: Identifier, event: Identifier, completion: (ErrorValue<Double>) -> ()) {
        
        let URI = "/api/v1/summits/\(summit)/events/\(event)/published?fields=id,avg_feedback_rate&relations=none"
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.serviceAccount)
        
        let context = privateQueueManagedObjectContext
        
        http.GET(URL) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.error(error!)); return }
            
            guard let json = try? JSON.Value(string: responseObject as! String),
                let jsonObject = json.objectValue,
                let averageFeedbackJSON = jsonObject[Event.JSONKey.avg_feedback_rate.rawValue]
                else { completion(.error(Error.invalidResponse)); return }
            
            let averageFeedback: Double
            
            if let doubleValue = averageFeedbackJSON.rawValue as? Double {
                
                averageFeedback = doubleValue
                
            } else if let integerValue = averageFeedbackJSON.rawValue as? Int {
                
                averageFeedback = Double(integerValue)
                
            } else {
                
                completion(.error(Error.invalidResponse)); return
            }
                        
            // update cache
            try! context.performErrorBlockAndWait {
                
                if let managedObject = try EventManagedObject.find(event, context: context) {
                    
                    managedObject.averageFeedback = averageFeedback
                    
                    try context.save()
                }
            }
            
            // success
            completion(.value(averageFeedback))
        }
    }
    
    func addFeedback(_ summit: Identifier, event: Identifier, rate: Int, review: String, completion: (ErrorValue<Identifier>) -> ()) {
        
        let URI = "/api/v2/summits/\(summit)/events/\(event)/feedback"
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.openIDJSON)
        
        var jsonDictionary = [String: AnyObject]()
        jsonDictionary["rate"] = rate
        jsonDictionary["note"] = review
        
        let context = privateQueueManagedObjectContext
        
        http.POST(URL, parameters: jsonDictionary) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.error(error!)); return }
            
            let identifier = Int(responseObject as! String)!
            
            // create new feedback in cache
            try! context.performErrorBlockAndWait {
                
                if let memberManagedObject = try self.authenticatedMember(context) {
                    
                    let member = Member(managedObject: memberManagedObject)
                    
                    let feedback = Feedback(identifier: identifier, rate: rate, review: review, date: Date(), event: event, member: member)
                    
                    let managedObject = try feedback.save(context)
                    
                    memberManagedObject.feedback.insert(managedObject)
                    
                    try context.validateAndSave()
                }
            }
            
            completion(.value(identifier))
        }
    }
    
    func editFeedback(_ summit: Identifier, event: Identifier, rate: Int, review: String, completion: (Swift.Error?) -> ()) {
        
        let URI = "/api/v2/summits/\(summit)/events/\(event)/feedback"
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.openIDJSON)
        
        var jsonDictionary = [String: AnyObject]()
        jsonDictionary["rate"] = rate
        jsonDictionary["note"] = review
        
        let context = privateQueueManagedObjectContext
        
        http.PUT(URL, parameters: jsonDictionary) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(error!); return }
            
            // create new feedback in cache
            try! context.performErrorBlockAndWait {
                
                if let member = try self.authenticatedMember(context),
                    let feedback = member.feedback(for: event) {
                    
                    feedback.rate = Int16(rate)
                    
                    feedback.review = review
                    
                    try context.save()
                }
            }
            
            completion(nil)
        }
    }
}
