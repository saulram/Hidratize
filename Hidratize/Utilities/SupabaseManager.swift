//
//  SupabaseManager.swift
//  Hidratize
//
//  Created by Saul Ramirez  on 05/11/24.
//

import Supabase
import Foundation


class SupabaseManager {
    static let shared = SupabaseManager()
    let client: SupabaseClient

    private init() {
        let supabaseURL = URL(string: "https://bxxnfyaqwylbynsdkssb.supabase.co")!
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ4eG5meWFxd3lsYnluc2Rrc3NiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA4MzU3MjEsImV4cCI6MjA0NjQxMTcyMX0.LlnQqdztXPU6lpO3uE_De4qhUKL1GXDO7tPFDxrDewI"

        self.client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }
}
