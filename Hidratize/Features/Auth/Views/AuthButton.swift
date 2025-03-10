//
//  AuthButton.swift
//  Hidratize
//
//  Created by Saul Ramirez  on 06/11/24.
//

import SwiftUI

struct AuthButton: View {
    @State private var isLoading = false
    let isSignUp: Bool
    let email: String
    let password: String
    let viewModel: AuthViewModel

    var body: some View {
        Button(action: {
            isLoading = true
            Task {
                defer { isLoading = false }
                if isSignUp {
                    await viewModel.signUp(email: email, password: password)
                } else {
                    await viewModel.signIn(email: email, password: password)
                }
            }
        }) {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Text(isSignUp ? "Registrarse" : "Iniciar Sesión")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(5)
            }
        }
        .disabled(isLoading)
    }
}
