import Foundation
import SwiftUI
import Combine
import FirebaseFirestore

@MainActor
class HeroViewModel: ObservableObject {
    @Published var allHeroes: [SuperHero] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    
    private var db = Firestore.firestore()
    private var apiHeroes: [SuperHero] = []
    private var firebaseHeroes: [SuperHero] = []
    private var firestoreListener: ListenerRegistration?
    
    var filteredHeroes: [SuperHero] {
        if searchText.isEmpty { return allHeroes }
        return allHeroes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var filteredHeroesWithoutLocation: [SuperHero] {
        filteredHeroes.filter { $0.coordinate == nil }
    }
    
    var filteredHeroesWithLocation: [SuperHero] {
        filteredHeroes.filter { $0.coordinate != nil }
    }
    
    func hero(withID id: String) -> SuperHero? {
        allHeroes.first { $0.id == id }
    }
    
    func fetchData(forceRefresh: Bool = false) async {
        guard forceRefresh || allHeroes.isEmpty else { return }
        isLoading = true
        
        do {
            let url = URL(string: "https://akabab.github.io/superhero-api/api/all.json")!
            let (data, _) = try await URLSession.shared.data(from: url)
            apiHeroes = try JSONDecoder().decode([SuperHero].self, from: data)

            listenToFirestoreHeroes()
            updateAllHeroes()
            
        } catch {
            print("HATA: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func deleteHero(_ hero: SuperHero) async {
        guard let documentID = hero.firestoreDocumentID else { return }
        
        do {
            try await db.collection("Kahramanlar").document(documentID).delete()
            allHeroes.removeAll { $0.id == hero.id }
        } catch {
            print("SILME HATASI: \(error.localizedDescription)")
        }
    }
    
    private func listenToFirestoreHeroes() {
        guard firestoreListener == nil else { return }
        
        firestoreListener = db.collection("Kahramanlar").addSnapshotListener { [weak self] snapshot, error in
            guard let self else { return }
            
            if let error {
                print("FIRESTORE DINLEME HATASI: \(error.localizedDescription)")
                return
            }
            
            let heroes = snapshot?.documents.map { self.firebaseHero(from: $0) } ?? []
            
            Task { @MainActor in
                self.firebaseHeroes = heroes
                self.updateAllHeroes()
            }
        }
    }
    
    private func updateAllHeroes() {
        allHeroes = firebaseHeroes + apiHeroes
    }
    
    private func firebaseHero(from doc: QueryDocumentSnapshot) -> SuperHero {
        let d = doc.data()
        let latitude = doubleValue(from: d["latitude"]) ?? doubleValue(from: d["lat"])
        let longitude = doubleValue(from: d["longitude"]) ?? doubleValue(from: d["lon"])
        let name = firstString(in: d, keys: ["name", "isim", "ad", "title"]) ?? "Bilinmiyor"
        let imageURL = firstString(in: d, keys: [
            "imageURL",
            "imageUrl",
            "imageurl",
            "image",
            "url",
            "photoURL",
            "photoUrl",
            "photo",
            "resim",
            "gorsel",
            "görsel"
        ])
        
        return SuperHero(
            id: "firebase-\(doc.documentID)",
            firestoreDocumentID: doc.documentID,
            name: name,
            imageURL: imageURL,
            lat: latitude,
            lon: longitude
        )
    }
    
    private func doubleValue(from value: Any?) -> Double? {
        if let double = value as? Double {
            return double
        }
        
        if let int = value as? Int {
            return Double(int)
        }
        
        if let string = value as? String {
            return Double(string.replacingOccurrences(of: ",", with: "."))
        }
        
        return nil
    }
    
    private func stringValue(from value: Any?) -> String? {
        guard let string = value as? String else { return nil }
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedString.isEmpty ? nil : trimmedString
    }
    
    private func firstString(in data: [String: Any], keys: [String]) -> String? {
        for key in keys {
            if let value = stringValue(from: data[key]) {
                return value
            }
        }
        
        return nil
    }
}
