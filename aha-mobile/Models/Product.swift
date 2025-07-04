//
//  Product.swift
//  aha-mobile
//
//  Created by Matthew Soh on 7/4/25.
//

import Foundation

struct Product: Identifiable, Decodable {
    let id: Int
    let name: String
    let description: String
    let price: Int
    let quantity: Int
}
