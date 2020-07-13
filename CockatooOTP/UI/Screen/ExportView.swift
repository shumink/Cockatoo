//
//  ExportView.swift
//  CockatooOTP
//
//  Created by Shumin Kong on 12/7/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import SwiftUI
import os

struct ExportView: View {
    let accountsPerImage: Int = 8
    let attemptID: Int32 = Int32.random(in:Int32.min ... Int32.max)
    var fetchRequest: FetchRequest<Account>
    @State var qrImage: UIImage = UIImage()
    @State var idx: Int = 0
    @EnvironmentObject var timeManager: TimeManager
    @Environment(\.managedObjectContext) var managedObjectContext
    var nImages:Int {
        Int(ceil(Float(self.fetchRequest.wrappedValue.count) / Float(accountsPerImage)))
    }
//    var images = Array<UIImage>()
//    var
//    var lazyImages: LazyMapSequence<Array<Int>, UIImage>
//    @State var lazyImages: LazyMapSequence<Array<Int>, UIImage> = Array(0...99).lazy.map{_ in UIImage()}
//    lazy var fibonacciOfAge: UIImage = {
//        return UIImage()
//    }()

    init() {
        self.fetchRequest = FetchRequest<Account> (
            entity: Account.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Account.favTime, ascending: false),
                NSSortDescriptor(keyPath: \Account.createdTime, ascending: false),
            ]
        )
    }
    
    func accounts2Image(index: Int) -> UIImage {
        var accounts: [Account] = []
        self.fetchRequest.wrappedValue
            .prefix((index+1)*accountsPerImage)
            .dropFirst((index)*accountsPerImage)
            .forEach { each in
            accounts.append(each)
        }
        os_log("Exporting %d accounts", accounts.count)
        guard let data = try? exportToGoogleAuth(accounts:accounts, index: Int32(index), batch_size: Int32(nImages), id: attemptID) else {
            return UIImage()
        }
        let exportedString = "otpauth-migration://offline?data=\(data)"
        return generateQRCode(from: exportedString)
    }

    var body: some View {
        VStack {
            if nImages == 1 {
                Text("Open the app, and scan this code.").font(.title).frame(height: 100)
            } else {
                if idx != nImages-1 {
                    Text("Open the app, and scan the code \(idx+1) of \(nImages).").font(.title).frame(height: 100)
                } else {
                    Text("Finally, scan the last code.").font(.title).frame(height: 100)
                }
            }
            Image(uiImage: self.qrImage)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .transition(.scale)
                .onAppear {
                    self.qrImage = self.accounts2Image(index: self.idx)
                }
            
            if nImages > 1 && idx != nImages-1 {
                Button(action: {
                    if self.idx < self.nImages {
                        self.idx += 1
                        self.qrImage = self.accounts2Image(index: self.idx)
                    }
                }, label: {Text("Next")})
                .disabled(self.idx>=nImages-1)
            }
            Spacer()
        }.padding()
    }
}

struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        ExportView()
    }
}
