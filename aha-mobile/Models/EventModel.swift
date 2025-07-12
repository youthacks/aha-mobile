//
//  EventModel.swift
//  aha-mobile
//
//  Created by Matthew Soh on 7/7/25.
//

import Foundation

struct Event: Identifiable, Decodable {
    var id: String { slug }
    let name: String
    let description: String
    let date: String
    let slug: String
}
