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
    @State var migrationAlert: String = ""
    @State var isAlertPresent: Bool = false
    @Environment(\.managedObjectContext) var managedObjectContext

    
    var body: some View {
        NavigationView {
            Form {

                
                Section(header: Text("Migration")) {
                    NavigationLink(destination: CodeScannerView(codeTypes: [.qr],
                                                                completion: self.handleScan),
                                   isActive: $isScannerActive) {
                        Text("Import from Google Authenticator")
                    }
                }
                .alert(isPresented: self.$isAlertPresent, content: {
                    return Alert(title: Text("Account Migration"), message: Text(self.migrationAlert))
                })
            }.navigationBarTitle("Settings", displayMode: .inline)
        }
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        switch result {
            case .success(let code):
                print(code)
                do {
                    let data = try unpackGoogleAuthScanned(code: code)
                    let imported = importFromGoogleAuth(code: data, moc: self.managedObjectContext)
                    self.migrationAlert = "Succesfully imported \(imported) accounts."
                    self.isScannerActive = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.isAlertPresent = true
                    }
                } catch (let e) {
                    print(e)
                }
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
