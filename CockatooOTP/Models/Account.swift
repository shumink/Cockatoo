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
import os

class Account: NSObject, Codable, Identifiable, NSCoding {

    

    let id: UUID
    let service: String
    let account: String
    let key: String
    let interval: Int
    let digits: Int
    let totp: TOTP?
//    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
//    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("Accounts")
    
    private enum CodingKeys: String, CodingKey {
        case id
        case service
        case account
        case key
        case interval
        case digits
    }
    
    private struct PropertyKey {
        static let id = "id"
        static let service = "service"
        static let account = "account"
        static let key = "key"
        static let interval = "interval"
        static let digits = "digits"
    }

    
    init(service: String, account: String, key: String, interval: Int, digits: Int) {
        self.id = UUID()
        self.service = service
        self.account = account
        self.key = key
        self.interval = interval
        self.digits = digits
        let data = base32DecodeToData(key.replacingOccurrences(of: " ", with: ""))

        self.totp = TOTP(secret: data!, digits: self.digits, timeInterval: self.interval)!

    }
    
    init(id: UUID, service: String, account: String, key: String, interval: Int, digits: Int) {
        self.id = UUID()
        self.service = service
        self.account = account
        self.key = key
        self.interval = interval
        self.digits = digits
        let data = base32DecodeToData(key.replacingOccurrences(of: " ", with: ""))

        self.totp = TOTP(secret: data!, digits: self.digits, timeInterval: self.interval)!

    }
    
    required init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.service = try values.decode(String.self, forKey: .service)
        self.account = try values.decode(String.self, forKey: .account)
        self.key = try values.decode(String.self, forKey: .key)
        self.interval = try values.decode(Int.self, forKey: .interval)

        self.digits = try values.decode(Int.self, forKey: .digits)
        if let id = try values.decode(UUID.self, forKey: .id) as UUID? {
            self.id = id
        } else {
            self.id = UUID()
        }

        
        let data = base32DecodeToData(self.key.replacingOccurrences(of: " ", with: ""))
        self.totp = TOTP(secret: data!, digits: self.digits, timeInterval: self.interval)!
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.id, forKey: PropertyKey.id)
        coder.encode(self.service, forKey: PropertyKey.service)
        coder.encode(self.account, forKey: PropertyKey.account)
        coder.encode(self.key, forKey: PropertyKey.key)
        coder.encode(self.interval, forKey: PropertyKey.interval)
        coder.encode(self.digits, forKey: PropertyKey.digits)

    }
    
    required convenience init?(coder: NSCoder) {
        guard let id = coder.decodeObject(forKey: PropertyKey.id) as? UUID else {
            os_log("Unable to decode the ID.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let service = coder.decodeObject(forKey: PropertyKey.service) as? UUID else {
            os_log("Unable to decode the service.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let account = coder.decodeObject(forKey: PropertyKey.account) as? UUID else {
            os_log("Unable to decode the account.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let key = coder.decodeObject(forKey: PropertyKey.key) as? UUID else {
            os_log("Unable to decode the key.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let interval = coder.decodeObject(forKey: PropertyKey.interval) as? UUID else {
            os_log("Unable to decode the interval.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let digits = coder.decodeObject(forKey: PropertyKey.digits) as? UUID else {
            os_log("Unable to decode the digits.", log: OSLog.default, type: .debug)
            return nil
        }
        
        self.init(id, service, account, key, interval, digits)

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


