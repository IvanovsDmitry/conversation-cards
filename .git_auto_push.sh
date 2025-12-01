#!/bin/bash
# Автоматический коммит и push изменений

cd /Users/dmitryivanov/ConversationCards

# Проверяем, есть ли изменения
if [ -n "$(git status --porcelain)" ]; then
    echo "📝 Найдены изменения, коммитим..."
    git add .
    git commit -m "Auto-update: $(date '+%Y-%m-%d %H:%M:%S')"
    git push origin main
    echo "✅ Изменения отправлены в GitHub"
else
    echo "ℹ️  Нет изменений для коммита"
fi
