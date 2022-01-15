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
    var datePicker  = UIDatePicker()
    
    // Dates for API call
    var firstDate: String?
    var secondDate: String?
    
    // Initial Dates. If user select wrong range of data this values will be used
    var initialFirstDate: String?
    var initialSecondDate: String?
    
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
        setUpInitialDateLabel()
        
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
        let dateBefore = Date().addWeek(noOfWeeks: -24)
        let dateBeforeString = formatter.string(from: dateBefore)
        
        self.firstDate = dateBeforeString
        self.secondDate = dateTodayString
        
        // Set initial values for range dates.
        // This values will be used in case user set wrong range.
        if initialFirstDate == nil && initialSecondDate == nil {
            self.initialFirstDate = dateBeforeString
            self.initialSecondDate = dateTodayString
        }
        
        // Update label with proper values.
        setNewRangeLabel(firstDate: dateBeforeString, secondDate: dateTodayString)
        
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
//        set.mode = .cubicBezier
        
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

        let dateRange = firstDate!+"/"+secondDate!
        
        if let currencyToDisplay = currencyToDisplay {
            return "https://api.nbp.pl/api/exchangerates/rates/a/"+currencyToDisplay.code+"/"+dateRange+"/?format=json"
        } else {
            return nil
        }
    }
    
    @objc func donePressed() {
        // Initialize the date formatter
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        // Get the date as String
        let selectedDate = formatter.string(from: datePicker.date)
        
        if firstDateSetted == false {
            firstDate = selectedDate
            setNewRangeLabel(firstDate: firstDate!, secondDate: "")
            
            // Set flag that firstDate have been setted
            firstDateSetted = true
            
        } else if firstDateSetted == true {
            secondDate = selectedDate
            setNewRangeLabel(firstDate: firstDate!, secondDate: secondDate!)
            
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
            
//            firstDate = nil
//            secondDate = nil
            
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
   
