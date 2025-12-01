import SwiftUI

struct EditDeckView: View {
    @Binding var deck: Deck
    @ObservedObject var deckManager: DeckManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingAddCard = false
    @State private var editingCard: Card?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(deck.cards) { card in
                    CardRowView(card: card, onDelete: {
                        deleteCard(card)
                    })
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingCard = card
                    }
                    .modifier(SwipeToDeleteModifier(onDelete: {
                        deleteCard(card)
                    }))
                }
            }
            .navigationTitle("Редактировать колоду")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Готово") {
                        deckManager.updateDeck(deck)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddCard = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $editingCard) { card in
                EditCardView(card: card, deck: $deck, deckManager: deckManager)
            }
            .sheet(isPresented: $showingAddCard) {
                AddCardView(deck: $deck, deckManager: deckManager)
            }
        }
    }
    
    private func deleteCard(_ card: Card) {
        deck.cards.removeAll { $0.id == card.id }
        deckManager.updateDeck(deck)
    }
}

struct CardRowView: View {
    let card: Card
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(card.mainQuestion)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(card.additionalQuestion)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.vertical, 4)
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
    }
}

// Модификатор для поддержки swipeActions на iOS 15+ и альтернативы на iOS 14
struct SwipeToDeleteModifier: ViewModifier {
    let onDelete: () -> Void
    
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive, action: onDelete) {
                        Label("Удалить", systemImage: "trash")
                    }
                }
        } else {
            content
        }
    }
}

struct EditCardView: View {
    let card: Card
    @Binding var deck: Deck
    @ObservedObject var deckManager: DeckManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var mainQuestion: String
    @State private var additionalQuestion: String
    
    init(card: Card, deck: Binding<Deck>, deckManager: DeckManager) {
        self.card = card
        self._deck = deck
        self.deckManager = deckManager
        _mainQuestion = State(initialValue: card.mainQuestion)
        _additionalQuestion = State(initialValue: card.additionalQuestion)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Основной вопрос")) {
                    TextField("Вопрос", text: $mainQuestion)
                }
                
                Section(header: Text("Дополнительный вопрос")) {
                    TextField("Дополнительный вопрос", text: $additionalQuestion)
                }
            }
            .navigationTitle("Редактировать карту")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveCard()
                    }
                    .disabled(mainQuestion.isEmpty || additionalQuestion.isEmpty)
                }
            }
        }
    }
    
    private func saveCard() {
        if let index = deck.cards.firstIndex(where: { $0.id == card.id }) {
            deck.cards[index].mainQuestion = mainQuestion
            deck.cards[index].additionalQuestion = additionalQuestion
            deckManager.updateDeck(deck)
        }
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddCardView: View {
    @Binding var deck: Deck
    @ObservedObject var deckManager: DeckManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var mainQuestion: String = ""
    @State private var additionalQuestion: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Основной вопрос")) {
                    TextField("Вопрос", text: $mainQuestion)
                }
                
                Section(header: Text("Дополнительный вопрос")) {
                    TextField("Дополнительный вопрос", text: $additionalQuestion)
                }
            }
            .navigationTitle("Новая карта")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        addCard()
                    }
                    .disabled(mainQuestion.isEmpty || additionalQuestion.isEmpty)
                }
            }
        }
    }
    
    private func addCard() {
        let newCard = Card(
            mainQuestion: mainQuestion,
            additionalQuestion: additionalQuestion
        )
        deck.cards.append(newCard)
        deckManager.updateDeck(deck)
        presentationMode.wrappedValue.dismiss()
    }
}

