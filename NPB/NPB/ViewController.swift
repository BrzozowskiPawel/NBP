//
//  ViewController.swift
//  NPB
//
//  Created by Paweł Brzozowski on 12/01/2022.
//

import UIKit

class ViewController: UIViewController {

    let MyAPICaller = APICaller()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        MyAPICaller.getData(from: "https://api.nbp.pl/api/exchangerates/tables/A/?format=json")
    }


}

