//
//  CurrencyDetailViewController.swift
//  NBP
//
//  Created by Paweł Brzozowski on 13/01/2022.
//

import UIKit
import Charts

class CurrencyDetailViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var datePickerBackgroundView: UIView!
    
    // Spiner to show downloading at the beginning
    var spinner = UIActivityIndicatorView(style: .large)

    // Create a floatingButton
    var floatingButton = UIButton()
    
    // DatePicker and toolbar for datpicker
    var toolBar = UIToolbar()
    var datePicker = UIDatePicker()
    
    // Dates for API call
    var firstDate: Date?
    var secondDate: Date?
    
    // Last proper Dates.
    // If the user selects a wrong range of data this value will be used for the API call.
    var lastFirstDate: Date?
    var lastSecondDate: Date?
    
    // Storing data about currency to display. (This data if passed from rpevious VC)
    var currencyToDisplay: currencyModel?
    
    // Instance of API caller.
    let myAPICaller = APICaller()
    
    // Data dowloaded from API
    var currencyTimelineArray = [timelineRate]()
    
    // Create a chart object
    lazy var lineChart: LineChartView = {
        // Create a chary
        let chartView = LineChartView()
        
        // Customize chart
        // Right axis isn't necessary - it's making it harder to read
        chartView.rightAxis.enabled = false
        // Customize left axis
        let yAxis = chartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        // Show only 4 labels
        yAxis.setLabelCount(8, force: false)
        // Y Axis colors
        yAxis.labelTextColor = .white
        yAxis.axisLineColor = .white
        // Customize label position
        yAxis.labelPosition = .outsideChart
        
        // X Axis customization
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .boldSystemFont(ofSize: 12)
        xAxis.setLabelCount(8, force: false)
        xAxis.labelTextColor = .white
        xAxis.axisLineColor = .systemBlue
        
        // Animate chart
        chartView.animate(xAxisDuration: 0.7)
        
        // Return custom chart
        return chartView
    }()
    
    // Inidates if first date from range have been setted
    // After this flag value is true, the user is choosing 2. value for the range.
    var firstDateSetted: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the title
        if let currencyToDisplay = currencyToDisplay {
            self.title = currencyToDisplay.currency.uppercased()
        }
        
        // Setup APIcaller
        myAPICaller.delegate = self
        
        
        // Get new date and set label according to it.
        // This also set up initial range dates to allow performing the request in the next step.
        setUpInitialDateAndUpdateLabel()
        
        // Download timeline, rates
        fetchDataFromAPI()
        
        // Set the ViewCotroller as the datasoruce and delegate of Table View
        tableView.delegate = self
        tableView.dataSource = self
        
        // Add lineChart to the view
        lineChart.frame = CGRect(x: 0, y: 0, width: chartView.frame.width, height: chartView.frame.height)
        chartView.backgroundColor = .systemBlue
        chartView.addSubview(lineChart)
        
        // Setup chart's delegate
        lineChart.delegate = self
        
        // Add floating button
        configureFloatingButton()
        floatingButton.frame = CGRect(x: view.frame.size.width - 90, y: view.frame.size.height - 120, width: 60, height: 60)
        floatingButton.addTarget(self, action: #selector(setNewDateRange), for: .touchUpInside)
        view.addSubview(floatingButton)
    }
    
    // Functions creating a url to make an API call.
    // URL depends of currency that have been selected and also on a range of dates.
    // Each time this data is changes, new url is being created to allow the new API call.
    func createValidURLToApi() -> String?{
        guard firstDate != nil, secondDate != nil else {
            print("DATES ARE EMPTY")
            return nil
        }
        
        // Get the first and second date as a formatted string
        let firstDateString = getDateAsString(DateToFormat: firstDate!, dateFormatString: "yyyy-MM-dd")
        let secondDateString = getDateAsString(DateToFormat: secondDate!, dateFormatString: "yyyy-MM-dd")
        
        // Create a date range as string
        let dateRange = firstDateString+"/"+secondDateString
        
        // Return final url
        if let currencyToDisplay = currencyToDisplay {
            return "https://api.nbp.pl/api/exchangerates/rates/a/"+currencyToDisplay.code+"/"+dateRange+"/?format=json"
        } else {
            return nil
        }
    }
    
    // Function that download data from the API using delegate-protocol method.
    // Data is saved to instances in this class.
    func fetchDataFromAPI() {
        // Create an dowload spinner
        createAndStartDowloadSpinner()
        
        // Create a valid string URL and perform a request.
        let stringURL = createValidURLToApi()
        
        // Make sure that url isn't nil.
        // There might be an error with creating a valid URL.
        if let stringURL = stringURL {
            myAPICaller.getData(from: stringURL)
        }
    }
    
    // Set up initial date for the range.
    // Initial range is today and  (today - 13 weeks)
    // (API documentations says 93 days is max. value)
    // Also update a label to display proper range.
    func setUpInitialDateAndUpdateLabel() {
        // Gets the current date and time
        let currentDateTime = Date()
        
        // Get the date as String
        let dateTodayString = getDateAsString(DateToFormat: currentDateTime, dateFormatString: "yyyy-MM-dd")
        
        // Date 13 weeks before - because the API specification says that max range is 93 days.
        // Hover (this is out of the scope) more then 6 moths also worked :).
        let dateBefore = Date().addWeek(noOfWeeks: -13)
        let dateBeforeString = getDateAsString(DateToFormat: dateBefore, dateFormatString: "yyyy-MM-dd")
        
        // Setup range's dates
        self.firstDate = dateBefore
        self.secondDate = currentDateTime
        
        // Set initial values for range dates.
        // This value will be used in case user set wrong range.
        self.lastFirstDate = firstDate
        self.lastSecondDate = secondDate
        
        // Update label with proper values.
        setNewRangeLabelText(firstDate: dateBeforeString, secondDate: dateTodayString)
    }
    
    
    // This function set values of the First and Second date to the initial values if there was an error with choosing new range.
    func useInitialDateValues() {
        self.firstDate =  self.lastFirstDate
        self.secondDate = self.lastSecondDate
    }
    
    // Calculate how many days have passed between 2 dates
    func daysBetween(start: Date, end: Date) -> Int {
            return Calendar.current.dateComponents([.day], from: start, to: end).day! + 1
        }
    
    // Done button on datePicker pressed.
    // First time done button is pressed the first date in the range is saved.
    // Second time, the second date is saved.
    // Then this function also performs checks for error in range.
    // If there are no error and range is valid, new API call is being made.
    @objc func donePressed() {
        if firstDateSetted == false {
            // Set new value for firstDate
            firstDate = datePicker.date
            
            // Get a String value of firstDate
            let firstDateString = getDateAsString(DateToFormat: firstDate!, dateFormatString: "yyyy-MM-dd")
            
            // Update label
            setNewRangeLabelText(firstDate: firstDateString, secondDate: "")
            
            // Set flag that firstDate have been setted
            firstDateSetted = true
            
        } else if firstDateSetted == true {
            // Set new value for secondDate
            secondDate = datePicker.date
            
            // Make sure that values aren't nil and unwrap is safe.
            guard firstDate != nil, secondDate != nil else {
                return
            }
            
            // Perform check to make sure that dates in rages are correct. If not use last values.
            performErrorCheck()
            
            // Get a String value of secondDate
            let firstDateString = getDateAsString(DateToFormat: firstDate!, dateFormatString: "yyyy-MM-dd")
            let secondDateString = getDateAsString(DateToFormat: secondDate!, dateFormatString: "yyyy-MM-dd")
            
            // Update label
            setNewRangeLabelText(firstDate: firstDateString, secondDate: secondDateString)
            
            // Download new data according to the new range of dates
            fetchDataFromAPI()
            
            // Hide background of view.
            // TableView cells will be fully visible now
            datePickerBackgroundView.alpha = 0
            
            // Show floating button again
            floatingButton.alpha = 1
            
            toolBar.removeFromSuperview()
            datePicker.removeFromSuperview()
            
            // Reset this flag value to initial state.
            firstDateSetted = false
        }
    }
    
    // Manually refresh data pressing right BarButton.
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        fetchDataFromAPI()
    }
}

// MAKR: - FloatingButton - set a new dates range
extension CurrencyDetailViewController {
    // Button callendar
    @objc func setNewDateRange(_ sender: Any) {
        // Hide floating button
        floatingButton.alpha = 0
        
        // Set alpha of this view to 1. Now only picker will be visible
        datePickerBackgroundView.alpha = 1
        datePickerBackgroundView.backgroundColor = UIColor.white
        
        // Create datePicker
        datePicker = UIDatePicker.init()
        datePicker.backgroundColor = UIColor.white
        datePicker.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        // Add datePicker to the view
        self.view.addSubview(datePicker)
        
        // Place datePicker
        let xConstraint = NSLayoutConstraint(item: datePicker, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: datePicker, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 290)
        
        NSLayoutConstraint.activate([xConstraint, yConstraint])
        
        // Add toolBar with done button.
        toolBar = UIToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.donePressed))]
            toolBar.sizeToFit()
        
        // Add toolBar
        self.view.addSubview(toolBar)
        
    }
}


// MARK: - Creating and destroying initial dowload spinner
extension CurrencyDetailViewController {
    // Create a dowload spinner
    func createAndStartDowloadSpinner() {
        // Create spinner and add it to the view
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        // Place spinner
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    // Destroy a dowload spinner
    func stopAndDestroySpinner() {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
    }
}

// MARK: - Delegate-Protocol API extension
extension CurrencyDetailViewController: APIProtocol {
    func dataRetrieved(_ retrievedStandartData: APIData?, retrievedTimelinetData: APIDataTimeline?) {
        if let retrievedTimelinetData = retrievedTimelinetData {
            self.currencyTimelineArray = retrievedTimelinetData.rates
            
            // After data is downloaded start creating data to populate the chart.
            setChartData()
            // Reload new data to the tablewView
            tableView.reloadData()
            
            // Destroy created spinner that indicates that data is being downloaded to start of the screening.
            stopAndDestroySpinner()
        }
    }
}

// MARK: - Handle DETECTED type of errors.
extension CurrencyDetailViewController {
    
    /*
     Both firstDate! and secondDate! are safe to force unwrap.
     This have been checked before calling function
     */
    
    // Handle error when set second date before first
    func handleRangeErrorSecodDateIsBefore() {
        // Because selected rnage is inavlid use initial values.
        useInitialDateValues()
        
        // Get the first and second date as a formatted string
        let firstDateString = getDateAsString(DateToFormat: firstDate!, dateFormatString: "yyyy-MM-dd")
        let secondDateString = getDateAsString(DateToFormat: secondDate!, dateFormatString: "yyyy-MM-dd")
        
        // Create an alert to inform user about this error
        let alert = createCustomAllert(alertTitle: "Second date cannot be before the first date.", alertMessage: "Sorry, but selected range is invalid. Your first date is: \(firstDateString) and the second is \(secondDateString). Please set range again.", actionTitle: "OK")
        self.present(alert, animated: true, completion: nil)
    }
    
    // Handle error when the date is in the future
    func handleRangeErrorDateIsFuture() {
        // Because selected range is invalid, use initial values.
        useInitialDateValues()
        
        // Get the first and second date as a formatted string
        let firstDateString = getDateAsString(DateToFormat: firstDate!, dateFormatString: "yyyy-MM-dd")
        let secondDateString = getDateAsString(DateToFormat: secondDate!, dateFormatString: "yyyy-MM-dd")
        
        // Create an alert to inform user about this error
        let alert = createCustomAllert(alertTitle: "The range cannot contain in future dates", alertMessage: "Sorry, but selected range is invalid. Your first date is: \(firstDateString) and the second is \(secondDateString). Make sure that the dates aren't  in the future and select a range again.", actionTitle: "OK")
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleRangeErrorMaxRange(days numOfdays: Int) {
        // Because selected range is invalid, use initial values.
        useInitialDateValues()
        
        // Create an alert to inform user about this error
        let alert = createCustomAllert(alertTitle: "Maximum range is 93 days.", alertMessage: "Sorry, but the selected range is invalid. Maximum range is 93 days and your range was \(numOfdays)", actionTitle: "OK")
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - Detect if any kind of error exists, if so call spefycic handler.
extension CurrencyDetailViewController {
    // Perform check to make sure that dates in the range are correct
    func performErrorCheck() {
        // - first date must be earlier then the second date
        // - non of dates can be after the current date
        // - single range cannot be larger than 93 days
        if secondDate! < firstDate! {
            // Handle this error
            handleRangeErrorSecodDateIsBefore()
            return
        }
        let currentDate = Date()
        
        if secondDate! > currentDate || firstDate! > currentDate {
            handleRangeErrorDateIsFuture()
            return
        }
        
        let days = daysBetween(start: firstDate!, end: secondDate!)
        // KEEP IN MIND THAT API DOCUMENTATION SAYS THAT MAX ANGE IS 93 DAYS. That's why this range is so small...
        if days > 93 {
            handleRangeErrorMaxRange(days: days)
            return
        }
    }
}

