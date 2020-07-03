//
//  HeaderBar.swift
//  Cockatoo
//
//  Created by Shumin Kong on 30/6/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import SwiftUI
import CodeScanner
import os

struct HeaderBar: View {
//    @State var query:String = ""
    @State var showAddMenu: Bool = false
    @State var isActionViewPresented = false
    @State var isSettingViewPresented = false
    @State var alertText:String = ""
    @State var isAlertPresented = false
    @State var data: [String:String] = ["":""]
    @State var actionViewMode = ActionViewMode.qr
    @Binding var search: String
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        
        HStack {
            Button(action: {
                self.isSettingViewPresented.toggle()
            }) {
                Image(systemName: "gear")
            }.sheet(isPresented: $isSettingViewPresented, content: {
                SettingView()
            })
            TextField("Search", text:$search)
                .padding()
                .cornerRadius(10)
                .border(Color.secondary)
            Button(action: {
                self.showAddMenu.toggle()
            }) {
                Image(systemName: "plus")
            }.actionSheet(isPresented: self.$showAddMenu) {
                ActionSheet(title: Text("Where do you want to import from?"), buttons: [.default(Text("QR Code"), action: {
                        self.actionViewMode = .qr
                        self.isActionViewPresented = true}),
                     .default(Text("Manual"), action: {
                        self.actionViewMode = .manual
                        self.isActionViewPresented = true}),
                     .destructive(Text("Cancel"))])
            }.sheet(isPresented: $isActionViewPresented) {
                if self.actionViewMode == .manual {
                    ManualView(callback: {
                        self.isActionViewPresented = false
                    }).environment(\.managedObjectContext, self.managedObjectContext)
                } else if self.actionViewMode == .qr {
                    CodeScannerView(codeTypes: [.qr], completion: self.handleScan)
                } else {
                    ManualView(service: self.data["issuer"]!,
                               account: self.data["path"]!,
                               key: self.data["secret"]!,
                               interval: self.data["period"]!,
                               digits: self.data["digits"]!,
                               callback: {
                                   self.isActionViewPresented = false
                               })
                        .environment(\.managedObjectContext, self.managedObjectContext)
                }
            }.alert(isPresented: $isAlertPresented) {
                Alert(title: Text("Scanning Error"), message: Text(self.alertText), dismissButton: .default(Text("OK")))
            }
            
            
        }.frame(maxWidth: .infinity,
                minHeight: 36)
        .padding()
        
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        self.isActionViewPresented = false
        switch result {
            case .success(let code):
                print(code)
                self.data = validate(code: code)
                if self.data != [:] {
                    self.actionViewMode = .qrDone
                    self.isActionViewPresented = true
                } else {
                    self.isActionViewPresented = false
                    self.isAlertPresented = true
                }
            case .failure(let error):
                print(error)
                print("Scanning failed")
        }
    }
    
    func validate(code: String ) -> [String:String]  {
        guard let url = URL(string:code) else {
            self.alertText = "Invalid QR code."
            self.isActionViewPresented = false
            self.isAlertPresented = true
            return [:]

        }
        let data = url.params()
        var result = [String:String]()
        print(data)
        guard data["issuer"] != nil else {
            self.alertText = "Invalid issuer."
            return [:]
        }
        result["issuer"] = data["issuer"] as? String
        
        guard data["path"] != nil else {
            self.alertText = "Invalid path."
            return [:]
        }
        result["path"] = data["path"] as? String
        result["path"]?.removeFirst()
        
        guard data["secret"] != nil else {
            self.alertText = "Invalid key."
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
        print("result")

        print(result)
        print(type(of: result))
        return result
    }
}

enum ActionViewMode {
    case qr
    case manual
    case qrDone
}
//CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson\npaul@hackingwithswift.com", completion: self.handleScan)
//extension ActionViewMode {
//    var view: some View {
//        switch self {
//            case .qr: return ManualView()
//            case .manual: return ManualView()
//        }
//    }
//}


//struct HeaderBar_Previews: PreviewProvider {
//    static var previews: some View {
//        HeaderBar()
//    }
//}
