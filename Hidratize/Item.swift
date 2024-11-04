//
//  Item.swift
//  Hidratize
//
//  Created by Saul Ramirez  on 03/11/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
