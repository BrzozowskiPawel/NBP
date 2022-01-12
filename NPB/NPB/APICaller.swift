//
//  APICaller.swift
//  NPB
//
//  Created by Paweł Brzozowski on 12/01/2022.
//

import Foundation

class APICaller {
    
    
    // Make an API call
    func getData(from urlString: String) {
        // Create a URL object
        let url = URL(string: urlString)
        
        // Check that it isnt nil
        guard url != nil else {
            print("URL object is empty")
            return
        }
        
        // Get the URL Session
        let session = URLSession.shared
        
        // Crete the data task
        let dataTask = session.dataTask(with: url!) { data, response, error in
            // Chcech that there are no errors and there is data
            if error == nil && data != nil {
                // Attempt to parse the JSON
                let decoder = JSONDecoder()
                do {
                    // Parse the JSON into the desired structure
                    let APIResponse = try decoder.decode([APIData].self, from: data!)
                    print(APIResponse.count)
                    print(APIResponse[0].rates.count)
                    
                } catch {
                    print("Sorry there was and error while decoding JSON")
                }
            }
        }
        // Start the data task
        dataTask.resume()
        
    }
}
