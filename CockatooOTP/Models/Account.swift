//
//  Account.swift
//  Cockatoo
//
//  Created by Shumin Kong on 29/6/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import Foundation
import SwiftUI
import CoreLocation
import SwiftOTP

struct Account: Hashable, Codable, Identifiable {

    
    let service: String
    let account: String
    let key: String
    let interval: Int
    let digits: Int
    let totp: TOTP?
    
    var id: String {
        return key
    }
    
    private enum CodingKeys: String, CodingKey {
        case service
        case account
        case key
        case interval
        case digits
    }

    
    init(service: String, account: String, key: String, interval: Int, digits: Int) {
        
        self.service = service
        self.account = account
        self.key = key
        self.interval = interval
        self.digits = digits
        let data = base32DecodeToData(key.replacingOccurrences(of: " ", with: ""))

        self.totp = TOTP(secret: data!, digits: self.digits, timeInterval: self.interval)!

    }
    
    init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.service = try values.decode(String.self, forKey: .service)
        self.account = try values.decode(String.self, forKey: .account)
        self.key = try values.decode(String.self, forKey: .key)
        self.interval = try values.decode(Int.self, forKey: .interval)

        self.digits = try values.decode(Int.self, forKey: .digits)

        let data = base32DecodeToData(self.key.replacingOccurrences(of: " ", with: ""))
        self.totp = TOTP(secret: data!, digits: self.digits, timeInterval: self.interval)!

    }
    
    func getOTP(time: UInt64) -> String {
        guard self.totp != nil else {
            return "nil"
        }
        
        guard let otpString = self.totp?.generate(secondsPast1970: Int(time))! else { return "Error" }
        return otpString
    }
        
    func progress(time: Binding<Int>) -> Float {
        return Float(time.wrappedValue % self.interval) / Float(self.interval)
    }

    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.service == rhs.service &&
               lhs.account == rhs.account &&
               lhs.key == rhs.key &&
                lhs.interval == rhs.interval &&
                lhs.digits == rhs.digits
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(service)
        hasher.combine(account)
        hasher.combine(key)
        hasher.combine(interval)
        hasher.combine(digits)
    }

}


