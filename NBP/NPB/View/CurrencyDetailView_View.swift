//
//  CurrencyDetailViewControllerView.swift
//  NBP
//
//  Created by Paweł Brzozowski on 16/01/2022.
//

import UIKit
import Charts

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

// MARK: - Setup Chart
extension CurrencyDetailViewController {
    // Load data to the chart
    func setChartData() {
        // Create a variable that stores entries
        var entries = [ChartDataEntry]()

        // Create an entry. For x use, simply number from 0 to make it more readable
        var index:Double = 1.0
        for singleRate in currencyTimelineArray {
            entries.append(ChartDataEntry(x: index, y: singleRate.mid))
            index += 1
        }

        // Set of data, also add label that this chart represents the price of a specific currency
        let set = LineChartDataSet(entries: entries, label: "Price of \(currencyToDisplay!.code)")

        // Remove circles form data on the chart
        set.drawCirclesEnabled = false
        
        // Smooth out edges of set
        // set.mode = .cubicBezier
        
        // Set line width
        set.lineWidth = 2
        
        // Set set color to white
        set.setColor(.white)
        set.drawHorizontalHighlightIndicatorEnabled = false
        
        // Set fill under the line
        set.fill = Fill(color: .white)
        set.fillAlpha = 0.75
        set.drawFilledEnabled = true
        
        // Create a data from set
        let data = LineChartData(dataSet: set)
        
        // Remove value labels
        data.setDrawValues(false)
        
        // Add data to the chart
        lineChart.data = data
    }
}

// MARK: - Main range label
extension CurrencyDetailViewController {
    // The function responsible for updating range label on top of the screen.
    func setNewRangeLabelText(firstDate date1: String, secondDate date2: String) {
        rangeLabel.text = "Price from "+date1+" to "+date2
    }
}


// MARK: - tableView functions
extension CurrencyDetailViewController: UITableViewDelegate, UITableViewDataSource {
    // How many cells should be created
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyTimelineArray.count
    }
    
    // Populate tableView with cell
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
