//
//  MapitModel.swift
//  Mapit
//
//  Created by Andrea on 27/03/2019.
//  Copyright © 2019 AFL. All rights reserved.
//

import Foundation
import Firebase

struct Mapit {
    
    let latitude: Double
    let longitude: Double
    var documentId: String?
    let reportedDate: Date = Date()
    
}

extension Mapit {
    
    init?(_ snapshot: QueryDocumentSnapshot) {
        guard let latitude = snapshot["latitude"] as? Double,
            let longitude = snapshot["longitude"] as? Double else {
                return nil
        }
        
        self.latitude = latitude
        self.longitude = longitude
        self.documentId = snapshot.documentID
    }
    
    
    init(latitude: Double, longitude: Double) {
        
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension Mapit {
    
    func toDictionary() -> [String: Any] {
        return [
            "latitude": self.latitude,
            "longitude": self.longitude,
            "reportedDate": self.reportedDate.formatAsString()
        ]
    }
}
