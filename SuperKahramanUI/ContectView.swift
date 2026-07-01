import SwiftUI

struct ContectView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject var viewModel = HeroViewModel()
    @State private var showingAddSheet = false
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Kahramanlar Yükleniyor...")
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            if !viewModel.filteredHeroesWithLocation.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Konumu Olan Kahramanlar")
                                        .font(.headline)
                                        .padding(.horizontal, 4)
                                    
                                    LazyVGrid(columns: columns, spacing: 20) {
                                        ForEach(viewModel.filteredHeroesWithLocation) { hero in
                                           
                                            NavigationLink(destination: HeroDetailView(hero: hero, viewModel: viewModel)) {
                                               
                                                HeroCard(hero: hero)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if !viewModel.filteredHeroesWithoutLocation.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Konumu Olmayan Kahramanlar")
                                        .font(.headline)
                                        .padding(.horizontal, 4)
                                    
                                    LazyVGrid(columns: columns, spacing: 20) {
                                        ForEach(viewModel.filteredHeroesWithoutLocation) { hero in
                                            NavigationLink(destination: HeroDetailView(hero: hero, viewModel: viewModel)) {
                                                HeroCard(hero: hero)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    authVM.logout()
                                } label: {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Kahramanlar")
            .searchable(text: $viewModel.searchText, prompt: "Kahraman ara...")
            .toolbar {
                Button {
                    showingAddSheet.toggle()
                } label: {
                    Image(systemName: "plus.circle.fill").font(.title3)
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddHeroView(viewModel: viewModel)
            }
            .task {
                await viewModel.fetchData()
            }
        }
    }
}

// Liste Kart Tasarımı
struct HeroCard: View {
    let hero: SuperHero
    var body: some View {
        VStack {
            AsyncImage(url: hero.imageURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.secondary)
                        .padding(35)
                case .empty:
                    ProgressView()
                @unknown default:
                    Color.gray.opacity(0.2)
                }
            }
            .frame(width: 160, height: 200)
            .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
            Text(hero.name).font(.headline).lineLimit(1).foregroundColor(.primary)
        }
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 3)
    }
}
