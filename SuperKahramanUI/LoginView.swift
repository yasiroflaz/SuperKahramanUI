import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "shield.lefthalf.filled")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.bottom, 20)
                
                Text(isSignUp ? "Yeni Hesap Oluştur" : "Kahramanlar Dünyası")
                    .font(.largeTitle).bold()
                
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .autocapitalization(.none)
                    
                    SecureField("Şifre", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                
                if let error = authVM.errorMessage {
                    Text(error).foregroundColor(.red).font(.caption)
                }
                
                Button {
                    if isSignUp {
                        authVM.signUp(email: email, password: password)
                    } else {
                        authVM.login(email: email, password: password)
                    }
                } label: {
                    Text(isSignUp ? "Kayıt Ol" : "Giriş Yap")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button {
                    isSignUp.toggle()
                } label: {
                    Text(isSignUp ? "Zaten hesabın var mı? Giriş yap" : "Hesabın yok mu? Kayıt ol")
                        .font(.footnote)
                }
            }
            .padding()
        }
    }
}
