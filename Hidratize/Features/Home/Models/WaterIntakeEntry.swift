//
//  WaterIntakeEntry.swift
//  Hidratize
//
//  Created by Saul Ramirez  on 04/11/24.
//


import Foundation

struct WaterIntakeEntry: Identifiable {
    let id: UUID
    let amount: Double
    let timestamp: Date
}

