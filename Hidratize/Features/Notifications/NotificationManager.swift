import UserNotifications
import SwiftUI

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestNotificationPermissions(completion: @escaping (Bool) -> Void) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error al solicitar permisos: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if granted {
                print("Permisos de notificación otorgados.")
            } else {
                print("Permisos de notificación denegados.")
            }
            completion(granted)
        }
    }
    
    func scheduleHydrationReminders() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests() // Para evitar duplicados
        
        // Definir el rango de horas para las notificaciones
        let startHour = 9
        let endHour = 21
        
        for hour in startHour...endHour {
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = 0 // En punto; puedes ajustar si lo deseas
            
            let content = UNMutableNotificationContent()
            content.title = "¡Es hora de hidratarte!"
            content.body = "Recuerda beber un vaso de agua para mantenerte hidratado."
            content.sound = .default
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let identifier = "hydration_reminder_\(hour)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            notificationCenter.add(request) { error in
                if let error = error {
                    print("Error al programar notificación para las \(hour):00: \(error.localizedDescription)")
                } else {
                    print("Notificación programada para las \(hour):00.")
                }
            }
        }
    }
    
    func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Prueba de Notificación"
        content.body = "Esta es una notificación de prueba."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "test_notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error al enviar notificación de prueba: \(error.localizedDescription)")
            } else {
                print("Notificación de prueba enviada.")
            }
        }
    }
    
    // Manejar notificaciones cuando la app está en foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
