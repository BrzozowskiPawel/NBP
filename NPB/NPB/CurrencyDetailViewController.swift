//
//  CurrencyDetailViewController.swift
//  NPB
//
//  Created by Paweł Brzozowski on 13/01/2022.
//

import UIKit
import Charts

class CurrencyDetailViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var dateRangeLabel: UILabel!
    
    // Storing data abour currency to dispaly
    var currencyToDisplay: currencyModel?
    
    // Instance of API caller.
    let myAPICaller = APICaller()
    
    // Data dowloaded from API
    var currencyTimelineArray = [timelineRates]()
    
    // Create a chart object
    var lineChart = LineChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the title
        if let currencyToDisplay = currencyToDisplay {
            self.title = currencyToDisplay.currency
        }
        
        // Setup APIcaller
        myAPICaller.delegate = self
        
        // Dowload timeline rates
        // Create a valid string URL and perform a request.
        let stringURL = createValidURLToApi()
        myAPICaller.getData(from: stringURL)
        
        // Setup charts
        lineChart.delegate = self
        
        // Create a chart
        lineChart.frame = CGRect(x: 0, y: 0, width: chartView.frame.width, height: chartView.frame.height)
        chartView.addSubview(lineChart)
    }
    
    
    // Load data to the chart
    func loadDataToChart() {
        var entries = [ChartDataEntry]()

        var index:Double = 1.0
        for singleRate in currencyTimelineArray {
            entries.append(ChartDataEntry(x: index, y: singleRate.mid))
            index += 1
        }

        let set = LineChartDataSet(entries: entries)
        set.colors = ChartColorTemplates.material()
        let data = LineChartData(dataSet: set)
        lineChart.data = data
    }
    
    func createValidURLToApi() -> String{
        if let currencyToDisplay = currencyToDisplay {
            return "https://api.nbp.pl/api/exchangerates/rates/a/"+currencyToDisplay.code+"/2022-01-01/2022-01-12/?format=json"
        } else {
            return "ERROR"
        }
    }
}

extension CurrencyDetailViewController: APIProtocol {
    func dataRetrieved(_ retrievedStandartData: APIData?, retrievedTimelinetData: APIDataTimeline?) {
        if let retrievedTimelinetData = retrievedTimelinetData {
            self.currencyTimelineArray = retrievedTimelinetData.rates
            loadDataToChart()
        }
    }
}
