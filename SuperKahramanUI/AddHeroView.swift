import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import PhotosUI
import UIKit

struct AddHeroView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HeroViewModel
    
    @State private var name = ""
    @State private var imageURL = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var lat = ""
    @State private var lon = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Kahraman Adı", text: $name)
                
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label("Cihazdan Görsel Seç", systemImage: "photo")
                }
                
                if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                }
                
                TextField("Görsel URL", text: $imageURL)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("Enlem (Örn: 41.01)", text: $lat).keyboardType(.decimalPad)
                TextField("Boylam (Örn: 28.97)", text: $lon).keyboardType(.decimalPad)
                
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
                
                Button(isSaving ? "Kaydediliyor..." : "Firebase'e Kaydet") {
                    Task {
                        await saveHero()
                    }
                }
                .disabled(name.isEmpty || isSaving)
            }
            .navigationTitle("Yeni Ekle")
            .toolbar {
                Button("Vazgeç") { dismiss() }
            }
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    selectedImageData = try? await newValue?.loadTransferable(type: Data.self)
                }
            }
        }
    }
    
    func saveHero() async {
        isSaving = true
        errorMessage = nil
        
        let db = Firestore.firestore()
        var data: [String: Any] = [
            "name": name,
            "latitude": Double(lat) ?? 0.0,
            "longitude": Double(lon) ?? 0.0
        ]
        
        do {
            if let selectedImageData {
                data["imageURL"] = try await uploadImage(selectedImageData)
            } else {
                let trimmedImageURL = imageURL.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedImageURL.isEmpty {
                    data["imageURL"] = trimmedImageURL
                }
            }
            
            try await db.collection("Kahramanlar").addDocument(data: data)
            await viewModel.fetchData(forceRefresh: true)
            dismiss()
        } catch {
            errorMessage = "Kaydetme hatası: \(error.localizedDescription)"
        }
        
        isSaving = false
    }
    
    func uploadImage(_ imageData: Data) async throws -> String {
        let reference = Storage.storage().reference().child("hero-images/\(UUID().uuidString).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await reference.putDataAsync(imageData, metadata: metadata)
        return try await reference.downloadURL().absoluteString
    }
}
