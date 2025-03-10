import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)

        let viewContext = controller.container.viewContext
        for i in 0..<5 {
            let newRecord = DailyRecord(context: viewContext)
            newRecord.date = Calendar.current.date(byAdding: .day, value: -i, to: Date())
            newRecord.dailyGoal = 2500.0 + Double(i) * 500.0
            newRecord.waterIntake = Double.random(in: 1000...3000)
            
            for j in 0..<Int.random(in: 1...5) {
                let waterIntake = WaterIntakeRecord(context: viewContext)
                waterIntake.amount = Double.random(in: 200...500)
                waterIntake.timestamp = Calendar.current.date(byAdding: .hour, value: -j * 2, to: Date())
                newRecord.addToWaterIntakes(waterIntake)
            }
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "HidratizeDataModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                // Manejo de errores al cargar el almacén persistente
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
