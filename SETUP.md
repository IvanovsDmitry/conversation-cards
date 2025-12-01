# Инструкция по настройке проекта

## Создание проекта в Xcode

1. Откройте Xcode
2. Выберите **File → New → Project**
3. Выберите **iOS → App**
4. Заполните:
   - **Product Name**: ConversationCards
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Minimum Deployment**: iOS 14.0
5. Выберите место для сохранения проекта
6. Нажмите **Create**

## Добавление файлов в проект

После создания проекта добавьте все файлы из папки `ConversationCards`:

1. Перетащите папки `Models`, `Views`, `Managers`, `Data` в проект Xcode
2. Убедитесь, что файлы добавлены в Target: **ConversationCards**
3. Замените содержимое файла `ContentView.swift` на содержимое из `ConversationCardsApp.swift`

## Структура файлов в Xcode

Убедитесь, что структура проекта выглядит так:

```
ConversationCards
├── ConversationCardsApp.swift
├── Models
│   ├── Card.swift
│   └── Deck.swift
├── Views
│   ├── DeckListView.swift
│   ├── CardViewerView.swift
│   ├── AddDeckView.swift
│   └── EditDeckView.swift
├── Managers
│   └── DeckManager.swift
└── Data
    └── BuiltInDecks.swift
```

## Настройка Info.plist

Убедитесь, что в `Info.plist` указано:
- **Bundle Identifier**: com.yourcompany.ConversationCards
- **Display Name**: Разговорные карты

## Запуск приложения

1. Выберите симулятор iPhone (например, iPhone 14 Pro)
2. Нажмите **Run** (⌘R) или кнопку Play

## Возможные проблемы

### Ошибка компиляции
- Убедитесь, что все файлы добавлены в Target
- Проверьте, что используется iOS 14.0 или выше
- Очистите Build Folder (⌘⇧K) и пересоберите проект

### Файлы не найдены
- Проверьте, что все файлы находятся в правильных папках
- Убедитесь, что файлы добавлены в проект (видны в навигаторе)

