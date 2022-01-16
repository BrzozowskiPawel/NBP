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

}
