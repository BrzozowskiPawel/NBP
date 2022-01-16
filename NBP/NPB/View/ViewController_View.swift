//
//  ViewControllerView.swift
//  NBP
//
//  Created by Paweł Brzozowski on 16/01/2022.
//

import Foundation

// MARK: - Creating and destroying initial download spinner // This spinner is being shown when data is being downloaded not refreshed by the user.
extension ViewController {
    // Create a download spinner
    func createAndStartDowloadSpinner() {
        // If it's not a manual refresh by user then show downloading spinner.
        if !refreshingIsActive {
            // NOTE: refreshingIsActive is a flag that corresponds to pull to the refresh.
            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.startAnimating()
            view.addSubview(spinner)

            // Place spinner on center of the View.
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        }
    }
    
    // Destroy a download spinner
    func stopAndDestroySpinner() {
        // Make sure that this is initial download not manual refreshing by user (if it is, then no spinner will be created).
        // If is manual refreshing than flag refreshingIsActive should be true.
        if !refreshingIsActive {
            spinner.stopAnimating()
            spinner.removeFromSuperview()
        }
    }
}

// MARK: - Navigation controller hiding/showing control appearance of NavigationController.
// In the first View navigation controller shouldn't be visible.
extension ViewController {
    // Turn off showing Navigation Controller on loading this VC
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // When a user leaves this VC tun on showing Navigation Controller
    // On the next screen title is required.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
