//
//  QRCodeScanner.swift
//  CockatooOTP
//
//  Created by Shumin Kong on 14/7/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import SwiftUI
import CodeScanner

struct QRCodeScanner: View {
    var title: String
    var callback: (Result<String, CodeScannerView.ScanError>) -> Void
    
    var body: some View {
        ZStack {
            CodeScannerView(codeTypes: [.qr], completion: self.callback)
            VStack {
                Text(title)
                    .foregroundColor(Color(.systemGray6))
                    .frame(height: 100)
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.systemGray6), lineWidth: 5)
                    .padding()
                    .frame(height: 300)
                Spacer()
            }
            .frame(width: 300)
            .padding()
        }

    }
}

struct QRCodeScanner_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeScanner(title: "Title",callback: {_ in })
    }
}
