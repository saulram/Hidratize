//
//  RingView.swift
//  Hidratize
//
//  Created by Saul Ramirez on 04/11/24.
//
import SwiftUI

struct RingSegment: View {
    var gradient: AngularGradient
    var progress: Double // Entre 0 y 1
    var lineWidth: CGFloat
    var size: CGFloat
    var opacity: Double

    var body: some View {
        Circle()
            .trim(from: 0, to: CGFloat(min(max(progress, 0), 1)))
            .stroke(gradient.opacity(opacity), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            .rotationEffect(.degrees(-90))
            .frame(width: size, height: size)
            // Primera sombra: más oscura y difuminada
            .shadow(color: Color.black.opacity(0.2), radius: 5.0, x: 4.0, y: 4.0)
            // Segunda sombra: más clara y cercana
            .shadow(color: Color.black.opacity(0.4), radius: 3.0, x: -2.0, y: -2.0)
    }

}

struct RingView: View {
    var gradient: AngularGradient
    var progress: Double // Puede exceder 1
    var lineWidth: CGFloat = 20
    var size: CGFloat
    var maxOpacityDecrease: Double = 0.2 // Máxima disminución de opacidad por vuelta
    var minOpacity: Double = 0.3 // Opacidad mínima para cualquier segmento

    var body: some View {
        ZStack {
            // Círculo de fondo para referencia
            Circle()
                .stroke(gradient.opacity(0.2), lineWidth: lineWidth)
                .frame(width: size, height: size)
            
            // Calcular el número de vueltas completas y el progreso restante
            let fullLoops = Int(progress)
            let partialProgress = progress.truncatingRemainder(dividingBy: 1)
            
            // Dibujar vueltas completas con opacidades decrecientes
            ForEach(0..<min(fullLoops, 10), id: \.self) { loop in
                RingSegment(
                    gradient: gradient,
                    progress: 1.0,
                    lineWidth: lineWidth,
                    size: size,
                    opacity: max(1.0 - Double(loop) * maxOpacityDecrease, minOpacity)
                )
            }
            
            // Dibujar el segmento parcial, si existe
            if partialProgress > 0 {
                RingSegment(
                    gradient: gradient,
                    progress: partialProgress,
                    lineWidth: lineWidth,
                    size: size,
                    opacity: max(1.0 - Double(fullLoops) * maxOpacityDecrease, minOpacity)
                )
            }
        }
        .animation(.easeOut, value: progress)
    }
}

struct RingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            RingView(
                gradient: AngularGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple, Color.blue]),
                    center: .center
                ),
                progress: 0.75,
                size: 150
            )
            .previewLayout(.sizeThatFits)
            .padding()
            
            RingView(
                gradient: AngularGradient(
                    gradient: Gradient(colors: [Color.green, Color.yellow, Color.green]),
                    center: .center
                ),
                progress: 1.5,
                size: 150
            )
            .previewLayout(.sizeThatFits)
            .padding()
            
            RingView(
                gradient: AngularGradient(
                    gradient: Gradient(colors: [Color.red, Color.orange, Color.red]),
                    center: .top
                ),
                progress: 3.25,
                size: 150
            )
            .previewLayout(.sizeThatFits)
            .padding()
        }
    }
}
