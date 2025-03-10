import SwiftUI
import CoreData

struct StatsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DailyRecord.date, ascending: false)],
        animation: .default)
    private var dailyRecords: FetchedResults<DailyRecord>

    var body: some View {
        NavigationView {
            List {
                ForEach(dailyRecords) { record in
                    
                    DailyRecordRow(record: record).onAppear(
                        perform: {
                            print("Appeared: \(record)")
                        }
                        
                    )
                }
                .onDelete(perform: deleteDailyRecords)
            }
            .navigationTitle("Registros Diarios")
            .toolbar {
                EditButton()
            }
        }
    }

    private func deleteDailyRecords(offsets: IndexSet) {
        withAnimation {
            offsets.map { dailyRecords[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Manejar el error apropiadamente
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext

        return StatsView().environment(\.managedObjectContext, context)
    }
}
