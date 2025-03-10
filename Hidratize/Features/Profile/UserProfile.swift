//
//  UserProfile.swift
//  Hidratize
//
//  Created by Saul Ramirez  on 05/11/24.
//


import Supabase
import Foundation

struct UserProfile: Codable, Identifiable {
    var id: String
    var first_name: String
    var last_name: String
    var age: Int
    var location: String
    var bio: String
    var avatar_url: String
    var updated_at: String?
    var email: String
}
