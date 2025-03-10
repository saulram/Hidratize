import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HydrationViewModel()
    @ObservedObject private var keyboard = KeyboardResponder()
    @State private var showingAddIntake = false

    let notificationManager = NotificationManager.shared
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Sección de Estadísticas
                Section {
                    HStack {
                        ZStack {
                            let waterProgress = viewModel.dailyGoal > 0 ? viewModel.hydrationData.totalIntake / viewModel.dailyGoal : 0
                            RingView(gradient: AngularGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple, Color.blue]),
                                center: .center
                            ), progress: waterProgress, lineWidth: 20, size: 150)
                            
                            let exerciseProgress = min(max(viewModel.exerciseProgress, 0), 4)
                            RingView(gradient: AngularGradient(
                                gradient: Gradient(colors: [Color.green, Color.yellow,Color.green]),
                                center: .center
                            ), progress: exerciseProgress, lineWidth: 20, size: 100)
                        }
                        .padding()
                        
                        VStack(alignment: .leading, spacing: 10) {
                            VStack(alignment: .leading) {
                                Text("Agua")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                Text("\(Int(viewModel.hydrationData.totalIntake)) / \(Int(viewModel.dailyGoal)) ml")
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(.blue)
                            }
                            VStack(alignment: .leading) {
                                Text("Ejercicio")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                                Text("\(Int(viewModel.exerciseProgress * 100))%")
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
                .listRowInsets(EdgeInsets()) // Eliminar insets para que el contenido ocupe todo el ancho
                .listRowBackground(Color.clear) // Fondo transparente para personalizar
                
                // MARK: - Sección de Registros de Ingesta
                Section(header: Text("Registros de Ingesta")) {
                    ForEach(viewModel.intakeRecords) { intake in
                        HStack(alignment: .center, spacing: 15) {
                            // Ícono de una gota de agua en un fondo circular azul
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.8))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "drop.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            }
                            
                            VStack(alignment: .leading, spacing: 5) {
                                // Texto que muestra la cantidad de agua ingerida
                                Text("\(intake.amount, specifier: "%.2f") ml")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                // Texto que muestra la hora de registro
                                Text(intake.timestamp, style: .time)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 10)
                    }
                    .onDelete { indexSet in
                        viewModel.deleteIntake(at: indexSet)
                    }
                }
                
                // MARK: - Sección de Acción
                Section {
                    Button(action: {
                        print("Button clicked")
                        showingAddIntake = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                            Text("Añadir Ingesta")
                                .foregroundColor(.blue)
                                .font(.headline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                .listRowInsets(EdgeInsets())
            }
            .listStyle(InsetGroupedListStyle()) // Estilo de lista que proporciona un fondo consistente
            .background(Color(.systemGroupedBackground)) // Fondo de la lista
            .navigationTitle("Hidratize")
            .sheet(isPresented: $showingAddIntake) {
                AddIntakeView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.loadInitialDataIfNeeded()
            }
            .padding(.bottom, keyboard.currentHeight) // Ajusta el padding inferior según la altura del teclado
            .animation(.easeOut(duration: 0.16), value: keyboard.currentHeight) // Animación suave al ajustar
        }
    }
}


// Extensión para ocultar el teclado
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// Previews
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

