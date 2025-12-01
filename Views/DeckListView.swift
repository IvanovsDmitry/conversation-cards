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
            ZStack {
                // Градиентный фон
                LinearGradient(
                    colors: [
                        AgoraTheme.background,
                        AgoraTheme.background.opacity(0.95),
                        AgoraTheme.sea.opacity(0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .center, spacing: 32) {
                        // Шапка с градиентом
                        AgoraHeaderView()
                            .padding(.top, 24)
                        
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
                        
                        // Футер
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
            }
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
        let accent = Color(hex: deck.colorHex) ?? AgoraTheme.accent
        
        VStack(spacing: 14) {
            // Эмодзи с градиентным фоном
            Text(deck.emoji)
                .font(.system(size: 48))
                .padding(16)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [accent.opacity(0.3), accent.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [accent, accent.opacity(0.5)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                )
                .shadow(color: accent.opacity(0.3), radius: 12, x: 0, y: 6)
            
            VStack(spacing: 6) {
                Text(deck.name)
                    .font(AgoraTheme.bodySerif.weight(.bold))
                    .foregroundColor(AgoraTheme.ink)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let ageRating = deck.ageRating {
                    Text(ageRating)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [AgoraTheme.gold, AgoraTheme.gold.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                
                Text("\(deck.cardCount) вопросов")
                    .font(.caption)
                    .foregroundColor(AgoraTheme.ink.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            AgoraTheme.marble,
                            AgoraTheme.marble.opacity(0.95),
                            accent.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [accent.opacity(0.4), accent.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
        .shadow(color: accent.opacity(0.15), radius: 16, x: 0, y: 8)
    }
}

struct AddDeckCardView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundColor(AgoraTheme.sea)
                .padding(20)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AgoraTheme.sea.opacity(0.2), AgoraTheme.sea.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [AgoraTheme.sea, AgoraTheme.sea.opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                )
            
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
        .frame(height: 200)
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [AgoraTheme.sea.opacity(0.6), AgoraTheme.sea.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 2, dash: [10, 8])
                )
        )
    }
}

struct AgoraHeaderView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            HStack(alignment: .center, spacing: 14) {
                // Логотип с градиентом
                Image(systemName: "building.columns")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(14)
                    .background(
                        LinearGradient(
                            colors: [AgoraTheme.ink, AgoraTheme.ink.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AgoraTheme.gold.opacity(0.5), lineWidth: 2)
                    )
                    .shadow(color: AgoraTheme.ink.opacity(0.4), radius: 12, x: 0, y: 6)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("АГОРА")
                        .font(AgoraTheme.headerTitle)
                        .foregroundColor(AgoraTheme.ink)
                    Text("Место встречи Я и Ты")
                        .font(AgoraTheme.headerSubtitle)
                        .foregroundColor(AgoraTheme.ink.opacity(0.7))
                }
            }
            
            VStack(alignment: .center, spacing: 8) {
                Text("Добро пожаловать в Агору")
                    .font(AgoraTheme.bodySerif.weight(.bold))
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
        .padding(.horizontal, 20)
    }
}
