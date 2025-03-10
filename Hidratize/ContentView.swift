import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        if authViewModel.session != nil {
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "drop.fill")
                        Text("Hidratación")
                    }
                
                StatsView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Stats")
                    }
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Perfil")
                    }
            }
                .environmentObject(authViewModel)
        } else {
            AuthView()
                .environmentObject(authViewModel)
        }
    }
}


#Preview {
    ContentView()
}
