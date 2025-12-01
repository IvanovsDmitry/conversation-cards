import SwiftUI
import Combine

struct CardViewerView: View {
    @State var deck: Deck
    @ObservedObject var deckManager: DeckManager
    @Environment(\.presentationMode) var presentationMode
    @State private var currentIndex: Int = 0
    @State private var isFlipped: Bool = false
    @State private var showingEditSheet = false
    
    var body: some View {
        ZStack {
            // Градиентный фон в цветах Агоры
            LinearGradient(
                colors: [
                    AgoraTheme.ink.opacity(0.95),
                    AgoraTheme.ink.opacity(0.85),
                    AgoraTheme.accent.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if deck.cards.isEmpty {
                VStack(spacing: 20) {
                    Text("Колода ждёт своих вопросов")
                        .font(AgoraTheme.bodySerif)
                        .foregroundColor(AgoraTheme.gold)
                    Button("Добавь свой голос") {
                        showingEditSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                VStack(spacing: 0) {
                    // Шапка с градиентным фоном
                    HStack(alignment: .center, spacing: 12) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(
                                    LinearGradient(
                                        colors: [AgoraTheme.gold, AgoraTheme.gold.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .shadow(color: AgoraTheme.gold.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        
                        VStack(spacing: 4) {
                            Text(deck.name)
                                .font(AgoraTheme.bodySerif.weight(.bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                            Text("Карта \(currentIndex + 1) из \(deck.cards.count)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        
                        Button {
                            showingEditSheet = true
                        } label: {
                            Image(systemName: "pencil")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(
                                    LinearGradient(
                                        colors: [AgoraTheme.sea, AgoraTheme.sea.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .shadow(color: AgoraTheme.sea.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                    
                    Spacer()
                    
                    // Карта с градиентом
                    CardFlipView(
                        card: deck.cards[currentIndex],
                        isFlipped: $isFlipped,
                        colorHex: deck.colorHex
                    )
                    .gesture(
                        DragGesture(minimumDistance: 40)
                            .onEnded { value in
                                if value.translation.width > 0 {
                                    previousCard()
                                } else {
                                    nextCard()
                                }
                            }
                    )
                    
                    Spacer()
                    
                    // Нижняя панель
                    VStack(spacing: 18) {
                        // Кнопка случайной карты с градиентом
                        Button(action: randomCard) {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 18, weight: .bold))
                                Text("Пусть судьба выберет")
                                    .font(AgoraTheme.actionSans)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [AgoraTheme.gold, AgoraTheme.gold.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(color: AgoraTheme.gold.opacity(0.5), radius: 12, x: 0, y: 6)
                        }
                        
                        // Кнопка переворота и стрелки
                        HStack(spacing: 16) {
                            // Стрелка влево
                            AgoraNavButton(system: "chevron.left", enabled: currentIndex > 0) {
                                previousCard()
                            }
                            
                            // Кнопка переворота
                            Button {
                                withAnimation(.easeInOut(duration: 0.35)) {
                                    isFlipped.toggle()
                                }
                            } label: {
                                Text(isFlipped ? "Вернуться к началу" : "Погляди глубже")
                                    .font(AgoraTheme.actionSans)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 14)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        LinearGradient(
                                            colors: [AgoraTheme.sea.opacity(0.3), AgoraTheme.sea.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 28)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [AgoraTheme.sea, AgoraTheme.sea.opacity(0.6)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 28))
                            }
                            
                            // Стрелка вправо
                            AgoraNavButton(system: "chevron.right", enabled: currentIndex < deck.cards.count - 1) {
                                nextCard()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingEditSheet) {
            EditDeckView(deck: $deck, deckManager: deckManager)
        }
        .onAppear(perform: updateDeck)
        .onReceive(deckManager.$decks) { _ in
            updateDeck()
        }
    }
    
    private func nextCard() {
        guard currentIndex < deck.cards.count - 1 else { return }
        withAnimation(.easeInOut(duration: 0.35)) {
            currentIndex += 1
            isFlipped = false
        }
    }
    
    private func previousCard() {
        guard currentIndex > 0 else { return }
        withAnimation(.easeInOut(duration: 0.35)) {
            currentIndex -= 1
            isFlipped = false
        }
    }
    
    private func updateDeck() {
        if let updatedDeck = deckManager.decks.first(where: { $0.id == deck.id }) {
            deck = updatedDeck
            if currentIndex >= deck.cards.count {
                currentIndex = max(0, deck.cards.count - 1)
            }
        }
    }
    
    private func randomCard() {
        guard deck.cards.count > 1 else { return }
        var newIndex = Int.random(in: 0..<deck.cards.count)
        if newIndex == currentIndex {
            newIndex = (newIndex + 1) % deck.cards.count
        }
        withAnimation(.easeInOut(duration: 0.35)) {
            currentIndex = newIndex
            isFlipped = false
        }
    }
}

struct CardFlipView: View {
    let card: Card
    @Binding var isFlipped: Bool
    let colorHex: String
    
    var body: some View {
        ZStack {
            if !isFlipped {
                CardSideView(
                    text: card.mainQuestion,
                    colorHex: colorHex,
                    isMain: true
                )
                .transition(.flipCard)
            }
            
            if isFlipped {
                CardSideView(
                    text: card.additionalQuestion,
                    colorHex: colorHex,
                    isMain: false
                )
                .transition(.flipCard)
            }
        }
        .frame(width: 340, height: 480)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.4)) {
                isFlipped.toggle()
            }
        }
    }
}

struct CardSideView: View {
    let text: String
    let colorHex: String
    let isMain: Bool
    
    var body: some View {
        let accent = Color(hex: colorHex) ?? AgoraTheme.accent
        let gradientColors = isMain ? [
            accent.opacity(0.9),
            accent.opacity(0.7),
            AgoraTheme.gold.opacity(0.3)
        ] : [
            AgoraTheme.ink.opacity(0.8),
            accent.opacity(0.6),
            AgoraTheme.sea.opacity(0.4)
        ]
        
        return VStack {
            Spacer()
            Text(text)
                .font(.title2.weight(.bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(28)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.3), .white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 24, x: 0, y: 12)
    }
}

struct AgoraNavButton: View {
    let system: String
    let enabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(enabled ? .white : .white.opacity(0.4))
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(
                            enabled ?
                            LinearGradient(
                                colors: [AgoraTheme.accent, AgoraTheme.accent.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [.gray.opacity(0.3), .gray.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.2), lineWidth: 1.5)
                        )
                )
                .shadow(color: enabled ? AgoraTheme.accent.opacity(0.4) : .clear, radius: 8, x: 0, y: 4)
        }
        .disabled(!enabled)
    }
}

extension AnyTransition {
    static var flipCard: AnyTransition {
        .asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        )
    }
}
