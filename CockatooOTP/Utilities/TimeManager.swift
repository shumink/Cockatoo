//
//  TimeManager.swift
//  Cockatoo
//
//  Created by Shumin Kong on 29/6/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import Foundation
import SwiftUI
class TimeManager: ObservableObject {
    @Published var date = Date()
    
    var updateTimer: Timer {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true,
                             block: { _ in
                                self.date = Date()
                             })
    }
    var unixEpochTime: UInt64 {
        return UInt64(self.date.timeIntervalSince1970)
    }
    
    var unixEpochTimeBinding: Binding<Int> {
        var d = 1.0
        let bd = Binding<Double>(get: { d }, set: { d = $0 })
        let bi = Binding<Int>(get: { Int(self.date.timeIntervalSince1970) },
                              set: { bd.wrappedValue = Double($0) })
        return bi
    }
    

}
