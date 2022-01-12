//
//  Models.swift
//  NPB
//
//  Created by Paweł Brzozowski on 12/01/2022.
//

import Foundation

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
}
