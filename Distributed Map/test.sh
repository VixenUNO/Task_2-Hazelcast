#!/bin/bash

BASE_NODE="localhost"
BASE_URL="http://${BASE_NODE}:5701/hazelcast/rest/maps/my-map"
MC_URL="http://localhost:8080/hazelcast/rest/management/maps/my-map/size"

echo "▶️ Додавання 1000 ключів до my-map через REST API..."
for i in {0..999}; do
  curl -s -X PUT "$BASE_URL/$i" -d "value-$i" > /dev/null
done
echo "✅ Завершено додавання."

#echo "📊 Початковий розмір Map у кластері:"
#MAP_SIZE=$(curl -s "$MC_URL" | grep -o '[0-9]\+')
#echo "   ➤ Size: $MAP_SIZE записів"

echo "📈 Подивіться в Management Center: http://localhost:8080"
echo "   ➤ Ви побачите 3 активні ноди та розподіл Map по них"

Sleep 20

echo ""
echo "🚫 [TEST] Вимикаємо одну ноду: hazelcast-node3..."
docker stop task_2-hazelcast-hazelcast-node3-1 >/dev/null
sleep 10

#echo "📊 Розмір Map після відключення однієї ноди:"
#MAP_SIZE=$(curl -s "$MC_URL" | grep -o '[0-9]\+')
#echo "   ➤ Size: $MAP_SIZE записів"

echo "🔁 Перевірка кількох ключів:"
for i in 0 100 500 999; do
  VALUE=$(curl -s -X GET "$BASE_URL/$i")
  if [[ "$VALUE" == "value-"* ]]; then
    echo "✅ $i => $VALUE"
  else
    echo "❌ $i => ВТРАЧЕНО або недоступне!"
  fi
done

Sleep 20

echo ""
echo "🚫 [TEST] Вимикаємо ще одну ноду: hazelcast-node2..."
docker stop task_2-hazelcast-hazelcast-node2-1 >/dev/null
sleep 10

#echo "📊 Розмір Map після відключення ДВОХ нод:"
#MAP_SIZE=$(curl -s "$MC_URL" | grep -o '[0-9]\+')
#echo "   ➤ Size: $MAP_SIZE записів"

echo "🔁 Повторна перевірка ключів:"
for i in 0 100 500 999; do
  VALUE=$(curl -s -X GET "$BASE_URL/$i")
  if [[ "$VALUE" == "value-"* ]]; then
    echo "✅ $i => $VALUE"
  else
    echo "❌ $i => ВТРАЧЕНО або недоступне!"
  fi
done

Sleep 20

echo ""
echo "♻️ Повертаємо всі ноди назад..."
docker start task_2-hazelcast-hazelcast-node2-1 >/dev/null
docker start task_2-hazelcast-hazelcast-node3-1 >/dev/null
sleep 15

echo "🧪 Перевірка даних після відновлення нод:"
for i in 0 100 500 999; do
  VALUE=$(curl -s -X GET "$BASE_URL/$i")
  echo "🔁 $i => $VALUE"
done

echo ""
echo "🧩 ВИСНОВКИ:"
echo "▶️ Якщо після відключення 2 нод були втрати — у Map не було резервних копій."
echo "▶️ Щоб уникнути втрат — потрібно конфігурувати Map із резервуванням:"
echo ""
echo "Java:"
echo "    config.getMapConfig(\"my-map\").setBackupCount(2);"
echo ""
echo "XML:"
echo "    <map name=\"my-map\">"
echo "        <backup-count>2</backup-count>"
echo "    </map>"
echo ""
echo "✅ Це дозволить тримати копії даних на інших нодах і пережити відмову до N нод."
