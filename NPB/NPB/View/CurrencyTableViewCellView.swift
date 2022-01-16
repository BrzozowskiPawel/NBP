//
//  CurrencyTableViewCellView.swift
//  NPB
//
//  Created by Paweł Brzozowski on 16/01/2022.
//

import Foundation

extension CurrencyTableViewCell {
    // Configure cell to display it properly.
    func displayCurrencyCell(curentCurrency currency: currencyModel, downloadDate date: String, segmentedControlIndexValue segmentedControlIndex: Int) {
        // Clean up the cell before displaing next currency! Because cells are reusable
        cleanUpOutlets()
        
        // Round corners of cellBackgroundView
        cellBackgroundView.layer.cornerRadius = 15
        
        // Keep a refrence of the currency
        currencyToDisplay = currency
        
        // Keep a refrence of the dowload date
        dateOfDownloading = date
        
        // Set the main CODE of currency, ex United States Dolar -> USD
        codeLabel.text = currencyToDisplay?.code
        codeLabel.alpha = 1
        
        // Set the currencyLabel, ex USD -> "dolar amerykański"
        currencyLabel.text = currencyToDisplay?.currency
        currencyLabel.alpha = 1
        
        // Set up rest of the cell depending on whether it is type A / B or C
        if segmentedControlIndex == 0 || segmentedControlIndex == 1{
            averageRateLabel.text = String(format: "%0.4f", currencyToDisplay!.mid!) + " PLN"
            averageRateLabel.alpha = 1
            
            if let dateOfDownloading = dateOfDownloading {
                date1Label.text = dateOfDownloading
                date1Label.alpha = 1
            }
            
        } else {
            // Here averageRateLabel is ask price and date1 is bid price. The dtae is shown via date2 label
            averageRateLabel.text = "Ask: " + String(format: "%.4f", currencyToDisplay!.ask!)
            averageRateLabel.alpha = 1
            averageRateLabel.textColor = .systemRed
            
            date1Label.text = "Bid: " + String(format: "%.4f", currencyToDisplay!.bid!)
            date1Label.alpha = 1
            date1Label.textColor = .systemGreen
            
            if let dateOfDownloading = dateOfDownloading {
                date2Label.text = dateOfDownloading
                date2Label.alpha = 1
            }
        }
    }
    
    // Function requaired to clean up outlets because it's reusable cell.
    private func cleanUpOutlets() {
        codeLabel.text = ""
        currencyLabel.text = ""
        averageRateLabel.text = ""
        date1Label.text = ""
        date2Label.text = ""
        codeLabel.alpha = 0
        currencyLabel.alpha = 0
        averageRateLabel.alpha = 0
        date1Label.alpha = 0
        date2Label.alpha = 0

        averageRateLabel.textColor = .black
        date1Label.textColor = .black
    }
}
