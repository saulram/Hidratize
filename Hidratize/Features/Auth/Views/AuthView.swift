import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSignUp: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Logotipo de la aplicación
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.top, 50)

                Text(isSignUp ? "Crear Cuenta" : "Iniciar Sesión")
                    .font(.largeTitle)
                    .bold()

                TextField("Correo Electrónico", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                SecureField("Contraseña", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                if authViewModel.isLoading {
                    ProgressView()
                        .padding()
                } else {
                    Button(action: {
                        Task {
                            if isSignUp {
                                await authViewModel.signUp(email: email, password: password)
                            } else {
                                await authViewModel.signIn(email: email, password: password)
                            }
                        }
                    }) {
                        
                        Text(isSignUp ? "Registrarse" : "Iniciar Sesión")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .disabled(authViewModel.isLoading)
                }

                Button(action: {
                    isSignUp.toggle()
                }) {
                    Text(isSignUp ? "¿Ya tienes una cuenta? Inicia Sesión" : "¿No tienes una cuenta? Regístrate")
                        .foregroundColor(.blue)
                        .padding(.top, 10)
                }
            }
            .padding()
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

