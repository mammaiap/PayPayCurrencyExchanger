//
//  ExchangeRateDataSource.swift
//  PayPayCurrencyExchanger
//
//  Created by muthulingam on 22/05/23.
//

import Foundation

protocol ExchangeRateDataSource {
    func getExchangeRate(
        completion: @escaping (Result<ExchangeRate, Error>)-> Void
    )
}
// MARK: - EndPointRequest

class EndPointRequest {
    // MARK: - Property
    typealias Response = ExchangeRate
    
    var baseURL: String {
        "https://openexchangerates.org/api"
    }
    
    var path: String {
        "/latest.json"
    }
    
    var latestURL: String {
        baseURL+path+"?app_id=\(appID)"
    }
    
    
    private let appID: String
    
    init() {
        
        let plistDict = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Info", ofType: "plist") ?? "")
        
        self.appID = plistDict?["OpenExchangeRateAppID"] as? String ?? "ffdeaf66552a46938dcdacd742a58cd1"
    }
}

// MARK: - EndPointClient will fetch the data from the url
class EndPointClient: ExchangeRateDataSource {
    
    static let shared = EndPointClient()
    
    func getExchangeRate(
        completion: @escaping (Result<ExchangeRate, Error>)-> Void
    ) {
        let req = EndPointRequest()
        let urlString =  req.latestURL
        let request = URLRequest(url: URL(string: urlString)!)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
                   if let response = response {
                       print(response)
                   }
                   do {
                    let jsonData = try JSONDecoder().decode(ExchangeRate.self, from: data!)
                       print(jsonData)
                       completion(.success(jsonData))
                       
                   }
                   catch let error as NSError {
                       print(error)
                       completion(.failure(error))
                   }
               })
               task.resume()
        
    }
}
