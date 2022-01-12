//
//  ViewController.swift
//  NPB
//
//  Created by Paweł Brzozowski on 12/01/2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
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
        
        // Default case - fetch data for table A
        fetchDataFromAPI(tabletype: "A")
    }

    // Functions that fetch data from API.
    func fetchDataFromAPI(tabletype: String) {
        let stringURL = "https://api.nbp.pl/api/exchangerates/tables/"+tabletype+"/?format=json"
        myAPICaller.getData(from: stringURL)
        
    }
    
    

}

// MARK: - Article Model Protocool/ Delgate Methods
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NBPCell", for: indexPath)
        
        cell.textLabel?.text = currencyArray[indexPath.row].currency
        
        return cell
    }
    
    
    
}

// MARK: - API Protocool-Delgate Methods

// Adapt APIProtocol to retrieve data from APICaller
extension ViewController: APIProtocol {
    
    // Retrieve data. From now data is no logner a list of APIData but single APIData.
    func dataRetrieved(_ retrievedData:APIData) {
        // Set data.
        self.currencyArray = retrievedData.rates
        self.dataDowloadedDate = retrievedData.effectiveDate
        
        // Temporary give info about API call.
        print("VC: number of currencies: \(currencyArray.count)")
        print("VC: date of dowloaded data: \(dataDowloadedDate)")
        
        // Reloading tableView after getting data
        tableView.reloadData()
    }
}
