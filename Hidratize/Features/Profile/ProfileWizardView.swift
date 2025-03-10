//
//  ProfileWizardView.swift
//  Hidratize
//
//  Created by Saul Ramirez  on 05/11/24.
//


import SwiftUI

struct ProfileWizardView: View {
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var age = ""
    @State private var location = ""
    @State private var bio = ""
    @State private var avatarImage: UIImage?
    @State private var showingImagePicker = false
    @State private var isSaving = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    // Lista de países (simplificado)
    let countries = ["México", "Estados Unidos", "España", "Argentina", "Colombia"]

    var body: some View {
        NavigationView {
            Form {
                // Sección de Foto de Perfil
                Section {
                    HStack {
                        Spacer()
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            if let avatarImage = avatarImage {
                                Image(uiImage: avatarImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    .shadow(radius: 5)
                            } else {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    .shadow(radius: 5)
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }

                // Sección de Información Personal
                Section(header: Text("Información Personal")) {
                    TextField("Nombre", text: $firstName)
                    TextField("Apellidos", text: $lastName)
                    TextField("Edad", text: $age)
                        .keyboardType(.numberPad)
                    Picker("País", selection: $location) {
                        ForEach(countries, id: \.self) { country in
                            Text(country).tag(country)
                        }
                    }
                }

                // Sección de Biografía
                Section(header: Text("Biografía")) {
                    TextEditor(text: $bio)
                        .frame(height: 100)
                }

                // Sección de Guardar
                Section {
                    Button(action: {
                        Task {
                            await saveProfile()
                        }
                    }) {
                        if isSaving {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Guardar Perfil")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isSaving || !isFormValid())
                    .listRowBackground(isFormValid() ? Color.blue : Color.gray)
                }
            }
            .navigationTitle("Crear Perfil")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $avatarImage)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    func isFormValid() -> Bool {
        return !firstName.isEmpty && !lastName.isEmpty && !age.isEmpty && !location.isEmpty
    }

    func saveProfile() async {
        guard isFormValid() else {
            alertMessage = "Por favor, completa todos los campos obligatorios."
            showAlert = true
            return
        }

        isSaving = true

        // Obtener el userID como String
        guard let userID = SupabaseManager.shared.client.auth.currentUser?.id.uuidString else {
            alertMessage = "No se pudo obtener el ID del usuario."
            showAlert = true
            isSaving = false
            return
        }

        let userEmail = SupabaseManager.shared.client.auth.currentUser?.email

        // Subir la imagen si hay una seleccionada
        var avatarURL = ""
        if let avatarImage = avatarImage {
            if let url = await uploadImage(image: avatarImage, userID: userID) {
                avatarURL = url
            } else {
                alertMessage = "Error al subir la imagen de perfil."
                showAlert = true
                isSaving = false
                return
            }
        }

        let newProfile = UserProfile(
            id: userID,
            first_name: firstName,
            last_name: lastName,
            age: Int(age) ?? 0,
            location: location,
            bio: bio,
            avatar_url: avatarURL,
            updated_at: nil,
            email: userEmail ?? ""
        )

        await profileViewModel.createOrUpdateProfile(profile: newProfile)
        isSaving = false
        dismiss()
    }


    
    func uploadImage(image: UIImage, userID: String) async -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        //generate a timestamo
        let timestamp = Int(Date().timeIntervalSince1970)
        
        let filePath = "avatars/\(userID) \(timestamp).jpg"
        do {
            _ = try await SupabaseManager.shared.client.storage.from("avatars").upload(filePath, data: imageData)
            let publicURL = try SupabaseManager.shared.client.storage.from("avatars").getPublicURL(path: filePath)
            return publicURL.absoluteString
        } catch {
            print("Error al subir imagen: \(error.localizedDescription)")
            return nil
        }
    }


}
