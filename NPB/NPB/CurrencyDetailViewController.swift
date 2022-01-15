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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var datePickerBackgroundView: UIView!
    
    // Spiner to show dowloading at the beggining
    var spinner = UIActivityIndicatorView(style: .large)
    
    private let floatingButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        button.backgroundColor = .systemBlue
        let img =  UIImage(systemName: "calendar.badge.plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: UIImage.SymbolWeight.medium))
        
        button.setImage(img, for: .normal)
        button.tintColor = .white
        button.setTitleColor(UIColor.white, for: .normal)
        
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 30
        return button
    }()
    
    // DatePicker and toolbar for datpicker
    var toolBar = UIToolbar()
    var datePicker = UIDatePicker()
    
    // Dates for API call
    var firstDate: Date?
    var secondDate: Date?
    
    // Last proper Dates.
    // If user select wrong range of data this values will be used for API call.
    var lastFirstDate: Date?
    var lastSecondDate: Date?
    
    // Storing data abour currency to dispaly
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
        // Right axi isn't nessesary - it's make it harder to read
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
        
        // Animate char
        chartView.animate(xAxisDuration: 0.5)
        
        // Return custom chart
        return chartView
    }()
    
    // Inidates if first date from range have been setted
    var firstDateSetted: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the title
        if let currencyToDisplay = currencyToDisplay {
            self.title = currencyToDisplay.currency.uppercased()
        }
        
        // Setup APIcaller
        myAPICaller.delegate = self
        
        
        // Get new date and set label acording to it.
        // This also set up initial range dates to allow perfoming request in next step.
        setUpInitialDateAndUpdateLabel()
        
        // Dowload timeline rates
        fetchDataFromAPI()
        
        // Set the ViewCotroller as the datasoruce and delgate of TableView
        tableView.delegate = self
        tableView.dataSource = self
        
        // Add lineChart to the view
        lineChart.frame = CGRect(x: 0, y: 0, width: chartView.frame.width, height: chartView.frame.height)
        chartView.backgroundColor = .systemBlue
        chartView.addSubview(lineChart)
        
        // Setup chart's delegate
        lineChart.delegate = self
        
        // Add floating button
        floatingButton.frame = CGRect(x: view.frame.size.width - 90, y: view.frame.size.height - 120, width: 60, height: 60)
        floatingButton.addTarget(self, action: #selector(setNewDateRange), for: .touchUpInside)
        view.addSubview(floatingButton)
    }
    
    func fetchDataFromAPI() {
        // Create a initial dowload spinner
        createAndStartDowloadSpinner()
        
        // Create a valid string URL and perform a request.
        let stringURL = createValidURLToApi()
        
        // Make sure that url isn't nil.
        // There might be a error with creating a valild URL.
        if let stringURL = stringURL {
            myAPICaller.getData(from: stringURL)
        }
        
    }
    
    func setNewRangeLabelText(firstDate date1: String, secondDate date2: String) {
        rangeLabel.text = "Price from "+date1+" to "+date2
    }
    
    func getDateAsString(DateToFormat date: Date) -> String {
        // Initialize the date formatter
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        // Return formated date
        return formatter.string(from: date)
    }
    
    func setUpInitialDateAndUpdateLabel() {
        // Gets the current date and time
        let currentDateTime = Date()
        
        // Get the date as String
        let dateTodayString = getDateAsString(DateToFormat: currentDateTime)
        
        // Date 13 weeks before - because API specyfications says that max range is 93 days.
        // Hoever out of the scope 6 moths also worked.
        let dateBefore = Date().addWeek(noOfWeeks: -13)
        let dateBeforeString = getDateAsString(DateToFormat: dateBefore)
        
        // Setup range's dates
        self.firstDate = dateBefore
        self.secondDate = currentDateTime
        
        // Set initial values for range dates.
        // This values will be used in case user set wrong range.
        self.lastFirstDate = firstDate
        self.lastSecondDate = secondDate
        
        // Update label with proper values.
        setNewRangeLabelText(firstDate: dateBeforeString, secondDate: dateTodayString)
        
    }
    
    // Load data to the chart
    func setChartData() {
        // Create a variable that stores entries
        var entries = [ChartDataEntry]()

        // Create an entry. For x use simply number form 0 to make it more redable
        var index:Double = 1.0
        for singleRate in currencyTimelineArray {
            entries.append(ChartDataEntry(x: index, y: singleRate.mid))
            index += 1
        }

        // Set of data, also add label that this chart represents price of specyfic currency
        let set = LineChartDataSet(entries: entries, label: "Price of \(currencyToDisplay!.code)")

        // Remove circles
        set.drawCirclesEnabled = false
        
        // Smooth out edges of set
        // set.mode = .cubicBezier
        
        // Set line widt
        set.lineWidth = 2
        
        // Set set color to white
        set.setColor(.white)
        
        set.drawHorizontalHighlightIndicatorEnabled = false
        
        // Set fill of under the line
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
    
    func createValidURLToApi() -> String?{
        guard firstDate != nil, secondDate != nil else {
            print("DATES ARE EMPTY")
            return ""
        }
        
        // Get first and second date as formated string
        let firstDateString = getDateAsString(DateToFormat: firstDate!)
        let secondDateString = getDateAsString(DateToFormat: secondDate!)
        
        // Create date range as string
        let dateRange = firstDateString+"/"+secondDateString
        
        if let currencyToDisplay = currencyToDisplay {
            return "https://api.nbp.pl/api/exchangerates/rates/a/"+currencyToDisplay.code+"/"+dateRange+"/?format=json"
        } else {
            return nil
        }
    }
    
    // This functions set vales of First and Second date to the inital values if there was an error with choosing new range.
    func useInitialDateValues() {
        self.firstDate =  self.lastFirstDate
        self.secondDate = self.lastSecondDate
    }
    
    // Handle error when suer set second date before first
    func handleRangeErrorSecodDateIsBefore() {
        // Because selected rnage is inavlid use initial values.
        useInitialDateValues()
        
        // Get first and second date as formated string
        let firstDateString = getDateAsString(DateToFormat: firstDate!)
        let secondDateString = getDateAsString(DateToFormat: secondDate!)
        
        // Create an allert to inform user about this error
        let alert = createCustomAllert(alertTitle: "Second date cannot be before first date.", alertMessage: "Sorry but selected range is invalid. Your first date is: \(firstDateString) and second is \(secondDateString). Please set range again.", actionTitle: "OK")
        self.present(alert, animated: true, completion: nil)
    }
    
    // Handle error when date is in futre
    func handleRangeErrorDateIsFuture() {
        // Because selected rnage is inavlid use initial values.
        useInitialDateValues()
        
        // Get first and second date as formated string
        let firstDateString = getDateAsString(DateToFormat: firstDate!)
        let secondDateString = getDateAsString(DateToFormat: secondDate!)
        
        // Create an allert to inform user about this error
        let alert = createCustomAllert(alertTitle: "Range cannot be in fute", alertMessage: "Sorry but selected range is invalid. Your first date is: \(firstDateString) and second is \(secondDateString). Make sure that dates arent future and select a range again.", actionTitle: "OK")
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleRangeErrorMaxRange(days numOfdays: Int) {
        // Because selected rnage is inavlid use initial values.
        useInitialDateValues()
        
        // Create an allert to inform user about this error
        let alert = createCustomAllert(alertTitle: "Max range is 93 days.", alertMessage: "Sorry but selected range is invalid. Max range is 93 days and your range was \(numOfdays)", actionTitle: "OK")
        self.present(alert, animated: true, completion: nil)
    }
    
    // Calcute how many days have passed between 2 dates
    func daysBetween(start: Date, end: Date) -> Int {
            return Calendar.current.dateComponents([.day], from: start, to: end).day! + 1
        }
    
    // Perform chaeck to make sure that dates in range is correct
    func performErrorCheck() {
        // - first date must be eariler then second date
        // - non of dates can be after current date
        // - single rnage cannot be larger than 93 days
        if secondDate! < firstDate! {
            // Handling this error
            handleRangeErrorSecodDateIsBefore()
            return
        }
        let currentDate = Date()
        if secondDate! > currentDate || firstDate! > currentDate {
            handleRangeErrorDateIsFuture()
            return
        }
        
        let days = daysBetween(start: firstDate!, end: secondDate!)
        // KEEP IN MIND THAT API DOCUMENATION SAYS THAT MAX ANGE IS 93 DAYS
        if days > 367 {
            handleRangeErrorMaxRange(days: days)
            return
        }
    }
    
    @objc func donePressed() {
        if firstDateSetted == false {
            // Set new value for firstDate
            firstDate = datePicker.date
            
            // Get a String value of firstDate
            let firstDateString = getDateAsString(DateToFormat: firstDate!)
            
            // Update label
            setNewRangeLabelText(firstDate: firstDateString, secondDate: "")
            
            // Set flag that firstDate have been setted
            firstDateSetted = true
            
        } else if firstDateSetted == true {
            // Set new value for secondDate
            secondDate = datePicker.date
            
            // Make sure that vales aren't nil and unwrape is safe.
            guard firstDate != nil, secondDate != nil else {
                return
            }
            
            // Perform chaeck to make sure that dates in rages are correct
            // If not use last values.
            performErrorCheck()
            
            // Get a String value of secondDate
            let firstDateString = getDateAsString(DateToFormat: firstDate!)
            let secondDateString = getDateAsString(DateToFormat: secondDate!)
            
            // Update label
            setNewRangeLabelText(firstDate: firstDateString, secondDate: secondDateString)
            
            // Dowload new data acording to new range od dates
            fetchDataFromAPI()
            
            // Hide background of view.
            // TableView cells will be fully visible now
            datePickerBackgroundView.alpha = 0
            
            // Show flaoting button again
            floatingButton.alpha = 1
            
            toolBar.removeFromSuperview()
            datePicker.removeFromSuperview()
            
            // Reset this flag value to initial state.
            firstDateSetted = false
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        fetchDataFromAPI()
    }
    
    
}

// MAKR: - Floating button - set a new range
extension CurrencyDetailViewController {
    // Button callendar
    @objc func setNewDateRange(_ sender: Any) {
        // Hide floating button
        floatingButton.alpha = 0
        
        // Set alpha of this view to 1. Now only picker will be visible
        datePickerBackgroundView.alpha = 1
        datePickerBackgroundView.backgroundColor = UIColor.white
        
        datePicker = UIDatePicker.init()
        datePicker.backgroundColor = UIColor.white
                    
        datePicker.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        
        self.view.addSubview(datePicker)
        
        
        let xConstraint = NSLayoutConstraint(item: datePicker, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: datePicker, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 290)
        
        NSLayoutConstraint.activate([xConstraint, yConstraint])
        
        toolBar = UIToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.donePressed))]
            toolBar.sizeToFit()
        self.view.addSubview(toolBar)
        
    }
}


// MARK: - Creating and destroying initial dowload spinner
extension CurrencyDetailViewController {
    // Create a dowload spinner
    func createAndStartDowloadSpinner() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    // Destroy a dowload spinner
    func stopAndDestroySpinner() {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
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

// MARK: - Delegate-Protocol API extension
extension CurrencyDetailViewController: APIProtocol {
    func dataRetrieved(_ retrievedStandartData: APIData?, retrievedTimelinetData: APIDataTimeline?) {
        if let retrievedTimelinetData = retrievedTimelinetData {
            self.currencyTimelineArray = retrievedTimelinetData.rates
            
            // After data is dowloaded start creating data to populate the chart.
            setChartData()
            // Reload new data to the tablewView
            tableView.reloadData()
            
            // Destroy created spinner that indicates that data is being dowloaded on start of the screen.
            stopAndDestroySpinner()
        }
    }
}

extension Date {
    func addWeek(noOfWeeks: Int) -> Date {
    return Calendar.current.date(byAdding: .weekOfYear, value: noOfWeeks, to: self)!
    }
}
   

