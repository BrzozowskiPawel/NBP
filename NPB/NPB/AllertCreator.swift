//
//  AllertCreator.swift
//  NPB
//
//  Created by Paweł Brzozowski on 14/01/2022.
//

import Foundation
import UIKit

func createCustomAllert(alertTitle alertTitle: String, alertMessage alertMess: String, actionTitle actionTitle: String) -> UIAlertController {
    let alert = UIAlertController(title: alertTitle, message: alertMess, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
    
    return alert
}
