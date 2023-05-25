//
//  ExchangeRateUpdateTaskTest.swift
//  PayPayCurrencyExchanger
//
//  Created by muthulingam on 22/05/23.
//

import XCTest
@testable import PayPayCurrencyExchanger

class ExchangeRateUpdateTaskTest: XCTestCase {

    class MockDataSource: ExchangeRateDataSource {
        let rate: [String: Double]
        func getExchangeRate(completion: @escaping (Result<ExchangeRate, Error>) -> Void) {
            let rate = ExchangeRate(
                disclaimer: "",
                license: "",
                timestamp: 0,
                base: "",
                rates: rate
            )
            completion(.success(rate))
        }
        
        init(rate: [String: Double]) {
            self.rate = rate
        }
    }
    
    class MockPersistanceStore: PersistanceStorable {
        var exchangeRate: ExchangeRate? = nil
    }

    func test_shouldApplyForFirstTime_shouldReturnTrue() throws {
        // Arrange
        let task = ExchangeRateUpdateTask(
            dataSource: MockDataSource(rate: [:]),
            persistanceStore: MockPersistanceStore()
        )
        let timeInterval = 0
        // Act
        let firstFire = task.shouldApply(by: timeInterval)
        // Assert
        XCTAssertTrue(firstFire)
    }
    func test_shouldApplyForSecondTime_withShortOfTimeInterval_shouldReturnFalse() throws {
        // Arrange
        let task = ExchangeRateUpdateTask(
            dataSource: MockDataSource(rate: [:]),
            persistanceStore: MockPersistanceStore()
        )
        let timeInterval = 10
        // Act
        let _ = task.shouldApply(by: timeInterval)
        let secondFire = task.shouldApply(by: timeInterval)
        // Assert
        XCTAssertFalse(secondFire)
    }
    
    func test_shouldApplyForSecondTime_withEnoughTimeInterval_shouldReturnTrue() throws {
        // Arrange
        let task = ExchangeRateUpdateTask(
            dataSource: MockDataSource(rate: [:]),
            persistanceStore: MockPersistanceStore()
        )
        let timeInterval = 31*60
        // Act
        let _ = task.shouldApply(by: timeInterval)
        let secondFire = task.shouldApply(by: timeInterval)
        // Assert
        XCTAssertTrue(secondFire)
    }
    
    func test_applyGetExchangeRate_shouldWritePersistanceStore() throws {
        // Arrange
        let rate = ["USD": 1.0]
        let store = MockPersistanceStore()
        let task = ExchangeRateUpdateTask(
            dataSource: MockDataSource(rate: rate),
            persistanceStore: store
        )
        // Act
        task.apply()
        // Assert
        let exchangeRate = try XCTUnwrap(store.exchangeRate)
        XCTAssertEqual(exchangeRate.rates, rate)
    }
    
    func test_applyGetExchangeRate_shouldTriggerCompletion() throws {
        // Arrange
        let store = MockPersistanceStore()
        let exp = expectation(description: "wait for completion")
        let task = ExchangeRateUpdateTask(
            dataSource: MockDataSource(rate: [:]),
            persistanceStore: store,
            completion: {
                exp.fulfill()
            }
        )
        // Act
        task.apply()
        // Assert
        wait(for: [exp], timeout: 3)
        XCTAssertNotNil(store.exchangeRate)
    }
}
