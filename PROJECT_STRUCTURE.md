# Структура проекта "Разговорные карты"

```
ConversationCards/
├── ConversationCardsApp.swift
├── Models/
│   ├── Card.swift
│   └── Deck.swift
├── Managers/
│   └── DeckManager.swift
├── Data/
│   └── BuiltInDecks.swift
├── Views/
│   ├── DeckListView.swift
│   ├── CardViewerView.swift
│   ├── AddDeckView.swift
│   └── EditDeckView.swift
├── README.md
├── SETUP.md
└── SUMMARY.md
```

## Компоненты
- **Card** — модель карточки с основным и дополнительным вопросом
- **Deck** — модель колоды с цветом, эмодзи и возрастным рейтингом
- **DeckManager** — ObservableObject с логикой сохранения в UserDefaults
- **BuiltInDecks** — 6 готовых наборов вопросов
- **DeckListView** — главный экран со списком колод
- **CardViewerView** — экран просмотра и переключения карточек
- **AddDeckView** — создание пользовательской колоды
- **EditDeckView** — редактирование карт внутри колоды

## Анимации и жесты
- Flip-анимация (AnyTransition.flipCard)
- Свайпы для переключения карт и удаления (iOS 15+)
- Кнопка случайной карты

## Цвета и темы
- Каждая колода имеет собственный HEX-цвет и эмодзи
- Используются системные цвета для автоматической поддержки тем

## Расширение Color
Находится в `DeckListView.swift`, добавляет инициализацию из HEX-строки.
