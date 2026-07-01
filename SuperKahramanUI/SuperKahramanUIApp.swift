//
//  SuperKahramanUIApp.swift
//  SuperKahramanUI
//
//  Created by Yasir OFLAZ on 1.07.2026.
//


import SwiftUI
import FirebaseCore

@main
struct SuperKahramanUIApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            
            ContectView()
        }
    }
}
