import CoreData
import SwiftUI
import HealthKit
import CoreLocation
import Foundation

// MARK: - ViewModel
class HydrationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    // HealthKit and Location Managers
    private let healthStore = HKHealthStore()
    private var locationManager = CLLocationManager()
    private var hasLoadedData = false // Variable to avoid duplicate loads
    
    // Published Properties
    @Published var hydrationData = HydrationData(totalIntake: 0.0)
    @Published var dailyGoal: Double = 2500.0 // Initialize with base value
    @Published var weatherData: WeatherData?
    @Published var exerciseProgress: Double = 0.0
    @Published var intakeRecords: [WaterIntakeEntry] = [] // List of water intake entries with unique identifiers

    // Ajustes para recalcular dailyGoal
    private var weightGoal: Double = 0.0
    private var exerciseAdjustment: Double = 0.0
    private var weatherAdjustment: Double = 0.0

    // API Key para OpenWeatherMap
    private let apiKey = "15fa2bc8234e88441718b67b540792ab"

    // Core Data Persistent Container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "HidratizeDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error loading Core Data: \(error)")
            }
        }
        return container
    }()
    
    // Inicializador
    override init() {
        super.init()
        locationManager.delegate = self
        requestAuthorization()
        requestLocation()
    }
    
    // Función para cargar datos iniciales si no se han cargado aún
    func loadInitialDataIfNeeded() {
        guard !hasLoadedData else { return } // Evita cargas duplicadas
        
        // Resetear ajustes
        weightGoal = 0.0
        exerciseAdjustment = 0.0
        weatherAdjustment = 0.0
        
        // Cargar datos
        fetchUserWeight()
        fetchHydrationData()
        loadDailyIntakeRecords()
        adjustGoalForExercise()
        fetchWeatherData(for: locationManager.location ?? CLLocation())
        
        hasLoadedData = true // Marca los datos como cargados
    }
    
    // Función para recalcular dailyGoal basado en todos los ajustes
    private func calculateDailyGoal() {
        DispatchQueue.main.async {
            self.dailyGoal = self.weightGoal + self.exerciseAdjustment + self.weatherAdjustment
            self.updateTodayDailyRecord()
            print("dailyGoal recalculado a \(self.dailyGoal) ml.")
        }
    }
    func assignUUIDsToExistingRecords() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == nil")
        
        do {
            let records = try context.fetch(fetchRequest)
            for record in records {
                record.id = UUID()
            }
            if context.hasChanges {
                try context.save()
                print("UUIDs asignados a registros existentes.")
            }
        } catch {
            print("Error al asignar UUIDs: \(error.localizedDescription)")
        }
    }

    
    // Función para actualizar o crear el registro diario de hoy en Core Data
    func updateTodayDailyRecord() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
        
        // Obtener el inicio del día actual para la comparación de fechas
        let today = Calendar.current.startOfDay(for: Date())
        fetchRequest.predicate = NSPredicate(format: "date == %@", today as NSDate)
        
        do {
            // Ejecutar la consulta para buscar el registro diario de hoy
            let results = try context.fetch(fetchRequest)
            
            if let todayRecord = results.first {
                // Actualizar el dailyGoal existente
                todayRecord.dailyGoal = self.dailyGoal
                if(todayRecord.id == nil){
                    todayRecord.id = UUID()
                }
                print("DailyRecord existente encontrado. dailyGoal actualizado a \(todayRecord.dailyGoal) ml.")
            } else {
                // Crear un nuevo DailyRecord si no existe
                let newRecord = DailyRecord(context: context)
                newRecord.date = today
                newRecord.dailyGoal = self.dailyGoal
                newRecord.id = UUID()
                newRecord.exerciseMinutes = self.exerciseProgress * 100 // Ajusta según tu lógica
                print("Nuevo DailyRecord creado con dailyGoal \(newRecord.dailyGoal) ml.")
            }
            
            // Guardar los cambios en Core Data
            if context.hasChanges {
                try context.save()
                print("Cambios en DailyRecord guardados correctamente.")
            }
        } catch {
            print("Error al actualizar o crear DailyRecord: \(error.localizedDescription)")
        }
    }
    
    // Función para obtener el peso del usuario y ajustar la meta de hidratación
    func fetchUserWeight() {
        let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] _, results, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    print("Error al obtener el peso: \(error.localizedDescription); usando meta por defecto de 2500 ml")
                    self.weightGoal = 2500.0
                    self.calculateDailyGoal()
                }
                return
            }
            
            guard let sample = results?.first as? HKQuantitySample else {
                DispatchQueue.main.async {
                    print("Peso no encontrado; usando meta por defecto de 2500 ml")
                    self.weightGoal = 2500.0
                    self.calculateDailyGoal()
                }
                return
            }
            
            let weightInKg = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
            DispatchQueue.main.async {
                self.weightGoal = weightInKg * 35 // Meta diaria basada en peso (35 ml por kg)
                self.calculateDailyGoal()
                print("Peso encontrado: \(weightInKg) kg, meta de hidratación calculada: \(self.weightGoal) ml")
            }
        }
        healthStore.execute(query)
    }
    
    // Función para agregar un registro de ingesta de agua
    func addWaterIntake(amount: Double) {
        let context = persistentContainer.viewContext
        let waterIntakeRecord = WaterIntakeRecord(context: context)
        waterIntakeRecord.id = UUID() // Establece el ID aquí
        waterIntakeRecord.amount = amount
        waterIntakeRecord.timestamp = Date()
        
        let dailyRecord = getOrCreateDailyRecord(for: Date())
        dailyRecord.addToWaterIntakes(waterIntakeRecord) // Añade la ingesta al registro diario
        hydrationData.totalIntake += amount
        intakeRecords.append(WaterIntakeEntry(id: waterIntakeRecord.id!, amount: amount, timestamp: Date()))
        
        do {
            try context.save()
            print("Registro de ingesta de agua guardado exitosamente.")
        } catch {
            print("Error al guardar el registro de ingesta de agua: \(error)")
        }
    }

    // Función para obtener o crear el registro diario para una fecha específica
    private func getOrCreateDailyRecord(for date: Date) -> DailyRecord {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
        
        let today = Calendar.current.startOfDay(for: date)
        fetchRequest.predicate = NSPredicate(format: "date == %@", today as NSDate)
        
        if let existingRecord = try? context.fetch(fetchRequest).first {
            return existingRecord
        } else {
            let newRecord = DailyRecord(context: context)
            newRecord.date = today
            newRecord.exerciseMinutes = exerciseProgress * 100
            newRecord.dailyGoal = dailyGoal
            return newRecord
        }
    }
    
    // Función para cargar los registros de ingesta de agua diarios desde Core Data
    func loadDailyIntakeRecords() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<WaterIntakeRecord> = WaterIntakeRecord.fetchRequest()
        
        let today = Calendar.current.startOfDay(for: Date())
        fetchRequest.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", today as NSDate, Calendar.current.date(byAdding: .day, value: 1, to: today)! as NSDate)
        
        do {
            let records = try context.fetch(fetchRequest)
            intakeRecords = records.map {
                WaterIntakeEntry(
                    id: $0.id ?? UUID(),
                    amount: $0.amount,
                    timestamp: $0.timestamp ?? Date()
                )
            }
            hydrationData.totalIntake = records.reduce(0) { $0 + $1.amount }
            print("Total de ingesta de agua para hoy: \(hydrationData.totalIntake) ml")
        } catch {
            print("Error al cargar los registros de ingesta de agua: \(error)")
        }
    }
    
    // Función para eliminar registros de ingesta de agua
    func deleteIntake(at offsets: IndexSet) {
        let context = persistentContainer.viewContext
        
        offsets.map { intakeRecords[$0] }.forEach { intake in
            // Elimina el registro de Core Data
            if let record = fetchWaterIntakeRecord(with: intake.id) {
                context.delete(record)
            }
            
            // Elimina el registro de la lista en el ViewModel
            intakeRecords.removeAll { $0.id == intake.id }
            hydrationData.totalIntake -= intake.amount
        }
        
        // Guarda los cambios en Core Data
        do {
            try context.save()
            print("Registro de ingesta de agua eliminado exitosamente.")
        } catch {
            print("Error al eliminar el registro de ingesta de agua: \(error)")
        }
    }

    // Función auxiliar para obtener un registro de ingesta de agua específico de Core Data
    private func fetchWaterIntakeRecord(with id: UUID) -> WaterIntakeRecord? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<WaterIntakeRecord> = WaterIntakeRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return (try? context.fetch(fetchRequest))?.first
    }
    
    // Configura los permisos y actualizaciones de ubicación
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    // Maneja las actualizaciones de ubicación
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            fetchWeatherData(for: location)
            locationManager.stopUpdatingLocation() // Detiene las actualizaciones para ahorrar batería
        }
    }
    
    // Función para obtener datos de clima usando OpenWeatherMap
    func fetchWeatherData(for location: CLLocation) {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=metric&appid=\(apiKey)"
    
        guard let url = URL(string: urlString) else {
            print("URL inválida")
            return
        }
    
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error en la solicitud: \(error.localizedDescription)")
                return
            }
    
            guard let data = data else {
                print("No se recibió datos")
                return
            }
    
            do {
                let decoder = JSONDecoder()
                let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    let currentTemp = weatherResponse.main.temp
                    let humidity = weatherResponse.main.humidity
                    
                    self?.weatherData = WeatherData(
                        temperature: currentTemp,
                        humidity: Double(humidity)
                    )
                    print("Current Weather Data IS: \(currentTemp) temp  and \(humidity) humidity")
                    //we adjust the goal for weather if its too hot (27+) or the humidity > 60 and 24+ degrees.
                    self?.adjustGoalForWeather(isHotOrHumid: currentTemp > 25 || ( humidity > 60 && currentTemp > 24 ))
                }
            } catch {
                print("Error al decodificar datos: \(error.localizedDescription)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Datos JSON de respuesta: \(jsonString)")
                }
            }
        }
        task.resume()
    }

    // Función para ajustar la meta diaria basada en el clima
    func adjustGoalForWeather(isHotOrHumid: Bool) {
        if isHotOrHumid {
            weatherAdjustment = 500.0
        } else {
            weatherAdjustment = 0.0
        }
        calculateDailyGoal()
        print("Ajuste de clima aplicado: \(weatherAdjustment) ml")
    }
    
    // Función para solicitar permisos de HealthKit
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater)!
        let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
        let workoutType = HKObjectType.workoutType()
        
        let typesToRead: Set<HKObjectType> = [waterType, weightType, workoutType]
        
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            if success {
                print("Permissions granted to read water, weight, and workouts.")
            } else {
                print("Permissions not granted for HealthKit: \(String(describing: error?.localizedDescription))")
            }
        }
    }

    // Función para obtener datos de hidratación desde HealthKit
    func fetchHydrationData() {
        let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater)!
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: waterType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            guard let self = self, let result = result, let sum = result.sumQuantity() else { return }
            DispatchQueue.main.async {
                let healthKitTotalIntake = sum.doubleValue(for: .literUnit(with: .milli))
                // Opcionalmente, si deseas incluir los datos de HealthKit en tu ingesta total:
                self.hydrationData.totalIntake += healthKitTotalIntake
                print("Total de ingesta de agua desde HealthKit: \(healthKitTotalIntake) ml")
            }
        }
        
        healthStore.execute(query)
    }
    
    // Función para ajustar la meta diaria basada en el ejercicio
    func adjustGoalForExercise() {
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date(), options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: predicate, limit: 0, sortDescriptors: nil) { [weak self] _, results, error in
            guard let self = self, let workouts = results as? [HKWorkout] else { return }
            
            var totalExerciseMinutes = 0.0
            for workout in workouts {
                totalExerciseMinutes += workout.duration / 60
            }
            print("Total Excercise Minutes: \(totalExerciseMinutes)")
            
            DispatchQueue.main.async {
                self.exerciseProgress = min(max(totalExerciseMinutes / 30.0, 0), 5.0) // Asegura que el progreso esté entre 0 y 1
                let additionalWater = self.exerciseProgress * 350.0
                self.exerciseAdjustment = additionalWater
                self.calculateDailyGoal()
                print("Ajuste de ejercicio aplicado: \(self.exerciseAdjustment) ml")
            }
        }
        healthStore.execute(query)
    }
}
