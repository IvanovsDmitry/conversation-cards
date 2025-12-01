#!/bin/bash
# Быстрая синхронизация с GitHub

cd /Users/dmitryivanov/ConversationCards

echo "🔄 Синхронизация с GitHub..."
git add .
git commit -m "Update: $(date '+%Y-%m-%d %H:%M')" 2>/dev/null || echo "Нет изменений"
git push origin main
echo "✅ Готово!"
