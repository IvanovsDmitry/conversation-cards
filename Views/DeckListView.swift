import SwiftUI

struct DeckListView: View {
    @StateObject private var deckManager = DeckManager()
    @State private var showingAddDeck = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 18),
        GridItem(.flexible(), spacing: 18)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 32) {
                    // Шапка - отцентрована
                    AgoraHeaderView()
                        .padding(.top, 20)
                    
                    // Сетка колод
                    LazyVGrid(columns: columns, spacing: 18) {
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
                    .padding(.horizontal, 20)
                    
                    // Футер - отцентрован
                    VStack(alignment: .center, spacing: 6) {
                        Text("АГОРА — где каждый вопрос становится мостом")
                            .font(AgoraTheme.bodySerif.italic())
                            .foregroundColor(AgoraTheme.ink.opacity(0.8))
                            .multilineTextAlignment(.center)
                        Text("«Твоя история начинается здесь»")
                            .font(.caption)
                            .foregroundColor(AgoraTheme.ink.opacity(0.5))
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
            }
            .background(AgoraTheme.background.ignoresSafeArea())
            .navigationBarHidden(true)
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
                .font(.system(size: 44))
                .padding(12)
                .background(AgoraTheme.marble)
                .clipShape(Circle())
                .overlay(Circle().stroke(AgoraTheme.gold.opacity(0.5), lineWidth: 1))
            
            VStack(spacing: 4) {
                Text(deck.name)
                    .font(AgoraTheme.bodySerif.weight(.semibold))
                    .foregroundColor(AgoraTheme.ink)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let ageRating = deck.ageRating {
                    Text(ageRating)
                        .font(.caption)
                        .foregroundColor(AgoraTheme.gold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(AgoraTheme.ink.opacity(0.08))
                        .clipShape(Capsule())
                }
                
                Text("\(deck.cardCount) вопросов")
                    .font(.caption)
                    .foregroundColor(AgoraTheme.ink.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(AgoraTheme.marble)
                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(AgoraTheme.accent.opacity(0.35), lineWidth: 1.2)
        )
    }
}

struct AddDeckCardView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "plus")
                .font(.system(size: 26, weight: .bold, design: .serif))
                .padding(18)
                .background(AgoraTheme.sea.opacity(0.2))
                .clipShape(Circle())
                .overlay(Circle().stroke(AgoraTheme.sea, lineWidth: 1))
            
            Text("Добавить свой свиток")
                .font(AgoraTheme.bodySerif.weight(.semibold))
                .foregroundColor(AgoraTheme.ink)
                .multilineTextAlignment(.center)
            
            Text("«Каждый вопрос рождает мир»")
                .font(.caption)
                .foregroundColor(AgoraTheme.ink.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .stroke(style: StrokeStyle(lineWidth: 1.2, dash: [8, 6]))
                .foregroundColor(AgoraTheme.sea.opacity(0.5))
        )
    }
}

struct AgoraHeaderView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "building.columns")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AgoraTheme.gold)
                    .padding(12)
                    .background(AgoraTheme.ink.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("АГОРА")
                        .font(AgoraTheme.headerTitle)
                        .foregroundColor(AgoraTheme.ink)
                    Text("Место встречи Я и Ты")
                        .font(AgoraTheme.headerSubtitle)
                        .foregroundColor(AgoraTheme.ink.opacity(0.7))
                }
            }
            
            VStack(alignment: .center, spacing: 6) {
                Text("Добро пожаловать в Агору")
                    .font(AgoraTheme.bodySerif.weight(.semibold))
                    .foregroundColor(AgoraTheme.accent)
                    .multilineTextAlignment(.center)
                Text("Место, где два человека становятся собеседниками")
                    .font(AgoraTheme.bodySans)
                    .foregroundColor(AgoraTheme.ink.opacity(0.75))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
    }
}
