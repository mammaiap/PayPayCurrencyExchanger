//
//  ExchangeRateUpdateTask.swift
//  PayPayCurrencyExchanger
//
//  Created by muthulingam on 22/05/23.
//

import Foundation

class ExchangeRateUpdateTask: BackgroundPollingTask {
    //MARK: Private Property
    private let dataSource: ExchangeRateDataSource
    private var persistanceStore: PersistanceStorable
    
    var completion: (() -> Void)?
    
    var repeatingTimeInterval: Int = 30*60
    private var accumulateTimeInterval: Int = 0
    
    //MARK: Method
    func shouldApply(by timeInterval: Int) -> Bool {
        if accumulateTimeInterval == 0 {
            accumulateTimeInterval += timeInterval
            return true // fire at first time
        }
        accumulateTimeInterval += timeInterval
        guard accumulateTimeInterval >= repeatingTimeInterval else { return false }
        accumulateTimeInterval = 0
        return true
    }
    
    func apply() {
        dataSource.getExchangeRate { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let exchangeRate):
                self.persistanceStore.exchangeRate = exchangeRate
            case .failure(let error):
                // TODO: Handle Error
                print(error)
            }
            self.completion?()
        }
    }
    
    //MARK: init
    init(
        dataSource: ExchangeRateDataSource = EndPointClient.shared,
        persistanceStore: PersistanceStorable = UserDefaultsStorable.shared,
        completion: (() -> Void)? = nil
    ) {
        self.dataSource = dataSource
        self.persistanceStore = persistanceStore
        self.completion = completion
    }
}

