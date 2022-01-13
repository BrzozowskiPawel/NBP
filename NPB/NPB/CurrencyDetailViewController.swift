//
//  CurrencyDetailViewController.swift
//  NPB
//
//  Created by Paweł Brzozowski on 13/01/2022.
//

import UIKit

class CurrencyDetailViewController: UIViewController {

    // Storing data abour currency to dispaly
    var currencyToDisplay: currencyModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("LAST SCREEN: \(currencyToDisplay)")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
