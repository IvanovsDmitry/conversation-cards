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
            AgoraTheme.background
                .ignoresSafeArea()
            
            if deck.cards.isEmpty {
                VStack(spacing: 16) {
                    Text("Колода ждёт своих вопросов")
                        .font(AgoraTheme.bodySerif)
                        .foregroundColor(AgoraTheme.accent)
                    Button("Добавь свой голос") {
                        showingEditSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                VStack(spacing: 0) {
                    // Шапка: название колоды, кнопки назад и редактирования
                    HStack(alignment: .center, spacing: 12) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AgoraTheme.ink)
                                .frame(width: 40, height: 40)
                                .background(AgoraTheme.marble)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(AgoraTheme.accent.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        VStack(spacing: 2) {
                            Text(deck.name)
                                .font(AgoraTheme.bodySerif.weight(.semibold))
                                .foregroundColor(AgoraTheme.ink)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                            Text("Карта \(currentIndex + 1) из \(deck.cards.count)")
                                .font(.caption)
                                .foregroundColor(AgoraTheme.ink.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        
                        Button {
                            showingEditSheet = true
                        } label: {
                            Image(systemName: "pencil")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AgoraTheme.accent)
                                .frame(width: 40, height: 40)
                                .background(AgoraTheme.marble)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(AgoraTheme.accent.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                    
                    Spacer()
                    
                    // Карта
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
                    
                    // Нижняя панель с кнопками
                    VStack(spacing: 16) {
                        // Кнопка случайной карты
                        Button(action: randomCard) {
                            Label("Пусть судьба выберет", systemImage: "sparkles")
                                .font(AgoraTheme.actionSans)
                                .foregroundColor(.white)
                                .padding(.horizontal, 22)
                                .padding(.vertical, 12)
                                .background(AgoraTheme.gold)
                                .clipShape(Capsule())
                        }
                        
                        // Кнопка "Погляди глубже" и стрелки навигации
                        HStack(spacing: 20) {
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
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(AgoraTheme.sea.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(AgoraTheme.sea, lineWidth: 1.5)
                                    )
                                    .foregroundColor(AgoraTheme.ink)
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
        .frame(width: 320, height: 460)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.35)) {
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
        let fillColor = isMain ? AgoraTheme.marble : AgoraTheme.marble.opacity(0.95)
        let borderColor = isMain ? AgoraTheme.gold : AgoraTheme.accent
        
        return VStack {
            Spacer()
            Text(text)
                .font(.title2.weight(.semibold))
                .foregroundColor(AgoraTheme.ink)
                .multilineTextAlignment(.center)
                .padding(24)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(fillColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(borderColor.opacity(isMain ? 0.8 : 0.5), lineWidth: 2.5)
        )
        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)
    }
}

struct AgoraNavButton: View {
    let system: String
    let enabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(enabled ? AgoraTheme.accent : AgoraTheme.ink.opacity(0.3))
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(enabled ? AgoraTheme.marble : AgoraTheme.marble.opacity(0.5))
                        .overlay(
                            Circle()
                                .stroke(enabled ? AgoraTheme.accent.opacity(0.5) : AgoraTheme.ink.opacity(0.2), lineWidth: 1.5)
                        )
                )
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
