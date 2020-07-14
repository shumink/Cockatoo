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
import os

struct SettingView: View {
    @State var isScannerActive: Bool = false
    @State var migrationAlert: String = ""
    @State var isAlertPresent: Bool = false
    @EnvironmentObject var timeManager: TimeManager
    @Environment(\.managedObjectContext) var managedObjectContext

    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Migration")) {
                    NavigationLink(destination:
                        QRCodeScanner(title: "Point the camera at the QR code given by the Google Authenticator.", callback: self.handleScan),
                                   isActive: $isScannerActive) {
                        Text("Import from Google Authenticator")
                    }
                    NavigationLink(destination: ExportView().environment(\.managedObjectContext, managedObjectContext)) {
                        Text("Export to Google Authenticator")
                    }

                }
                .alert(isPresented: self.$isAlertPresent, content: {
                    return Alert(title: Text("Account Migration"), message: Text(self.migrationAlert))
                })
            }.navigationBarTitle("More", displayMode: .inline)
        }
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        switch result {
            case .success(let code):
                do {
                    let data = try unpackGoogleAuthScanned(code: code)
                    let imported = importFromGoogleAuth(code: data, moc: self.managedObjectContext)
                    self.migrationAlert = "Succesfully imported \(imported) accounts."
                    self.isScannerActive = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.isAlertPresent = true
                    }
                } catch (let e) {
                    os_log("%s", e.localizedDescription as String)
                }
            case .failure(let error):
                os_log("%s", error.localizedDescription)
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
