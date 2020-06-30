//
//  ProgressBar.swift
//  Cockatoo
//
//  Created by Shumin Kong on 30/6/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import SwiftUI
//struct ProgressBar: View {
//    var progress: Float
//    var body: some View {
//        ZStack {
//            Circle()
//                .stroke(lineWidth: 20.0)
//                .opacity(0.3)
//                .foregroundColor(Color.accentColor)
//            Circle()
//                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
//                .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
//                .foregroundColor(Color.accentColor)
//                .rotationEffect(Angle(degrees: 270.0))
//                .animation(.linear)
//        }
//    }
//}
//

struct ProgressBar: View {
    var progress: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color.secondary)
                
                Rectangle().frame(width: min(CGFloat(self.progress)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color.primary)
                    .animation(.linear)
            }.cornerRadius(45.0)
        }
    }
}
