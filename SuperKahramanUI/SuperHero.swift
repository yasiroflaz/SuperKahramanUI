import Foundation
import CoreLocation

struct SuperHero: Identifiable, Codable {
    let id: String
    let name: String
    let powerstats: Powerstats?
    let biography: Biography?
    let images: HeroImages?
    let firestoreDocumentID: String?
    
    var latitude: Double?
    var longitude: Double?
    
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    var imageURL: URL? {
        guard let imageURLString = images?.lg ?? images?.sm else { return nil }
        let trimmedString = imageURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let url = URL(string: trimmedString) {
            return url
        }
        
        return URL(string: trimmedString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
    }

    enum CodingKeys: String, CodingKey {
        case id, name, powerstats, biography, images, latitude, longitude
    }

    // API için (JSON Çözücü)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let stringID = try? container.decode(String.self, forKey: .id) {
            self.id = stringID
        } else if let intID = try? container.decode(Int.self, forKey: .id) {
            self.id = String(intID)
        } else {
            self.id = UUID().uuidString
        }
        
        self.name = try container.decode(String.self, forKey: .name)
        self.powerstats = try? container.decode(Powerstats.self, forKey: .powerstats)
        self.biography = try? container.decode(Biography.self, forKey: .biography)
        self.images = try? container.decode(HeroImages.self, forKey: .images)
        self.firestoreDocumentID = nil
        self.latitude = try? container.decode(Double.self, forKey: .latitude)
        self.longitude = try? container.decode(Double.self, forKey: .longitude)
    }
    
    // Firebase Manuel Ekleme İçin (Hataları çözen kısım burası)
    init(id: String, firestoreDocumentID: String?, name: String, imageURL: String?, lat: Double?, lon: Double?) {
        self.id = id
        self.name = name
        self.powerstats = nil
        self.biography = nil
        self.images = imageURL.map { HeroImages(sm: $0, lg: $0) }
        self.firestoreDocumentID = firestoreDocumentID
        self.latitude = lat
        self.longitude = lon
    }
}

struct Powerstats: Codable {
    let intelligence, strength, speed, durability, power, combat: Int
}

struct Biography: Codable {
    let fullName: String
    let publisher: String?
}

struct HeroImages: Codable {
    let sm: String
    let lg: String
}
