#!/bin/bash
# Автоматический pull перед началом работы

cd /Users/dmitryivanov/ConversationCards

echo "📥 Загружаю последние изменения с GitHub..."
git pull origin main
echo "✅ Синхронизировано!"
