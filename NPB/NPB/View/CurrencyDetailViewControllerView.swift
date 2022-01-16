//
//  CurrencyDetailViewControllerView.swift
//  NPB
//
//  Created by Paweł Brzozowski on 16/01/2022.
//

import UIKit

// MARK: - FloatingButton
extension CurrencyDetailViewController {
    // Create a floating button that allows to pick a new range
    func configureFloatingButton() {
        floatingButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        floatingButton.backgroundColor = .systemBlue
        let img =  UIImage(systemName: "calendar.badge.plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: UIImage.SymbolWeight.medium))
        
        floatingButton.setImage(img, for: .normal)
        floatingButton.tintColor = .white
        floatingButton.setTitleColor(UIColor.white, for: .normal)
        
        floatingButton.layer.shadowRadius = 10
        floatingButton.layer.shadowOpacity = 0.3
        
        floatingButton.layer.masksToBounds = true
        floatingButton.layer.cornerRadius = 30
    }
}

// MARK: - Main range label
extension CurrencyDetailViewController {
    
    // Function responsible for updating range label on top of the screen.
    func setNewRangeLabelText(firstDate date1: String, secondDate date2: String) {
        rangeLabel.text = "Price from "+date1+" to "+date2
    }
}


// MARK: - tableView functions
extension CurrencyDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyTimelineArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "RateCell", for: indexPath) as! DetailTableViewCell
        
        // Get the data needed to display
        let curentRate = currencyTimelineArray[indexPath.row]
        
        // Cusotmize cell
        cell.configureCell(curentRate: curentRate, numberOfRate: indexPath.row)
        
        // return the cell
        return cell
    }
    
}
