//
//  CurrencyTableViewCell.swift
//  NPB
//
//  Created by Paweł Brzozowski on 13/01/2022.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {

    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var averageRateLabel: UILabel!
    @IBOutlet weak var date1Label: UILabel!
    @IBOutlet weak var date2Label: UILabel!
    @IBOutlet weak var cellBackgroundView: UIView!
    
    
    // Storing data abour currency to dispaly
    var currencyToDisplay: currencyModel?
    // Storing data about date of dowloading
    var dateOfDownloading: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Configure cell to display it properly.
    func displayCurrencyCell(curentCurrency currency: currencyModel, downloadDate date: String, segmentedControlIndex segmentedControlIndex: Int) {
        // Clean up the cell before displaing next currency! Because cells are reusable
        cleanUpOutlets()
        
        // Keep a refrence of the currency
        currencyToDisplay =  currency
        
        // Set the main CODE of currency, ex United States Dolar -> USD
        codeLabel.text = currencyToDisplay?.code
        codeLabel.alpha = 1
        
        // Set the currencyLabel, ex USD -> "dolar amerykański"
        currencyLabel.text = currencyToDisplay?.currency
        currencyLabel.alpha = 1
        
        // Set up rest of the cell depending on whether it is type A / B or C
        if segmentedControlIndex == 0 || segmentedControlIndex == 1{
            print("Cell type A or B")
            averageRateLabel.text = String(format: "%f", currencyToDisplay!.mid!)
            averageRateLabel.alpha = 1
            
            if let dateOfDownloading = dateOfDownloading {
                print("DATE WORKING")
                date1Label.text = dateOfDownloading
                date1Label.alpha = 1
            }
            
        } else {
            print("Cell type C")
            // Here averageRateLabel is ask price and date1 is bid price. The dtae is shown via date2 label
            averageRateLabel.text = String(format: "%f", currencyToDisplay!.ask!)
            averageRateLabel.alpha = 1
            
            date1Label.text = String(format: "%f", currencyToDisplay!.bid!)
            date1Label.alpha = 1
            
            if let dateOfDownloading = dateOfDownloading {
                date2Label.text = dateOfDownloading
                date2Label.alpha = 1
            }
        }
    }
    
    // FUnction requaired to clean up outlets because it's reusable cell.
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
    }

}
