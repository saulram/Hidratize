//
//  AddWaterIntent.swift
//  Hidratize
//
//  Created by Saul Ramirez  on 06/11/24.
//


import AppIntents
import WidgetKit

struct AddWaterIntent: AppIntent {
    static var title: LocalizedStringResource = "Agregar Agua"

    static var description = IntentDescription("Agrega una cantidad de agua definida a tu registro de hidratación.")

    @Parameter(title: "Cantidad de Agua (ml)")
    var amount: Int

    func perform() async throws -> some IntentResult {
        let sharedDefaults = UserDefaults(suiteName: "group.com.disolutionsmx.Hidratize")
        let currentProgress = sharedDefaults?.double(forKey: "hydrationProgress") ?? 0.0
        let dailyGoal = sharedDefaults?.double(forKey: "dailyHydrationGoal") ?? 2000.0 // Ejemplo: 2000 ml

        let newProgress = currentProgress + Double(amount)
        sharedDefaults?.set(newProgress, forKey: "hydrationProgress")

        // Notificar al widget para que se actualice
        WidgetCenter.shared.reloadAllTimelines()

        // Opcional: Actualizar datos en la base de datos o notificar a la aplicación principal

        return .result()
    }
}
