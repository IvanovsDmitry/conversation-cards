import SwiftUI

struct DeckListView: View {
    @StateObject private var deckManager = DeckManager()
    @State private var showingAddDeck = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(deckManager.decks) { deck in
                            NavigationLink(destination: CardViewerView(deck: deck, deckManager: deckManager)) {
                                DeckCardView(deck: deck)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Button {
                            showingAddDeck = true
                        } label: {
                            AddDeckCardView()
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                }
            }
            .navigationTitle("Разговорные карты")
            .sheet(isPresented: $showingAddDeck) {
                AddDeckView(deckManager: deckManager)
            }
        }
    }
}

struct DeckCardView: View {
    let deck: Deck
    
    var body: some View {
        VStack(spacing: 12) {
            Text(deck.emoji)
                .font(.system(size: 48))
            
            Text(deck.name)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
            
            if let rating = deck.ageRating {
                Text(rating)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.15))
                    .cornerRadius(8)
            }
            
            Text("\(deck.cardCount) вопросов")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: deck.colorHex)?.opacity(0.15) ?? Color.secondary.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: deck.colorHex)?.opacity(0.3) ?? .clear, lineWidth: 1)
        )
    }
}

struct AddDeckCardView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("Добавить колоду")
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [6]))
                .foregroundColor(Color.secondary.opacity(0.3))
        )
    }
}

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
