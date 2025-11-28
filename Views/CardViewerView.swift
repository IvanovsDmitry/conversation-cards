import SwiftUI
import Combine

struct CardViewerView: View {
    @State var deck: Deck
    @ObservedObject var deckManager: DeckManager
    @State private var currentIndex: Int = 0
    @State private var isFlipped: Bool = false
    @State private var showingEditSheet = false
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            if deck.cards.isEmpty {
                VStack(spacing: 20) {
                    Text("Эта колода пуста")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Button("Добавить карту") {
                        showingEditSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                VStack(spacing: 0) {
                    // Счётчик карт
                    HStack {
                        Text("Карта \(currentIndex + 1) из \(deck.cards.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(action: {
                            showingEditSheet = true
                        }) {
                            Image(systemName: "pencil")
                                .font(.body)
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Карта
                    CardFlipView(
                        card: deck.cards[currentIndex],
                        isFlipped: $isFlipped,
                        colorHex: deck.colorHex
                    )
                    .gesture(
                        DragGesture(minimumDistance: 50)
                            .onEnded { value in
                                if value.translation.width > 0 {
                                    previousCard()
                                } else {
                                    nextCard()
                                }
                            }
                    )
                    
                    Spacer()
                    
                    // Кнопки навигации
                    VStack(spacing: 20) {
                        // Кнопка случайной карты
                        Button(action: randomCard) {
                            HStack {
                                Image(systemName: "shuffle")
                                Text("Случайная карта")
                            }
                            .font(.headline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                        }
                        
                        HStack(spacing: 40) {
                            Button(action: previousCard) {
                                Image(systemName: "chevron.left.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(currentIndex > 0 ? .blue : .gray)
                            }
                            .disabled(currentIndex == 0)
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    isFlipped.toggle()
                                }
                            }) {
                                Text(isFlipped ? "Основной вопрос" : "Дополнительный вопрос")
                                    .font(.headline)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(25)
                            }
                            
                            Button(action: nextCard) {
                                Image(systemName: "chevron.right.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(currentIndex < deck.cards.count - 1 ? .blue : .gray)
                            }
                            .disabled(currentIndex == deck.cards.count - 1)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle(deck.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            EditDeckView(deck: $deck, deckManager: deckManager)
        }
        .onAppear {
            updateDeck()
        }
        .onReceive(deckManager.$decks) { _ in
            updateDeck()
        }
    }
    
    private func nextCard() {
        if currentIndex < deck.cards.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIndex += 1
                isFlipped = false
            }
        }
    }
    
    private func previousCard() {
        if currentIndex > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIndex -= 1
                isFlipped = false
            }
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
        guard !deck.cards.isEmpty, deck.cards.count > 1 else { return }
        var newIndex = Int.random(in: 0..<deck.cards.count)
        // Если выбрали ту же карту и есть другие, выберем другую
        if newIndex == currentIndex && deck.cards.count > 1 {
            newIndex = (newIndex + 1) % deck.cards.count
        }
        withAnimation(.easeInOut(duration: 0.3)) {
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
            // Основной вопрос (лицевая сторона)
            if !isFlipped {
                CardSideView(
                    text: card.mainQuestion,
                    colorHex: colorHex,
                    isMain: true
                )
                .transition(.flipCard)
            }
            
            // Дополнительный вопрос (обратная сторона)
            if isFlipped {
                CardSideView(
                    text: card.additionalQuestion,
                    colorHex: colorHex,
                    isMain: false
                )
                .transition(.flipCard)
            }
        }
        .frame(width: 320, height: 450)
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
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
        let baseColor = Color(hex: colorHex) ?? Color.blue
        let fillColor = isMain ? baseColor.opacity(0.2) : baseColor.opacity(0.15)
        let strokeColor = baseColor.opacity(0.4)
        
        return VStack {
            Spacer()
            
            Text(text)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(fillColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(strokeColor, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
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

