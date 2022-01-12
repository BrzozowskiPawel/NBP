//
//  ViewController.swift
//  NPB
//
//  Created by Paweł Brzozowski on 12/01/2022.
//

import UIKit

class ViewController: UIViewController {

    // Instance of API caller.
    let myAPICaller = APICaller()
    
    // Data dowloaded from API
    var currencyArray = [currencyModel]()
    var dataDowloadedDate: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        myAPICaller.delegate = self
        myAPICaller.getData(from: "https://api.nbp.pl/api/exchangerates/tables/A/?format=json")
    }


}

// MARK: - Article Model Protocool/ Delgate Methods

// Adapt APIProtocol to retrieve data from APICaller
extension ViewController: APIProtocol {
    
    // Retrieve data. From now data is no logner a list of APIData but single APIData.
    func dataRetrieved(_ retrievedData:APIData) {
        // Set data.
        self.currencyArray = retrievedData.rates
        self.dataDowloadedDate = retrievedData.effectiveDate
        
        print("VC: number of currencies: \(currencyArray.count)")
        print("VC: date of dowloaded data: \(dataDowloadedDate)")
    }
}
