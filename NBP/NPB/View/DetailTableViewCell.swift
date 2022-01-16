//
//  DetailTableViewCell.swift
//  NBP
//
//  Created by Paweł Brzozowski on 15/01/2022.
//

import UIKit

class DetailTableViewCell: UITableViewCell {

    @IBOutlet weak var numberBGView: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // Keeping a reference to rate
    var rate: timelineRate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // Configure displaing of an cell
    func configureCell(curentRate rateObj: timelineRate, numberOfRate rateNo: Int){
        
        // Make backgroundView rounded
        numberBGView.layer.cornerRadius = 17
        
        // Keep a refrence to the rate
        self.rate = rateObj
        
        // Set proper cell text values to labels
        numberLabel.text = String(rateNo)
        priceLabel.text = String(format: "%0.4f", rate!.mid) + " PLN"
        dateLabel.text = rate?.effectiveDate
        
        
    }

}
