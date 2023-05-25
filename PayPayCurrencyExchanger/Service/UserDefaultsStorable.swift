//
//  UserDefaultsStorable.swift
//  PayPayCurrencyExchanger
//
//  Created by muthulingam on 22/05/23.
//

import Foundation

protocol PersistanceStorable {
    var exchangeRate: ExchangeRate? { get set }
}

class UserDefaultsStorable: PersistanceStorable {
    
    //MARK: Property
    static let shared = UserDefaultsStorable()
    
    private let store: UserDefaults
    
    //MARK: init
    init(_ store: UserDefaults = UserDefaults.standard) {
        self.store = store
    }
    
    private static let exchangeRateKey = "exchangeRate"
    var exchangeRate: ExchangeRate? {
        get {
            store.object(forKey: Self.exchangeRateKey)
        }
        set {
            guard let newValue = newValue else { return }
            store.set(newValue, for: Self.exchangeRateKey)
        }
    }
}

//MARK: extension
extension UserDefaults {
    func set<T: RawRepresentable>(_ value: T, for key: String) {
        set(value.rawValue, forKey: key)
    }
    
    func object<T: RawRepresentable>(forKey: String) -> T? {
        guard let rawValue = value(forKey: forKey) as? T.RawValue
        else { return nil }
        return T(rawValue: rawValue)
    }
}
