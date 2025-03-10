//
//  ProfileViewModel.swift
//  Hidratize
//
//  Created by Saul Ramirez  on 05/11/24.
//


import Foundation
import Supabase

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let client = SupabaseManager.shared.client
    
    func fetchUserProfile(userID: UUID) async {
        isLoading = true
        do {
            let response: [UserProfile] = try await client
                .from("profiles")
                .select()
                .eq("id", value: userID.uuidString)
                .execute()
                .value
            self.profile = response.first
            isLoading = false
        } catch {
            isLoading = false
            print(error.localizedDescription)
            errorMessage = error.localizedDescription
        }
    }
    
    func createOrUpdateProfile(profile: UserProfile) async {
        isLoading = true
        do {
            let response = try await client
                .from("profiles")
                .upsert(profile)
                .execute()
            self.profile = profile
            print("Response \(response)")
            isLoading = false
        } catch {
            isLoading = false
            print("Error \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
}
