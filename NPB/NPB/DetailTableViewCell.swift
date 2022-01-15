//
//  DetailTableViewCell.swift
//  NPB
//
//  Created by Paweł Brzozowski on 15/01/2022.
//

import UIKit

class DetailTableViewCell: UITableViewCell {

    @IBOutlet weak var numberBGView: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var rate: timelineRate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(curentRate rateObj: timelineRate, numberOfRate rateNo: Int){
//        // Clean up the cell before displaing next currency! Because cells are reusable
//        cleanUpOutlets()
        
        // Make backgroundView rounded
        numberBGView.layer.cornerRadius = 15
        
        // Keep a refrence to the rate
        self.rate = rateObj
        
        numberLabel.text = String(rateNo)
        
        priceLabel.text = String(format: "%0.4f", rate!.mid) + " PLN"
        
        dateLabel.text = rate?.effectiveDate
        
        
    }
    
//    // FUnction requaired to clean up outlets because it's reusable cell.
//    private func cleanUpOutlets() {
//
//    }

}
