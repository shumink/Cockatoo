//
//  Utility.swift
//  CockatooOTP
//
//  Created by Shumin Kong on 2/7/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import Foundation



extension URL {
  func params() -> [String:Any] {
    var dict = [String:String]()

    if let components = URLComponents(url: self, resolvingAgainstBaseURL: true) {
        dict["host"] = components.host
        dict["path"] = components.path
      if let queryItems = components.queryItems {
        for item in queryItems {
          dict[item.name] = item.value!
        }
      }
      return dict
    } else {
      return [:]
    }
  }
}
