//
//  EventModel.swift
//  aha-mobile
//
//  Created by Matthew Soh on 7/7/25.
//

import Foundation

struct Event: Identifiable, Decodable {
    let id: Int
    let name: String
    let description: String
    let date: Date
    let slug: String
}
