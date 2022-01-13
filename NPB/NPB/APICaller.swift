//
//  APICaller.swift
//  NPB
//
//  Created by Paweł Brzozowski on 12/01/2022.
//

import Foundation

protocol APIProtocol {
    func dataRetrieved(_ retrievedStandartData:APIData?, retrievedTimelinetData: APIDataTimeline?)
}

class APICaller {
    // Deleagate-Protocol pattern to retrieve data
    var delegate: APIProtocol?
    
    // Make an API call
    func getData(from urlString: String) {
        // Create a URL object
        let url = URL(string: urlString)
        
        // By default use ris reguesting A, B or C table from API
        var timelineRatesReguest = false
        
        // If link is directing to the rates data, change this parametr.
        // Changing reatesrequest to true will use different struct with JSON decodin.
        if urlString.contains("rates") {
            print("RATES TYPE REQUEST")
            timelineRatesReguest = true
        }
        
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
                    // Parse the JSON into the desired structure.
                    if timelineRatesReguest {
                        print("Standart request")
                        let APIResponseStandart = try decoder.decode([APIData].self, from: data!)
                        
                        // Everything connected with UI should be in main thread
                        DispatchQueue.main.async {
                            // Parse the returned JSON into article instances and pass it back to the view controller with the protocol and deleagte pattern
                            // Std response is a list of APIData structs. Hoever only first item contains data.
                            self.delegate?.dataRetrieved(APIResponseStandart[0], retrievedTimelinetData: nil)
                        }
                        
                    } else {
                        print("Timeline request")
                        let APIResponseTimeline = try decoder.decode(APIDataTimeline.self, from: data!)
                        
                        // Everything connected with UI should be in main thread
                        DispatchQueue.main.async {
                            // Parse the returned JSON into article instances and pass it back to the view controller with the protocol and deleagte pattern
                            self.delegate?.dataRetrieved(nil, retrievedTimelinetData: APIResponseTimeline)
    //                        self.delegate?.dataRetrieved(APIResponse[0])
                        }
                    }
                    
                } catch {
                    print("Sorry there was and error while decoding JSON")
                }
            }
        }
        // Start the data task
        dataTask.resume()
        
    }
}
