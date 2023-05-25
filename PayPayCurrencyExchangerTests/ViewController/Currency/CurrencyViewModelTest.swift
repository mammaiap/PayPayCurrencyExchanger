//
//  CurrencyViewModelTest.swift
//  PayPayCurrencyExchanger
//
//  Created by muthulingam on 22/05/23.
//

import XCTest
@testable import PayPayCurrencyExchanger

class CurrencyViewModelTest: XCTestCase {
    
    class MockPersistanceStore: PersistanceStorable {
        var exchangeRate: ExchangeRate?
        
        init(_ rate: [String: Double] = [:]) {
            self.exchangeRate = ExchangeRate(
                disclaimer: "",
                license: "",
                timestamp: 0,
                base: "",
                rates: rate)
        }
    }
    
    func test_pickerData() throws {
        // Arrange
        let rate: [String: Double] = ["A": 0, "B": 1, "C": 2]
        let vm = CurrencyViewModel(store: MockPersistanceStore(rate))
        // Act
        let pickerData = vm.pickerData
        // Asset
        XCTAssertEqual(pickerData, ["A", "B", "C"])
    }
    
    func test_exchangeCurrency_fromTWDToUSDnJPY() throws {
        // Arrange
        let rate: [String: Double] = [
            "TWD": 31.5,
            "USD": 1.0,
            "JPY": 145.0
        ]
        let vm = CurrencyViewModel(
            store: MockPersistanceStore(rate),
            defaultCountry: "TWD"
        )
        let twd = 31.5
        // Act
        let usd = vm.exchangeCurrency(amount: twd, to: "USD")
        let jpy = vm.exchangeCurrency(amount: twd, to: "JPY")
        // Assert
        XCTAssertEqual(usd, "1.00000")
        XCTAssertEqual(jpy, "145.00000")
    }
    
    func test_exchangeCurrency_findNoCountryShouldReturnNaN() throws {
        // Arrange
        let rate: [String: Double] = [
            "TWD": 31.5
        ]
        let vm = CurrencyViewModel(
            store: MockPersistanceStore(rate),
            defaultCountry: "TWD"
        )
        let twd = 31.5
        let noSuchCountry = "NoSuchCountry"
        // Act
        let nan = vm.exchangeCurrency(
            amount: twd,
            to: noSuchCountry
        )
        // Assert
        XCTAssertEqual(nan, "NaN")
    }
    
    func test_updateCurrencyCellViewModels_byChangeCountry() throws {
        // Arrange
        let rate: [String: Double] = [
            "TWD": 31.5,
            "USD": 1.0,
            "JPY": 145.0
        ]
        let vm = CurrencyViewModel(
            store: MockPersistanceStore(rate),
            defaultCountry: "TWD",
            defaultAmount: "0"
        )
        // Act
        vm.pickedCountry = "USD"
        // Assert
        let cell0 = try XCTUnwrap(vm.currencyCellVM[safe: 0])
        XCTAssertEqual(cell0.country, "JPY")
        XCTAssertEqual(cell0.amount, "0.00000")
        let cell1 = try XCTUnwrap(vm.currencyCellVM[safe: 1])
        XCTAssertEqual(cell1.country, "TWD")
        XCTAssertEqual(cell1.amount, "0.00000")
        let cell2 = try XCTUnwrap(vm.currencyCellVM[safe: 2])
        XCTAssertEqual(cell2.country, "USD")
        XCTAssertEqual(cell2.amount, "0.00000")
    }
    
    func test_updateCurrencyCellViewModels_byChangeAmount() throws {
        // Arrange
        let rate: [String: Double] = [
            "TWD": 31.5,
            "USD": 1.0,
            "JPY": 145.0
        ]
        let vm = CurrencyViewModel(
            store: MockPersistanceStore(rate),
            defaultCountry: "USD",
            defaultAmount: "0"
        )
        // Act
        vm.amount = "1.0"
        // Assert
        let cell0 = try XCTUnwrap(vm.currencyCellVM[safe: 0])
        XCTAssertEqual(cell0.country, "JPY")
        XCTAssertEqual(cell0.amount, "145.00000")
        let cell1 = try XCTUnwrap(vm.currencyCellVM[safe: 1])
        XCTAssertEqual(cell1.country, "TWD")
        XCTAssertEqual(cell1.amount, "31.50000")
        let cell2 = try XCTUnwrap(vm.currencyCellVM[safe: 2])
        XCTAssertEqual(cell2.country, "USD")
        XCTAssertEqual(cell2.amount, "1.00000")
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
