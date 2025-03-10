import SwiftUI

struct AddIntakeView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: HydrationViewModel
    @State private var intakeAmount: String = ""
    @State private var showAlert: Bool = false

    let commonQuantities: [String] = ["250ml", "500ml", "700ml", "1000ml", "Venti", "Alto", "Grande"]
    let commonQuantitiesValues: [Int] = [250, 500, 700, 1000, 591, 470, 354]
    @State private var selectedQuantityIndex: Int? = nil

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(commonQuantities.enumerated()), id: \.offset) { index, quantity in
                            ChipView(
                                text: quantity,
                                isSelected: index == selectedQuantityIndex
                            )
                            .onTapGesture {
                                selectedQuantityIndex = index
                                intakeAmount = String(commonQuantitiesValues[index])
                            }
                        }
                    }
                    .padding()
                }
                .frame(height: 80)
                .background(Color(UIColor.systemGroupedBackground))
                .cornerRadius(10)
                .padding(.horizontal)

                HStack {
                    Button(action: decrementIntake) {
                        Image(systemName: "minus.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                    }
                    .padding(.leading)

                    TextField("Cantidad en ml", text: $intakeAmount)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .frame(width: 150)

                    Button(action: incrementIntake) {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing)
                }
                .padding()

                Spacer()

                Button(action: {
                    if isValidInput() {
                        saveIntake()
                    } else {
                        showAlert.toggle()
                    }
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                }
                .padding()
                .accessibilityLabel("Guardar ingesta de agua")
            }
            .navigationTitle("Añadir Ingesta")
            .navigationBarItems(
                leading: Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Entrada Inválida"),
                    message: Text("Por favor, ingresa una cantidad válida de agua."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private func isValidInput() -> Bool {
        if let amount = Double(intakeAmount), amount > 0 {
            return true
        }
        return false
    }

    private func saveIntake() {
        guard let amount = Double(intakeAmount), amount > 0 else {
            showAlert = true
            return
        }
        viewModel.addWaterIntake(amount: amount)
        presentationMode.wrappedValue.dismiss()
    }

    private func incrementIntake() {
        if let currentAmount = Int(intakeAmount) {
            intakeAmount = String(currentAmount + 50)
        } else {
            intakeAmount = "50"
        }
    }

    private func decrementIntake() {
        if let currentAmount = Int(intakeAmount), currentAmount > 50 {
            intakeAmount = String(currentAmount - 50)
        }
    }
}

#Preview {
    AddIntakeView(viewModel: HydrationViewModel())
}

