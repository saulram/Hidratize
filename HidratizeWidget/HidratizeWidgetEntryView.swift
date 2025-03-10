import AppIntents
import SwiftUI

struct HidratizeWidgetEntryView: View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            Color("WidgetBackground")
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    RingView(progress: entry.hydrationProgress, ringColor: .blue, title: "Hidratación")
                    RingView(progress: entry.exerciseProgress, ringColor: .green, title: "Ejercicio")
                }

                if family == .systemMedium {
                    AppIntentButton(AddWaterIntent(amount: getUserDefinedAmount())) {
                        Text("Agregar Agua")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }

    func getUserDefinedAmount() -> Int {
        let sharedDefaults = UserDefaults(suiteName: "group.com.disolutionsmx.Hidratize")
        return sharedDefaults?.integer(forKey: "quickAddAmount") ?? 250 // Valor predeterminado: 250 ml
    }
}
