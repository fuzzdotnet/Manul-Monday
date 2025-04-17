import SwiftUI
import Firebase

struct ManulView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var storeService: StoreService
    @State private var activeManul: Manul?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingItemSelector = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                if isLoading {
                    ProgressView("Loading your manul...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let errorMessage = errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                            .padding()
                        
                        Text("Error")
                            .font(.headline)
                        
                        Text(errorMessage)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button(action: loadManul) {
                            Text("Try Again")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 150, height: 40)
                                .background(Color.orange)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                } else if let manul = activeManul {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Manul habitat view
                            manulHabitatView(manul: manul)
                            
                            // Manul info card
                            manulInfoCard(manul: manul)
                            
                            // Customization button
                            Button(action: {
                                showingItemSelector = true
                            }) {
                                HStack {
                                    Image(systemName: "paintbrush.fill")
                                        .foregroundColor(.white)
                                    
                                    Text("Customize Habitat")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                            }
                            
                            // Manul facts
                            manulFactsSection()
                            
                            // Conservation info
                            conservationSection()
                        }
                        .padding(.bottom, 30)
                    }
                } else {
                    VStack {
                        Image(systemName: "pawprint.circle")
                            .font(.system(size: 70))
                            .foregroundColor(.orange)
                            .padding()
                        
                        Text("No Manul Found")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("You don't have an active manul yet.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button(action: {
                            // Navigate to store or onboarding
                        }) {
                            Text("Get a Manul")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 150, height: 40)
                                .background(Color.orange)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("My Manul")
            .navigationBarItems(trailing: Button(action: {
                // Show manul selector if user has multiple manuls
                if let user = authService.user, user.ownedManulIds.count > 1 {
                    // Show manul selector
                }
            }) {
                Image(systemName: "arrow.left.arrow.right")
                    .foregroundColor(.orange)
            })
            .sheet(isPresented: $showingItemSelector) {
                ItemSelectorView(manul: activeManul!)
                    .environmentObject(authService)
                    .environmentObject(storeService)
            }
            .onAppear(perform: loadManul)
        }
    }
    
    // MARK: - Helper Views
    
    private func manulHabitatView(manul: Manul) -> some View {
        ZStack {
            // Background habitat
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Placeholder for actual manul image and habitat
            VStack {
                Image(systemName: "pawprint.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .foregroundColor(.orange)
                
                Text(manul.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 10)
                
                Text(manul.type.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(40)
        }
        .frame(height: 300)
        .padding(.horizontal, 20)
    }
    
    private func manulInfoCard(manul: Manul) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About \(manul.name)")
                .font(.headline)
                .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: "pawprint.fill")
                        .foregroundColor(.orange)
                        .frame(width: 25)
                    
                    Text("Type: \(manul.type.description)")
                        .font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "bag.fill")
                        .foregroundColor(.orange)
                        .frame(width: 25)
                    
                    Text("Items: \(manul.appliedItemIds.count)")
                        .font(.subheadline)
                }
                
                if let user = authService.user {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.orange)
                            .frame(width: 25)
                        
                        Text("Your Currency: \(user.currency)")
                            .font(.subheadline)
                    }
                }
            }
            .padding(15)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal, 20)
        }
    }
    
    private func manulFactsSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Pallas Cat Facts")
                .font(.headline)
                .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 15) {
                factRow(icon: "info.circle.fill", text: "Pallas's cats are about the size of domestic cats but have stockier builds")
                
                factRow(icon: "globe.americas.fill", text: "They live in the grasslands and montane steppes of Central Asia")
                
                factRow(icon: "leaf.fill", text: "Their diet consists mainly of small rodents, particularly pikas and voles")
                
                factRow(icon: "exclamationmark.triangle.fill", text: "They are listed as Near Threatened on the IUCN Red List")
            }
            .padding(15)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal, 20)
        }
    }
    
    private func conservationSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Conservation")
                .font(.headline)
                .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("The Manul Working Group is dedicated to protecting Pallas's cats in the wild.")
                    .font(.subheadline)
                    .padding(.bottom, 5)
                
                Button(action: {
                    // Open conservation website
                    if let url = URL(string: "https://www.manulworkinggroup.org") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "link")
                            .foregroundColor(.white)
                        
                        Text("Learn More")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.green)
                    .cornerRadius(8)
                }
            }
            .padding(15)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal, 20)
        }
    }
    
    private func factRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 25)
            
            Text(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    // MARK: - Actions
    
    private func loadManul() {
        guard let user = authService.user, let activeManulId = user.activeManulId else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let db = Firestore.firestore()
        db.collection("manuls").document(activeManulId).getDocument { (document, error) in
            isLoading = false
            
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            
            guard let document = document, document.exists else {
                errorMessage = "Could not find your manul"
                return
            }
            
            do {
                let manul = try document.data(as: Manul.self)
                self.activeManul = manul
            } catch {
                errorMessage = "Error loading manul data"
            }
        }
    }
}

// MARK: - Item Selector View

struct ItemSelectorView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var storeService: StoreService
    
    let manul: Manul
    @State private var selectedCategory: ItemType = .habitat
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Category selector
                Picker("Category", selection: $selectedCategory) {
                    Text("Habitat").tag(ItemType.habitat)
                    Text("Accessories").tag(ItemType.accessory)
                    Text("Toys").tag(ItemType.toy)
                    Text("Food").tag(ItemType.food)
                    Text("Background").tag(ItemType.background)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if isLoading {
                    Spacer()
                    ProgressView("Loading items...")
                    Spacer()
                } else if storeService.items.isEmpty {
                    Spacer()
                    Text("No items available")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    // Items grid
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(filteredItems) { item in
                                itemCard(item: item)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Customize \(manul.name)")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                if storeService.items.isEmpty {
                    isLoading = true
                    storeService.fetchAllItems { result in
                        isLoading = false
                    }
                }
            }
        }
    }
    
    private var filteredItems: [Item] {
        storeService.items.filter { $0.type == selectedCategory }
    }
    
    private func itemCard(item: Item) -> some View {
        let isOwned = authService.user?.ownedItemIds.contains(item.id ?? "") ?? false
        let isApplied = manul.appliedItemIds.contains(item.id ?? "")
        
        return VStack {
            // Item image placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray5))
                
                Image(systemName: "gift.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(20)
                    .foregroundColor(.orange)
            }
            .frame(height: 120)
            
            Text(item.name)
                .font(.headline)
                .lineLimit(1)
            
            Text(item.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .frame(height: 40)
            
            if isApplied {
                Button(action: {
                    // Remove item
                }) {
                    Text("Remove")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.red)
                        .cornerRadius(8)
                }
            } else if isOwned {
                Button(action: {
                    // Apply item
                }) {
                    Text("Apply")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .cornerRadius(8)
                }
            } else {
                Button(action: {
                    // Purchase item
                }) {
                    Text("\(item.cost) 💰")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .cornerRadius(8)
                }
                .disabled(authService.user?.currency ?? 0 < item.cost)
            }
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ManulView_Previews: PreviewProvider {
    static var previews: some View {
        ManulView()
            .environmentObject(AuthenticationService())
            .environmentObject(StoreService())
    }
}
