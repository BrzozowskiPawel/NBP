//
//  Models.swift
//  NBP
//
//  Created by Paweł Brzozowski on 12/01/2022.
//

import Foundation

// Strucutres requaired to parse JSON from tables
struct APIData: Codable{
    let table: String
    let no: String
    let effectiveDate: String
    let rates: [currencyModel]
}

struct currencyModel: Codable {
    let currency: String
    let code: String
    let mid: Double?
    let bid: Double?
    let ask: Double?
}

// Strucutres fof detail view. Parsing a JSON from rates
struct APIDataTimeline: Codable{
    let table: String
    let currency: String
    let code: String
    let rates: [timelineRate]
}

struct timelineRate: Codable {
    let no: String
    let effectiveDate: String
    let mid: Double
}
