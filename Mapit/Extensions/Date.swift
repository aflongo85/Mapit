//
//  Date.swift
//  Mapit
//
//  Created by Andrea on 27/03/2019.
//  Copyright © 2019 AFL. All rights reserved.
//

import Foundation

extension Date {
    func formatAsString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        return dateFormatter.string(from: self)
    }
}
