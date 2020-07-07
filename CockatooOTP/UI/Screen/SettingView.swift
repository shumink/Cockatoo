//
//  SettingView.swift
//  CockatooOTP
//
//  Created by Shumin Kong on 3/7/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import SwiftUI
import CoreData
import CodeScanner

struct SettingView: View {
    @State var isScannerActive: Bool = false
    @Environment(\.managedObjectContext) var managedObjectContext

    
    var body: some View {
        NavigationView {
            Form {
                Section(footer: Text("BTC Address goes here")) {
                    Text("Hello World")
                }
                
                Section(header: Text("Migration")) {
                    NavigationLink(destination: CodeScannerView(codeTypes: [.qr],
                                                                completion: self.handleScan),
                                   isActive: $isScannerActive) {
                        Text("Import from Google Authenticator")

                    }
                }
            }.navigationBarTitle("Settings", displayMode: .inline)
        }
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
//        self.isActionViewPresented = false
        switch result {
            case .success(let code):
                print(code)
                do {
                    let data = try unpackGoogleAuthScanned(code: code)
                    let imported = importFromGoogleAuth(code: data, moc: self.managedObjectContext)
                    print("imported")
                    print(imported)
                    self.isScannerActive = false
                } catch (let e) {
                    print(e)
                }
//                self.data = validate(code: code)
//                print(self.data)
//                print(self.alertText)
//                if self.data != [:] {
//                    self.actionViewMode = .qrDone
//                    self.isActionViewPresented = true
//                }
            case .failure(let error):
                print(error)
                print("Scanning failed")
        }

    }
}

extension String: Error {}


struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}

func unpackGoogleAuthScanned(code: String) throws -> String {
    guard let url = URL(string:code) else {
        throw "invalid sacnned result"

    }
    let data = url.params()
    return data["data"] as! String
}
