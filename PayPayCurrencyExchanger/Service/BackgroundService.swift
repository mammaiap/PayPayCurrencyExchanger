//
//  BackgroundService.swift
//  PayPayCurrencyExchanger
//
//  Created by muthulingam on 22/05/23.
//

import Foundation

protocol BackgroundPollingTask {
    var completion: (() -> Void)? { get set }
    var repeatingTimeInterval: Int { get }
    func shouldApply(by timeInterval: Int) -> Bool
    func apply()
}

//MARK: Background Service 
class BackgroundService {
    private enum TimerState: Equatable {
        case resumed
        case suspended
        case cancelled
    }
    //MARK: Private Property
    private var state: TimerState = .suspended
    
    private let timer: DispatchSourceTimer = {
        let queue = DispatchQueue(
            label: "BackgroundService.Timer",
            qos: .background
        )
        return DispatchSource.makeTimerSource(queue: queue)
    }()
    
    private let repeatingTimeInterval: DispatchTimeInterval = .seconds(30)
    
    var tasks: [BackgroundPollingTask]
    
    //MARK: init
    init(tasks: [BackgroundPollingTask] = []) {
        self.tasks = tasks
    }
    
    deinit {
        cancel()
    }
    
    //MARK: Method
    func startService() {
        timer.schedule(
            deadline: .now(),
            repeating: repeatingTimeInterval
        )

        timer.setEventHandler(qos: .background) { [weak self] in
            guard let self = self,
                  case let .seconds(secondTimeInterval) = self.repeatingTimeInterval
            else { return }
            self.suspend()
            self.tasks.forEach { task in
                if task.shouldApply(by: secondTimeInterval) { task.apply() }
            }
            self.resume()
        }

        resume()
    }
    
    func stopService() {
        suspend()
    }
}


// MARK: - Private Methods
fileprivate extension BackgroundService {
    func resume() {
        guard state != .resumed else { return }
        timer.resume()
        state = .resumed
    }
    
    func suspend() {
        guard state != .suspended else { return }
        timer.suspend()
        state = .suspended
    }
    
    func cancel() {
        guard state != .cancelled else { return }
        
        if state != .resumed {
            resume()
        }

        timer.cancel()
        state = .cancelled
    }
}
