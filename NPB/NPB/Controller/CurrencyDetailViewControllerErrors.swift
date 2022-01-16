//
//  CurrencyDetailViewControllerErrors.swift
//  NPB
//
//  Created by Paweł Brzozowski on 16/01/2022.
//

import Foundation
// Handling all kind of error that could exist when suer set wrong range.

// MARK: - Handle DETECTED type of error.
extension CurrencyDetailViewController {
    
    /*
     Both firstDate! and secondDate! are safe to force unwrap.
     This have been checked before calling function
     */
    
    // Handle error when set second date before first
    func handleRangeErrorSecodDateIsBefore() {
        // Because selected rnage is inavlid use initial values.
        useInitialDateValues()
        
        // Get first and second date as formated string
        let firstDateString = getDateAsString(DateToFormat: firstDate!, dateFormatString: "yyyy-MM-dd")
        let secondDateString = getDateAsString(DateToFormat: secondDate!, dateFormatString: "yyyy-MM-dd")
        
        // Create an allert to inform user about this error
        let alert = createCustomAllert(alertTitle: "Second date cannot be before first date.", alertMessage: "Sorry but selected range is invalid. Your first date is: \(firstDateString) and second is \(secondDateString). Please set range again.", actionTitle: "OK")
        self.present(alert, animated: true, completion: nil)
    }
    
    // Handle error when date is in futre
    func handleRangeErrorDateIsFuture() {
        // Because selected rnage is inavlid use initial values.
        useInitialDateValues()
        
        // Get first and second date as formated string
        let firstDateString = getDateAsString(DateToFormat: firstDate!, dateFormatString: "yyyy-MM-dd")
        let secondDateString = getDateAsString(DateToFormat: secondDate!, dateFormatString: "yyyy-MM-dd")
        
        // Create an allert to inform user about this error
        let alert = createCustomAllert(alertTitle: "Range cannot be in fute", alertMessage: "Sorry but selected range is invalid. Your first date is: \(firstDateString) and second is \(secondDateString). Make sure that dates arent future and select a range again.", actionTitle: "OK")
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleRangeErrorMaxRange(days numOfdays: Int) {
        // Because selected rnage is inavlid use initial values.
        useInitialDateValues()
        
        // Create an allert to inform user about this error
        let alert = createCustomAllert(alertTitle: "Max range is 93 days.", alertMessage: "Sorry but selected range is invalid. Max range is 93 days and your range was \(numOfdays)", actionTitle: "OK")
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - Detect if any kinf of error exists, if so call spefycic handler.
extension CurrencyDetailViewController {
    // Perform chaeck to make sure that dates in range is correct
    func performErrorCheck() {
        // - first date must be eariler then second date
        // - non of dates can be after current date
        // - single rnage cannot be larger than 93 days
        if secondDate! < firstDate! {
            // Handling this error
            handleRangeErrorSecodDateIsBefore()
            return
        }
        let currentDate = Date()
        if secondDate! >= currentDate || firstDate! >= currentDate {
            if secondDate! < firstDate! {
                // Handling this error
                handleRangeErrorDateIsFuture()
                return
            }
        }
        
        let days = daysBetween(start: firstDate!, end: secondDate!)
        // KEEP IN MIND THAT API DOCUMENATION SAYS THAT MAX ANGE IS 93 DAYS
        if days > 93 {
            handleRangeErrorMaxRange(days: days)
            return
        }
    }
}
