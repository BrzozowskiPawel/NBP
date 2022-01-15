//
//  AllertCreator.swift
//  NPB
//
//  Created by Paweł Brzozowski on 14/01/2022.
//

import Foundation
import UIKit

func createCustomAllert(alertTitle alertTitleString: String, alertMessage alertMess: String, actionTitle actionTitleString: String) -> UIAlertController {
    let alert = UIAlertController(title: alertTitleString, message: alertMess, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: actionTitleString, style: .default, handler: nil))
    
    return alert
}
