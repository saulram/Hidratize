import Foundation

struct HydrationData {
    var totalIntake: Double // Total de agua consumida en mililitros

    mutating func addIntake(amount: Double) {
        totalIntake += amount
    }
}
