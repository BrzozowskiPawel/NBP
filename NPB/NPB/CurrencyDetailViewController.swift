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
    @IBOutlet weak var rangeLabel: UILabel!
    
    // DatePicker and toolbar for datpicker
    var toolBar = UIToolbar()
    var datePicker  = UIDatePicker()
    
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
    func setNewRangeLabel(firstDate date1: String, secondDate date2: String) {
        rangeLabel.text = "Price from "+date1+" to "+date2
        
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
        
        setNewRangeLabel(firstDate: dateBeforeString, secondDate: dateTodayString)
        
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
            print("DATES ARE EMPTY")
            return ""
        }

        let dateRange = firstDate!+"/"+secondDate!
        
        if let currencyToDisplay = currencyToDisplay {
            return "https://api.nbp.pl/api/exchangerates/rates/a/"+currencyToDisplay.code+"/"+dateRange+"/?format=json"
        } else {
            return "ERROR"
        }
    }
    
    // Button callendar
    @IBAction func setNewDateRange(_ sender: Any) {
        datePicker = UIDatePicker.init()
        datePicker.backgroundColor = UIColor.white
                    
        //datePicker.autoresizingMask = .flexibleWidthe
                    
//            datePicker.addTarget(self, action: #selector(self.dateChanged(_:)), for: .valueChanged)
        datePicker.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(datePicker)
        let xConstraint = NSLayoutConstraint(item: datePicker, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: datePicker, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 290)
        
        NSLayoutConstraint.activate([xConstraint, yConstraint])
        
        toolBar = UIToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
//        toolBar.barStyle = .blackTranslucent
        toolBar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.donePressed))]
            toolBar.sizeToFit()
        self.view.addSubview(toolBar)
    }
    
    func loadNewDataFromAPI() {
        // Dowload timeline rates
        // Create a valid string URL and perform a request.
        let stringURL = createValidURLToApi()
        myAPICaller.getData(from: stringURL)
    }
    
//    func createAndCustromDatePicker() {
//        // toolbar
//        let toolbar = UIToolbar()
//        toolbar.sizeToFit()
//
//        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
//        toolbar.setItems([doneButton], animated: true)
//
//        // Add toolbar
//        dateRangeTextField.inputAccessoryView = toolbar
//
//        // Asign date pciker to the text field
//        dateRangeTextField.inputView = datePicker
//
//    }
    
//    @objc func nextDate() {
//        // Initialize the date formatter
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//
//        // Get the date as String
//        firstDate = formatter.string(from: datePicker.date)
//
//        print("Date saved: \(firstDate)")
//
//        datePicker.
//
//    }
    
    @objc func donePressed() {
        // Initialize the date formatter
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        // Get the date as String
        let selectedDate = formatter.string(from: datePicker.date)
        
        if firstDate == nil {
            firstDate = selectedDate
            print("Setted first date to: \(firstDate)")
            setNewRangeLabel(firstDate: firstDate!, secondDate: "")
        } else if firstDate != nil && secondDate == nil {
            secondDate = selectedDate
            print("Setted first date to: \(secondDate)")
            setNewRangeLabel(firstDate: firstDate!, secondDate: secondDate!)
            loadNewDataFromAPI()
            
            toolBar.removeFromSuperview()
            datePicker.removeFromSuperview()
        }

//        self.view.endEditing(true)
    }
    
}

extension CurrencyDetailViewController: APIProtocol {
    func dataRetrieved(_ retrievedStandartData: APIData?, retrievedTimelinetData: APIDataTimeline?) {
        if let retrievedTimelinetData = retrievedTimelinetData {
            self.currencyTimelineArray = retrievedTimelinetData.rates
            loadDataToChart()
            
            firstDate = nil
            secondDate = nil
        }
    }
}

extension Date {
    func addWeek(noOfWeeks: Int) -> Date {
    return Calendar.current.date(byAdding: .weekOfYear, value: noOfWeeks, to: self)!
    }
}
   
