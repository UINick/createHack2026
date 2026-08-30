//
//  Item.swift
//  ScrollVerses
//
//  Created by Nicholas Forte on 29/08/26.
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
