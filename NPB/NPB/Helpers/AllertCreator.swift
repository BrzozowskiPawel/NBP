//
//  AllertCreator.swift
//  NPB
//
//  Created by Paweł Brzozowski on 14/01/2022.
//

import Foundation
import UIKit

// This functions is responsible for creating and returning alert.
// Allert are custom designed via specyfic parameters
func createCustomAllert(alertTitle alertTitleString: String, alertMessage alertMess: String, actionTitle actionTitleString: String) -> UIAlertController {
    // Create an allert
    let alert = UIAlertController(title: alertTitleString, message: alertMess, preferredStyle: .alert)
    // Add action to the allert - this is only information kind allert
    alert.addAction(UIAlertAction(title: actionTitleString, style: .default, handler: nil))
    
    // return created allert
    return alert
}
