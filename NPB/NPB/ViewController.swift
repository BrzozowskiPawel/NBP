//
//  ViewController.swift
//  NPB
//
//  Created by Paweł Brzozowski on 12/01/2022.
//

import UIKit

class ViewController: UIViewController {

    let myAPICaller = APICaller()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        myAPICaller.getData(from: "https://api.nbp.pl/api/exchangerates/tables/A/?format=json")
    }


}

