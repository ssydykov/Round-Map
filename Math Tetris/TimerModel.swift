//
//  TimerModel.swift
//  Math Tetris
//
//  Created by Saken Sydykov on 12.07.17.
//  Copyright © 2017 Strixit. All rights reserved.
//

import Foundation

class TimerModel: NSObject {
    static let sharedTimer: TimerModel = {
        let timer = TimerModel()
        return timer
    }()
    
    var internalTimer: Timer?
    var jobs = [() -> Void]()
    
    func startTimer(withInterval interval: Double, andJob job: @escaping () -> Void) {
        if internalTimer == nil {
            internalTimer?.invalidate()
        }
        jobs.append(job)
        internalTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(doJob), userInfo: nil, repeats: true)
    }
    
    func pauseTimer() {
        guard internalTimer != nil else {
            print("No timer active, start the timer before you stop it.")
            return
        }
        internalTimer?.invalidate()
    }
    
    func stopTimer() {
        guard internalTimer != nil else {
            print("No timer active, start the timer before you stop it.")
            return
        }
        jobs = [()->()]()
        internalTimer?.invalidate()
    }
    
    func doJob() {
        for job in jobs {
            job()
        }
    }
    
}
