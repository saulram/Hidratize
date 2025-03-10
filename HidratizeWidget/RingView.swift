//
//  RingView.swift
//  Hidratize
//
//  Created by Saul Ramirez  on 06/11/24.
//

import SwiftUI

struct RingView: View {
    var progress: Double
    var ringColor: Color
    var title: String

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .foregroundColor(ringColor)

                Circle()
                    .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .foregroundColor(ringColor)
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.linear, value: progress)
            }
            .frame(width: 70, height: 70)

            Text(title)
                .font(.caption)
        }
    }
}
