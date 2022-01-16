//
//  Date2String.swift
//  NBP
//
//  Created by Paweł Brzozowski on 16/01/2022.
//

import Foundation

// Convert a String
func getDateAsString(DateToFormat date: Date, dateFormatString dateFormat: String) -> String {
    // Initialize the date formatter
    let formatter = DateFormatter()
    formatter.dateFormat = dateFormat

    // Return formated date
    return formatter.string(from: date)
}

// Return date that is + {x} weeks away
extension Date {
    func addWeek(noOfWeeks: Int) -> Date {
    return Calendar.current.date(byAdding: .weekOfYear, value: noOfWeeks, to: self)!
    }
}
