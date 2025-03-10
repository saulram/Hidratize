import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var showingProfileWizard = false
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var profileImage: Image?

    var body: some View {
        NavigationView {
            VStack {
                if profileViewModel.isLoading {
                    ProgressView("Cargando perfil...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if let profile = profileViewModel.profile {
                    List {
                        // Sección de Foto de Perfil
                        Section {
                            HStack {
                                Spacer()
                                VStack {
                                    if let profileImage = profileImage {
                                        profileImage
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                            .shadow(radius: 5)
                                    } else if let url = URL(string: profile.avatar_url) {
                                        AsyncImage(url: url) { image in
                                            image.resizable()
                                                .scaledToFill()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                        .shadow(radius: 5)
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .foregroundColor(.gray)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                            .shadow(radius: 5)
                                    }
                                    Button("Cambiar Foto") {
                                        showingImagePicker = true
                                    }
                                    .font(.footnote)
                                    .padding(.top, 8)
                                }
                                Spacer()
                            }
                            .padding(.vertical)
                        }

                        // Sección de Información Personal
                        Section(header: Text("Información Personal")) {
                            HStack {
                                Text("Nombre Completo")
                                Spacer()
                                Text("\(profile.first_name) \(profile.last_name)")
                                    .foregroundColor(.secondary)
                            }
                            HStack {
                                Text("Ubicación")
                                Spacer()
                                Text(profile.location)
                                    .foregroundColor(.secondary)
                            }
                            HStack {
                                Text("Correo Electrónico")
                                Spacer()
                                Text(profile.email)
                                    .foregroundColor(.secondary)
                            }
                        }

                        // Sección de Biografía
                        Section(header: Text("Biografía")) {
                            Text(profile.bio)
                                .foregroundColor(.secondary)
                        }

                        // Sección de Cerrar Sesión
                        Section {
                            Button(action: {
                                Task {
                                await authViewModel.signOut()
                            }
                            }) {
                                Text("Cerrar Sesión")
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                } else {
                    // No hay perfil, mostrar botón para crear uno
                    VStack {
                        Text("No tienes un perfil creado.")
                            .foregroundColor(.secondary)
                        Button("Crear Perfil") {
                            showingProfileWizard = true
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Perfil")
            .sheet(isPresented: $showingProfileWizard, onDismiss: {
                Task {
                    if let userID = authViewModel.user?.id {
                        await profileViewModel.fetchUserProfile(userID: UUID(uuidString: userID.uuidString)!)
                    }
                }
            }) {
                ProfileWizardView()
                    .environmentObject(profileViewModel)
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: $inputImage)
            }
            .onAppear {
                Task {
                    if let userID = authViewModel.user?.id {
                        await profileViewModel.fetchUserProfile(userID: UUID(uuidString: userID.uuidString)!)
                    }
                }
            }
        }
    }

    private func loadImage() {
        guard let inputImage = inputImage else { return }
        profileImage = Image(uiImage: inputImage)
        // Aquí puedes agregar la lógica para subir la nueva imagen de perfil al servidor
    }
}
