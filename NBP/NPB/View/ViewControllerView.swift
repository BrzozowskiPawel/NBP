//
//  ViewControllerView.swift
//  NPB
//
//  Created by Paweł Brzozowski on 16/01/2022.
//

import Foundation

// MARK: - Creating and destroying initial dowload spinner
// This spinner is being shown when data is being dowloaded not refreshing by user.
extension ViewController {
    // Create a dowload spinner
    func createAndStartDowloadSpinner() {
        // If it's not a manula refresh by user then show dowloading spinner.
        if !refreshingIsActive {
            // NOTE: refreshingIsActive is a flag that coresponds to pull to the refresh.
            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.startAnimating()
            view.addSubview(spinner)

            // Place spinner on center of the View.
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        }
    }
    
    // Destroy a dowload spinner
    func stopAndDestroySpinner() {
        // Make sure that this is initial dowload not manual refreshing by user (if it is, than no spinner will be created).
        // If is manual refreshing than flag refreshingIsActive should be true.
        if !refreshingIsActive {
            spinner.stopAnimating()
            spinner.removeFromSuperview()
        }
    }
}

// MARK: - Navigation controller hiding/showing
// Controll apperience of NavigationController. In first View navigation controller shouldn't be visible.
extension ViewController {
    // Turn off showing Navigation Controller on loading this VC
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // When suer leaves this VC tun on showing Navigation Controller
    // On next screen title is requaired.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
