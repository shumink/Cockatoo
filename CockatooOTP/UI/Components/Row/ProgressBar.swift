//
//  ProgressBar.swift
//  Cockatoo
//
//  Created by Shumin Kong on 30/6/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import SwiftUI


struct ProgressBar: View {
    var progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color.secondary)
                if self.progress > 0 {
                    Rectangle().frame(width: min(CGFloat(self.progress)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                        .foregroundColor(Color.primary)
                        .animation(.linear(duration: 1))

                }
            }.cornerRadius(45.0)
        }
    }
}
