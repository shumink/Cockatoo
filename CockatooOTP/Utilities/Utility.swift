//
//  Utility.swift
//  CockatooOTP
//
//  Created by Shumin Kong on 2/7/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit


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


func validateOTP(code: String) -> [String:String]  {
    guard let url = URL(string:code) else {
        return [:]

    }
    let data = url.params()
    var result = [String:String]()
    print(data)
    guard data["host"] != nil else {
        return [:]
    }
    result["host"] = data["host"] as? String

            
    guard data["path"] != nil else {
        return [:]
    }
    result["path"] = data["path"] as? String
    if (result["path"] != nil && result["path"] != "") {
        result["path"]?.removeFirst()
    }
            
    
    if data["issuer"] != nil {
        result["issuer"] = data["issuer"] as? String
    } else {
        if (result["path"]?.contains(":"))! {
            result["issuer"] = String(result["path"]!.split(separator: ":")[0])
            result["path"] = String(result["path"]!.split(separator: ":")[1])
        } else {
            result["issuer"] = ""
        }

    }

    
    guard data["secret"] != nil else {
        return [:]
    }
    result["secret"] = data["secret"] as? String

    if data["period"] == nil || NumberFormatter().number(from: data["period"] as! String) == nil {
        result["period"] = "30"
    } else {
        result["period"] = data["period"] as? String
    }
    
    if data["digits"] == nil || NumberFormatter().number(from: data["digits"] as! String) == nil {
        result["digits"] = "6"
    } else {
        result["digits"] = data["digits"] as? String
    }
    
    if data["counter"] == nil || NumberFormatter().number(from: data["counter"] as! String) == nil {
        result["counter"] = "0"
    } else {
        result["counter"] = data["counter"] as? String
    }
    return result
}

func generateQRCode(from string: String) -> UIImage {
    let filter = CIFilter.qrCodeGenerator()
    let context = CIContext()

    let data = Data(string.utf8)
    
    filter.setValue(data, forKey: "inputMessage")

    if let outputImage = filter.outputImage {
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgimg)
        }
    }

    return UIImage(systemName: "xmark.circle") ?? UIImage()
}
