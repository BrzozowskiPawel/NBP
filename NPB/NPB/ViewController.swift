//
//  ViewController.swift
//  NPB
//
//  Created by Paweł Brzozowski on 12/01/2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableTypeSegmentedController: UISegmentedControl!
    
    // Spiner to show dowloading at the beggining
    var spinner = UIActivityIndicatorView(style: .large)
    
    
    // Refreshing variables.
    let refreshControl = UIRefreshControl()
    var refreshingIsActive = false // This flag is responsible for turning on and off refresh spinner insde of tableView
    
    // Instance of API caller.
    let myAPICaller = APICaller()
    
    // Data dowloaded from API
    var currencyArray = [currencyModel]()
    var dataDowloadedDate: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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
        
        // Fetch new data, reload tableView and turn off the refresh spinner inside tableviews.
        fetchDataFromAPI(segmentedControlIndex: tableTypeSegmentedController.selectedSegmentIndex)
    }
    
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
    
    // Functions that fetch data from API.
    func fetchDataFromAPI(segmentedControlIndex: Int) {
        // If it's not a refresh then show dowloading spinner
        if !refreshingIsActive {
            createAndStartDowloadSpinner()
        }
        
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
        myAPICaller.getData(from: stringURL)
    }
    
    
    // Dowload data from API acording to table type.
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
        
        guard indexPath != nil else {
            return
        }
        
        // Get currency that have been tapped on
        let selectedCurrency = currencyArray[indexPath!.row]
        
        // get a reference to the detail view contorller (aka CurrencyDetailViewController)
        let detailViewController = segue.destination as! CurrencyDetailViewController
        
        // Pass the data to the detail view contorller (aka CurrencyDetailViewController)
        detailViewController.currencyToDisplay = selectedCurrency
    }
}

// MARK: - Navigation controller hiding/showing
extension ViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
}

// MARK: - Article Model Protocool/ Delgate Methods
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyArray.count
    }
    
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
    
    // User has just selected row, trigger the segue to detail screen.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // If user try to see detail range rates for additional category DO NOT PERFORM SEGUE
        // Additional category currencies doesnt have rates by range od dates
        // Additional category is represented by segmentedController's index 1
        if tableTypeSegmentedController.selectedSegmentIndex != 1 {
            performSegue(withIdentifier: "goToDetail", sender: self)
        } else {
            let alert = createCustomAllert(alertTitle: "Cannot go to detail view.", alertMessage: "Sorry but there is no detail data for \(currencyArray[indexPath.row].code) yet. Data provider doesn't support data for additional category.", actionTitle: "OK")
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - API Protocool-Delgate Methods

// Adapt APIProtocol to retrieve data from APICaller
extension ViewController: APIProtocol {
    
    func dataRetrieved(_ retrievedStandartData: APIData?, retrievedTimelinetData: APIDataTimeline?) {
        if let retrievedStandartData = retrievedStandartData {
            
            // Set data.
            self.currencyArray = retrievedStandartData.rates
            self.dataDowloadedDate = retrievedStandartData.effectiveDate

            // Temporary give info about API call.
            print("VC: number of currencies: \(currencyArray.count)")
            print("VC: date of dowloaded data: \(dataDowloadedDate)")

            // Reloading tableView after getting data
            tableView.reloadData()

            // Toggle spinner flag and turn off spinner
            if refreshingIsActive {
                refreshingIsActive.toggle()
                refreshControl.endRefreshing()
            } else {
                stopAndDestroySpinner()
            }
        }
    }
    
}
