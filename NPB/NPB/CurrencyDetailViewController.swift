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
    
    // Dates for API call
    var firstDate: String?
    var secondDate: String?
    
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
            self.title = currencyToDisplay.currency.uppercased()
        }
        
        // Setup APIcaller
        myAPICaller.delegate = self
        
        // Setup charts
        lineChart.delegate = self
        
        // Create a chart
        lineChart.frame = CGRect(x: 0, y: 0, width: chartView.frame.width, height: chartView.frame.height)
        chartView.addSubview(lineChart)
        
        // Get new date and set label acording to it.
        setUpInitialDateLabel()
        
        // Dowload timeline rates
        // Create a valid string URL and perform a request.
        let stringURL = createValidURLToApi()
        myAPICaller.getData(from: stringURL)
    }
    func setNewDateOnLabel(firstDate date1: String, secondDate date2 :String) {
        dateRangeLabel.text = "Price from "+date1+" to "+date2
    }
    
    func setUpInitialDateLabel() {
        // Gets the current date and time
        let currentDateTime = Date()
        
        // Initialize the date formatter
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        // Get the date as String
        let dateTodayString = formatter.string(from: currentDateTime)
        
        // Date 2 weeks before
        let dateBefore = Date().addWeek(noOfWeeks: -2)
        let dateBeforeString = formatter.string(from: dateBefore)
        
        self.firstDate = dateBeforeString
        self.secondDate = dateTodayString
        
        setNewDateOnLabel(firstDate: dateBeforeString, secondDate: dateTodayString)
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
        guard firstDate != nil, secondDate != nil else {
            return ""
        }

        let dateRange = firstDate!+"/"+secondDate!
        
        if let currencyToDisplay = currencyToDisplay {
            return "https://api.nbp.pl/api/exchangerates/rates/a/"+currencyToDisplay.code+"/"+dateRange+"/?format=json"
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

extension Date {
    func addWeek(noOfWeeks: Int) -> Date {
    return Calendar.current.date(byAdding: .weekOfYear, value: noOfWeeks, to: self)!
    }
}
   
