---

# 📄 LogCmd — Логирование консольных команд игроков

Плагин для SourceMod, который логирует все консольные команды, отправленные игроками. Подходит для CSS / CSGO / TF2 и других Source-игр.

---

## 🔧 Возможности

* Логирует команды с ником, SteamID и IP.
* Разделение по игрокам: отдельный лог-файл на каждого (`/logs/details/cmd/ГОД-МЕСЯЦ/SteamID.log`).
* Выводит дату и время в каждой строке.
* Поддержка white-листа команд.
* Логирование подозрительных (неразрешённых) команд отдельно в `oddly.log`.

---

## 📂 Структура логов

Пример строки в логе:

```
2025:07:21 19:44:01 | [Nek.'a 2x2] (STEAM_0:0:30595975) [233.99.48.100] -> bind mouse1 "+attack"
```

* Все логи игроков — `addons/sourcemod/logs/details/cmd/YYYY-MM/STEAMID.log`
* Подозрительные команды — `addons/sourcemod/logs/details/cmd/YYYY-MM/oddly.log`

---

## 📜 WhiteList

Файл white-листа команд:

```
addons/sourcemod/data/logs/cmd_whitelist.ini
```

Формат:

```
say
buy
rebuy
bind
+hook
-hook
...
```

* Команды из white-листа **не попадают в oddly.log**
* Команды без префикса `!` или `sm_` проверяются на наличие в списке

---

## 📥 Установка

1. Скомпилируй `log_cmd.sp` и помести `.smx` в `addons/sourcemod/plugins/`
2. Создай файл `addons/sourcemod/data/logs/cmd_whitelist.ini`
3. Перезапусти сервер или поменяй карту

---

## ✅ Требования

* SourceMod 1.11+
* Поддержка ArrayList (по умолчанию есть в SM 1.10+)

---
