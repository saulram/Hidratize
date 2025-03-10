import Supabase
import Foundation

@MainActor
class AuthViewModel: ObservableObject {
    @Published var session: Session?
    @Published var user: User?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private let client = SupabaseManager.shared.client

    init() {
        initialize()
    }

    func initialize() {
        do {
            // Restaurar la sesión si existe
            if let currentUser = client.auth.currentUser{
                self.user = currentUser
                
            }
            if let currentSession = client.auth.currentSession {
                self.session = currentSession
            }
            print("Sesión inicializada con \(user?.id.uuidString ?? "Unknown ID")")


            // Suscribirse a los cambios de estado de autenticación
            Task {
                for await state in client.auth.authStateChanges {
                    switch state.event {
                    case .signedIn:
                        print("User signed in: \(state.session?.user.id.uuidString ?? "Unknown ID")")
                        user = state.session?.user
                        session=state.session
                    case .signedOut:
                        print("User signed out.")
                        user = nil
                        errorMessage = nil
                        session = nil
                    default:
                        break
                    }
                }
            }
        }
    }

    func signUp(email: String, password: String) async {
        do {
            self.isLoading = true
            defer { isLoading = false }
            let session = try await client.auth.signUp(email: email, password: password)
            self.session = session.session
            self.user = session.user
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        } 
    }

    func signIn(email: String, password: String) async {
        do {
            let session = try await client.auth.signIn(email: email, password: password)
            self.session = session
            self.user = session.user
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func signOut() async {
        do {
            try await client.auth.signOut()
            self.session = nil
            self.user = nil
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
