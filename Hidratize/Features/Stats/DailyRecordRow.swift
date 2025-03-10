//
//  DailyRecordRow.swift
//  Hidratize
//
//  Created by Saul Ramirez  on 04/11/24.
//


import SwiftUI

struct DailyRecordRow: View {
    var record: DailyRecord

    var body: some View {
        HStack {
            RingView(
                gradient: angularGradient,
                progress: progress,
                lineWidth: 16.0,
                size: 50
            )
            .frame(width: 50, height: 50)
            Spacer().frame(width: 20)

            VStack(alignment: .leading) {
                Text(formattedDate)
                    .font(.headline)
                Text("Meta: \(Int(record.dailyGoal)) ml")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text("Ingesta: \(Int(totalIntake)) ml")
                .font(.subheadline)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 5)
    }

    // Sub-vista o propiedades separadas
    var angularGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [Color.blue, Color.purple, Color.blue]),
            center: .center
        )
    }

    var progress: Double {
        guard record.dailyGoal > 0 else { return 0.0 }
        let total = record.waterIntakes?.reduce(0, { $0 + ($1 as AnyObject).amount }) ?? 0.0
        return total / record.dailyGoal
    }

    var totalIntake: Double {
        return record.waterIntakes?.reduce(0, { $0 + ($1 as AnyObject).amount }) ?? 0.0
    }

    var formattedDate: String {
        guard let date = record.date else { return "Fecha desconocida" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
