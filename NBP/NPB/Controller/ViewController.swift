//
//  ViewController.swift
//  NBP
//
//  Created by Paweł Brzozowski on 12/01/2022.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableTypeSegmentedController: UISegmentedControl!
    
    // Spiner to show downloading at the beginning
    var spinner = UIActivityIndicatorView(style: .large)
    
    // Refreshing variables. Responsible for pull to refresh acction.
    let refreshControl = UIRefreshControl()
    var refreshingIsActive = false
    // refreshingIsActive - this flag is responsible for turning on and off refresh spinner insde of tableView
    
    // Instance of API caller.
    let myAPICaller = APICaller()
    
    // Data dowloaded from API
    var currencyArray = [currencyModel]()
    var dataDowloadedDate: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the ViewCotroller as the datasoruce and delgate of TableView
        tableView.delegate = self
        tableView.dataSource = self
        
        // Setup APIcaller
        myAPICaller.delegate = self
        
        // Default case - fetch data for table 0 (table with main currencies).
        fetchDataFromAPI(segmentedControlIndex: tableTypeSegmentedController.selectedSegmentIndex)
        
        // Create a pull to refresh
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    // Function to handle refreshing.
    @objc func refresh(_ sender: AnyObject) {
        // Set a flag for refreshing.
        refreshingIsActive = true
        
        // Fetch new data, reload tableView and turn off the refresh spinner inside table views.
        fetchDataFromAPI(segmentedControlIndex: tableTypeSegmentedController.selectedSegmentIndex)
    }
    
    // Functions that fetch data from API.
    func fetchDataFromAPI(segmentedControlIndex: Int) {
        // Start spinner for initial download
        // This function, auto check if it should show spinner (it is initial download not manual refresh).
       createAndStartDowloadSpinner()
        
        // Set proper value for the variable table type.
        // According to the selected index of segmentedController app should perform a different API request.
        var tabletype = ""
        switch segmentedControlIndex {
        case 0:
            tabletype = "A"
        case 1:
            tabletype = "B"
        case 2:
            tabletype = "C"
        default:
            return
        }
        
        // Create a valid string URL and perform a request.
        let stringURL = "https://api.nbp.pl/api/exchangerates/tables/"+tabletype+"/?format=json"
        // Use APICaller object to perform the request by passing a url (string url) value of it.
        myAPICaller.getData(from: stringURL)
    }
}
// MARK: - SegmentedController supervision
extension ViewController {
    // Download data from API according to table type.
    @IBAction func tableTapeChanged(_ sender: UISegmentedControl) {
        switch tableTypeSegmentedController.selectedSegmentIndex {
        case 0:
            fetchDataFromAPI(segmentedControlIndex: 0)
        case 1:
            fetchDataFromAPI(segmentedControlIndex: 1)
        case 2:
            fetchDataFromAPI(segmentedControlIndex: 2)
        default:
            return
        }
    }
}

// MARK: - Prepeare for segue
extension ViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Detect which article the user selected (index path)
        let indexPath = tableView.indexPathForSelectedRow
        
        // Make sure that there is no invalid index. If's not safe to unwrap.
        guard indexPath != nil else {
            return
        }
        
        // Get currency that have been tapped on
        // Index is safe to unwrap due to guard statement
        let selectedCurrency = currencyArray[indexPath!.row]
        
        // Get a reference to the detail view controller (aka CurrencyDetailViewController)
        let detailViewController = segue.destination as! CurrencyDetailViewController
        
        // Pass the data to the detail view controller (aka CurrencyDetailViewController)
        detailViewController.currencyToDisplay = selectedCurrency
    }
}

// MARK: - Article Model Protocool/ Delgate Methods
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Nuber of cells in a tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyArray.count
    }
    
    // Create a custom cell and populate it with data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "NBPCell", for: indexPath) as! CurrencyTableViewCell
        
        // Get the data needed to display
        let curentCurrency = currencyArray[indexPath.row]
        let dowloadedData = dataDowloadedDate ?? "no date"
        let tableIndex = tableTypeSegmentedController.selectedSegmentIndex
        
        // Cusotmize cell
        cell.displayCurrencyCell(curentCurrency: curentCurrency, downloadDate: dowloadedData, segmentedControlIndexValue: tableIndex)
        
        // return the cell
        return cell
    }
    
    // User has just selected row, trigger the segue to the detail screen.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // If the user tries to see detail range rates for additional category DO NOT PERFORM SEGUE
        // Additional category currencies doesn't have rates by range of dates
        // Additional category is represented by segmentedController's index 1
        if tableTypeSegmentedController.selectedSegmentIndex != 1 {
            // There is details for this currency - perform a segue
            performSegue(withIdentifier: "goToDetail", sender: self)
        } else {
            // Sorry, but for this type of currency there aren't detail data
            // Let user know by showing info in the alert.
            let alert = createCustomAllert(alertTitle: "Cannot go to the detail view for \(currencyArray[indexPath.row].code).", alertMessage: "Sorry, but there is no detail data for \(currencyArray[indexPath.row].currency) yet. Data provider doesn't support data for additional category.", actionTitle: "OK")
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - API Protocol-Delegate Methods
// Adapt APIProtocol to retrieve data from APICaller
extension ViewController: APIProtocol {
    // Delegate-protocol function that allows data flow from API caller.
    func dataRetrieved(_ retrievedStandartData: APIData?, retrievedTimelinetData: APIDataTimeline?) {
        if let retrievedStandartData = retrievedStandartData {
            
            // Set value in variable from downloaded data.
            self.currencyArray = retrievedStandartData.rates
            self.dataDowloadedDate = retrievedStandartData.effectiveDate

            // Reloading tableView after getting data
            tableView.reloadData()

            // Toggle spinner flag and turn off table view spinner
            if refreshingIsActive {
                refreshingIsActive.toggle()
                refreshControl.endRefreshing()
            }
            // Destroy created spinner that indicates that data is being downloaded to start of the screening.
            stopAndDestroySpinner()
        }
    }
    
}
