import SwiftUI
import MapKit 

struct HeroDetailView: View {
    let hero: SuperHero
    @ObservedObject var viewModel: HeroViewModel
    
    @State private var showingDeleteConfirmation = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                
                // 1. Kahraman Resmi
                AsyncImage(url: hero.imageURL) { phase in
                    switch phase {
                    case .empty: ProgressView()
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(systemName: "photo").foregroundColor(.gray)
                    @unknown default: EmptyView()
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .cornerRadius(15)

                // 2. Kahraman Bilgileri
                VStack(alignment: .leading, spacing: 8) {
                    Text(hero.name)
                        .font(.largeTitle)
                        .bold()
                    
                    if let fullName = hero.biography?.fullName, !fullName.isEmpty {
                        Text(fullName)
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                Divider()

                // 3. Harita Bölümü
                VStack(alignment: .leading, spacing: 10) {
                    Text("Konum")
                        .font(.headline)
                    
                    if let coordinate = hero.coordinate {
                        // Eğer koordinat varsa haritayı gösteriyoruz
                        Map(initialPosition: .region(MKCoordinateRegion(
                            center: coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        ))) {
                            Marker(hero.name, coordinate: coordinate)
                        }
                        .frame(height: 200)
                        .cornerRadius(12)
                    } else {
                        // Koordinat yoksa bu mesajı gösteriyoruz
                        ContentUnavailableView("Konum Yok",
                                             systemImage: "mappin.slash",
                                             description: Text("Bu kahraman için henüz bir konum eklenmemiş."))
                            .frame(height: 200)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationTitle(hero.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if hero.firestoreDocumentID != nil {
                Button(role: .destructive) { showingDeleteConfirmation = true } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .alert("Karakter silinsin mi?", isPresented: $showingDeleteConfirmation) {
            Button("Sil", role: .destructive) {
                Task {
                    await viewModel.deleteHero(hero)
                    dismiss()
                }
            }
            Button("Vazgeç", role: .cancel) { }
        } message: {
            Text("\(hero.name) Firestore'dan silinecek.")
        }
    }
}
