//
//  HidratizeApp.swift
//  Hidratize
//
//  Created by Saul Ramirez  on 03/11/24.
//

import SwiftUI
import SwiftData

@main
struct HidratizeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let notificationManager = NotificationManager.shared
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView() .onAppear {
                // Solicitar permisos y programar notificaciones
                notificationManager.requestNotificationPermissions { granted in
                    if granted {
                        notificationManager.scheduleHydrationReminders()
                    } else {
                        print("El usuario denegó los permisos de notificación.")
                    }
                }
            }
        }
        
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .modelContainer(sharedModelContainer)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configurar cualquier cosa adicional si es necesario
        return true
    }
}
