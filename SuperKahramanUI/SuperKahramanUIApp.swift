import SwiftUI
import Firebase

@main
struct SuperKahramanUIApp: App {
  
    @StateObject var authVM = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.userSession != nil {
                   
                    NavigationStack {
                        ContectView()
                    }
                } else {
                    
                    LoginView()
                }
            }
            .environmentObject(authVM)
        }
    }
}
