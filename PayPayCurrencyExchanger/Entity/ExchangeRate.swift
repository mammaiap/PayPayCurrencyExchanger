//
//  ExchangeRate.swift
//  PayPayCurrencyExchanger
//
//  Created by muthulingam on 22/05/23.
//

import Foundation

// MARK: - ExchangeRate Response Model
struct ExchangeRate: Codable {
    let disclaimer: String
    let license: String
    let timestamp: Int
    let base: String
    let rates: [String: Double]
}

extension ExchangeRate: RawRepresentable {
    typealias RawValue = Data?
    
    init?(rawValue: Self.RawValue) {
        guard let data = rawValue,
              let instance = try? JSONDecoder()
            .decode(Self.self, from: data)
        else {
            return nil
        }
        self = instance
    }
    
    var rawValue: Self.RawValue {
        try? JSONEncoder().encode(self)
    }
}


