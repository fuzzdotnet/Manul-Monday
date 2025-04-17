import SwiftUI
import Firebase

struct StoreView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var storeService: StoreService
    @State private var selectedCategory: ItemCategory = .all
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingSubscriptionInfo = false
    @State private var showingPurchaseConfirmation = false
    @State private var selectedItem: Item?
    @State private var selectedManul: Manul?
    @State private var purchaseType: PurchaseType = .item
    
    enum ItemCategory: String, CaseIterable {
        case all = "All"
        case habitat = "Habitat"
        case accessory = "Accessories"
        case toy = "Toys"
        case food = "Food"
        case background = "Backgrounds"
        case manul = "Manuls"
        
        var systemImage: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .habitat: return "house"
            case .accessory: return "tag"
            case .toy: return "gamecontroller"
            case .food: return "fork.knife"
            case .background: return "photo"
            case .manul: return "pawprint"
            }
        }
        
        var itemType: ItemType? {
            switch self {
            case .habitat: return .habitat
            case .accessory: return .accessory
            case .toy: return .toy
            case .food: return .food
            case .background: return .background
            case .all, .manul: return nil
            }
        }
    }
    
    enum PurchaseType {
        case item
        case manul
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                if isLoading {
                    ProgressView("Loading store items...")
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
                        
                        Button(action: loadStoreItems) {
                            Text("Try Again")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 150, height: 40)
                                .background(Color.orange)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                } else {
                    VStack(spacing: 0) {
                        // Currency display
                        currencyHeader
                        
                        // Category selector
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(ItemCategory.allCases, id: \.self) { category in
                                    categoryButton(category)
                                }
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                        }
                        .background(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                        
                        // Items grid
                        ScrollView {
                            if selectedCategory == .manul {
                                manulsGrid
                            } else {
                                itemsGrid
                            }
                            
                            // Subscription banner
                            subscriptionBanner
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                                .padding(.bottom, 30)
                        }
                    }
                }
            }
            .navigationTitle("Store")
            .navigationBarItems(trailing: Button(action: {
                // Show store info/help
            }) {
                Image(systemName: "info.circle")
                    .foregroundColor(.orange)
            })
            .onAppear(perform: loadStoreItems)
            .sheet(isPresented: $showingSubscriptionInfo) {
                SubscriptionView()
                    .environmentObject(authService)
            }
            .alert(isPresented: $showingPurchaseConfirmation) {
                purchaseConfirmationAlert
            }
        }
    }
    
    // MARK: - Views
    
    private var currencyHeader: some View {
        HStack {
            if let user = authService.user {
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.orange)
                    
                    Text("\(user.currency)")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(20)
            }
            
            Spacer()
            
            if let user = authService.user, !user.isSubscriber {
                Button(action: {
                    showingSubscriptionInfo = true
                }) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        
                        Text("Subscribe")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.white)
    }
    
    private func categoryButton(_ category: ItemCategory) -> some View {
        Button(action: {
            withAnimation {
                selectedCategory = category
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: category.systemImage)
                    .font(.system(size: 20))
                    .foregroundColor(selectedCategory == category ? .white : .orange)
                    .frame(width: 40, height: 40)
                    .background(selectedCategory == category ? Color.orange : Color.orange.opacity(0.1))
                    .cornerRadius(12)
                
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(selectedCategory == category ? .semibold : .regular)
                    .foregroundColor(selectedCategory == category ? .primary : .secondary)
            }
        }
    }
    
    private var itemsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            ForEach(filteredItems) { item in
                itemCard(item: item)
            }
        }
        .padding(20)
    }
    
    private var manulsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible())], spacing: 20) {
            ForEach(storeService.manuls.filter { !$0.isUnlocked }) { manul in
                manulCard(manul: manul)
            }
        }
        .padding(20)
    }
    
    private func itemCard(item: Item) -> some View {
        let isOwned = authService.user?.ownedItemIds.contains(item.id ?? "") ?? false
        
        return VStack {
            // Item image placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                
                Image(systemName: "gift.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(20)
                    .foregroundColor(.orange)
            }
            .frame(height: 120)
            .overlay(
                Group {
                    if item.isSubscriberOnly && !(authService.user?.isSubscriber ?? false) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                            .offset(x: -8, y: -8)
                    }
                },
                alignment: .topTrailing
            )
            
            VStack(alignment: .leading, spacing: 5) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(item.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .frame(height: 40)
                
                HStack {
                    if isOwned {
                        Text("Owned")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(5)
                    } else {
                        Text("\(item.cost) 💰")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                    
                    if !isOwned {
                        Button(action: {
                            selectedItem = item
                            purchaseType = .item
                            showingPurchaseConfirmation = true
                        }) {
                            Text("Buy")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(
                                    (authService.user?.currency ?? 0) >= item.cost ? Color.orange : Color.gray
                                )
                                .cornerRadius(5)
                        }
                        .disabled((authService.user?.currency ?? 0) < item.cost)
                    }
                }
            }
            .padding(10)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func manulCard(manul: Manul) -> some View {
        VStack {
            HStack(spacing: 15) {
                // Manul image placeholder
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.1))
                    
                    Image(systemName: "pawprint.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(20)
                        .foregroundColor(.orange)
                }
                .frame(width: 80, height: 80)
                .overlay(
                    Group {
                        if manul.isSubscriberOnly && !(authService.user?.isSubscriber ?? false) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .padding(8)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                                .offset(x: -5, y: -5)
                        }
                    },
                    alignment: .topTrailing
                )
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(manul.type.description)
                        .font(.headline)
                    
                    Text(manulDescription(for: manul.type))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Text("\(manul.unlockCost) 💰")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        Button(action: {
                            selectedManul = manul
                            purchaseType = .manul
                            showingPurchaseConfirmation = true
                        }) {
                            Text("Unlock")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(
                                    (authService.user?.currency ?? 0) >= manul.unlockCost ? Color.orange : Color.gray
                                )
                                .cornerRadius(5)
                        }
                        .disabled((authService.user?.currency ?? 0) < manul.unlockCost)
                    }
                }
            }
            .padding(15)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var subscriptionBanner: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
                
                Text("Premium Subscription")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            Text("Subscribe to unlock exclusive manuls, premium items, and earn 2x currency from quizzes!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
            
            Button(action: {
                showingSubscriptionInfo = true
            }) {
                Text("Learn More")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .cornerRadius(8)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.orange.opacity(0.1), Color.yellow.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var purchaseConfirmationAlert: Alert {
        switch purchaseType {
        case .item:
            guard let item = selectedItem else {
                return Alert(title: Text("Error"), message: Text("Item not found"), dismissButton: .default(Text("OK")))
            }
            
            return Alert(
                title: Text("Purchase \(item.name)?"),
                message: Text("This will cost \(item.cost) currency."),
                primaryButton: .default(Text("Buy")) {
                    purchaseItem(item)
                },
                secondaryButton: .cancel()
            )
            
        case .manul:
            guard let manul = selectedManul else {
                return Alert(title: Text("Error"), message: Text("Manul not found"), dismissButton: .default(Text("OK")))
            }
            
            return Alert(
                title: Text("Unlock \(manul.type.description)?"),
                message: Text("This will cost \(manul.unlockCost) currency."),
                primaryButton: .default(Text("Unlock")) {
                    purchaseManul(manul)
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private var filteredItems: [Item] {
        if selectedCategory == .all {
            return storeService.items
        } else if let itemType = selectedCategory.itemType {
            return storeService.items.filter { $0.type == itemType }
        } else {
            return []
        }
    }
    
    private func manulDescription(for type: ManulType) -> String {
        switch type {
        case .standard:
            return "The classic Pallas cat with distinctive round face and thick fur"
        case .snow:
            return "Adapted to snowy environments with lighter coloration"
        case .desert:
            return "Sandy-colored coat perfect for arid environments"
        case .mountain:
            return "Rugged mountain dweller with extra thick fur"
        case .rare:
            return "A rare variant with unique markings"
        }
    }
    
    // MARK: - Actions
    
    private func loadStoreItems() {
        isLoading = true
        errorMessage = nil
        
        // Load items
        storeService.fetchAllItems { result in
            switch result {
            case .success(_):
                // Load manuls
                storeService.fetchAllManuls { result in
                    self.isLoading = false
                    
                    switch result {
                    case .success(_):
                        break
                    case .failure(let error):
                        self.errorMessage = "Failed to load manuls: \(error.localizedDescription)"
                    }
                }
                
            case .failure(let error):
                self.isLoading = false
                self.errorMessage = "Failed to load store items: \(error.localizedDescription)"
            }
        }
    }
    
    private func purchaseItem(_ item: Item) {
        guard let userId = authService.user?.id, let itemId = item.id else {
            errorMessage = "User or item ID not found"
            return
        }
        
        isLoading = true
        
        storeService.purchaseItem(itemId: itemId, userId: userId) { result in
            self.isLoading = false
            
            switch result {
            case .success(_):
                // Refresh user data to update currency
                self.authService.fetchUser(with: userId)
            case .failure(let error):
                self.errorMessage = "Failed to purchase item: \(error.localizedDescription)"
            }
        }
    }
    
    private func purchaseManul(_ manul: Manul) {
        guard let userId = authService.user?.id, let manulId = manul.id else {
            errorMessage = "User or manul ID not found"
            return
        }
        
        isLoading = true
        
        storeService.purchaseManul(manulId: manulId, userId: userId) { result in
            self.isLoading = false
            
            switch result {
            case .success(_):
                // Refresh user data to update currency and owned manuls
                self.authService.fetchUser(with: userId)
                
                // Refresh manuls list
                self.storeService.fetchAllManuls { _ in }
            case .failure(let error):
                self.errorMessage = "Failed to purchase manul: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Subscription View

struct SubscriptionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authService: AuthenticationService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "star.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.yellow)
                            .padding(.top, 20)
                        
                        Text("Premium Subscription")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Enhance your Manul Monday experience")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 20)
                    
                    // Benefits
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Benefits")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        benefitRow(icon: "dollarsign.circle.fill", title: "2x Currency Rewards", description: "Earn double currency from all quizzes and challenges")
                        
                        benefitRow(icon: "pawprint.circle.fill", title: "Exclusive Manuls", description: "Access to special manul variants only available to subscribers")
                        
                        benefitRow(icon: "gift.fill", title: "Premium Items", description: "Unlock subscriber-only habitat items and accessories")
                        
                        benefitRow(icon: "chart.bar.fill", title: "Conservation Impact Tracker", description: "See how your subscription helps real Pallas cats")
                    }
                    .padding(.horizontal, 20)
                    
                    // Pricing
                    VStack(spacing: 15) {
                        Text("Subscription Options")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 15) {
                            subscriptionOption(
                                title: "Monthly",
                                price: "$2.99",
                                period: "per month",
                                isPopular: false
                            )
                            
                            subscriptionOption(
                                title: "Annual",
                                price: "$24.99",
                                period: "per year",
                                isPopular: true,
                                savings: "Save 30%"
                            )
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Conservation impact
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Your Impact")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("30% of all subscription revenue goes directly to the Manul Working Group to support Pallas cat conservation efforts in the wild.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                        
                        Button(action: {
                            // Open conservation website
                            if let url = URL(string: "https://www.manulworkinggroup.org") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Learn More About Conservation")
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        .padding(.top, 5)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                .padding(.bottom, 30)
            }
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Close")
                    .foregroundColor(.orange)
            })
        }
    }
    
    private func benefitRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func subscriptionOption(title: String, price: String, period: String, isPopular: Bool, savings: String? = nil) -> some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.headline)
                    
                    HStack(alignment: .firstTextBaseline) {
                        Text(price)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(period)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let savings = savings {
                        Text(savings)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                            .padding(.vertical, 3)
                            .padding(.horizontal, 8)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    // Subscribe action
                }) {
                    Text("Subscribe")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .background(Color.orange)
                        .cornerRadius(8)
                }
            }
            .padding(15)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isPopular ? Color.orange : Color.clear, lineWidth: 2)
        )
        .overlay(
            Group {
                if isPopular {
                    Text("Best Value")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.orange)
                        .cornerRadius(5)
                        .offset(y: -15)
                }
            },
            alignment: .top
        )
    }
}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView()
            .environmentObject(AuthenticationService())
            .environmentObject(StoreService())
    }
}
