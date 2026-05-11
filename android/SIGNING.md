# Подпись release APK

## 1. Создать keystore (один раз на компьютере)

```bash
keytool -genkeypair -v -keystore release-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias calculator
```

Сохраните пароли и alias — они понадобятся в GitHub.

## 2. Секреты в репозитории GitHub

В **Settings → Secrets and variables → Actions** добавьте:

| Secret | Содержимое |
|--------|------------|
| `KEYSTORE_BASE64` | Файл `release-keystore.jks` в Base64 (одна строка, без переносов) |
| `KEYSTORE_PASSWORD` | Пароль keystore |
| `KEY_ALIAS` | Alias (например `calculator`) |

### Base64 keystore

**Linux / macOS:**

```bash
base64 -w0 release-keystore.jks
```

**Windows (PowerShell):**

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("release-keystore.jks")) | Set-Clipboard
```

Вставьте вывод в значение `KEYSTORE_BASE64`.

## 3. Локальная сборка с подписью

Скопируйте `release-keystore.jks` в `android/app/` и создайте `android/key.properties` (файл **не коммитьте**):

```properties
storePassword=ВАШ_ПАРОЛЬ
keyPassword=ВАШ_ПАРОЛЬ
keyAlias=calculator
storeFile=app/release-keystore.jks
```

Затем:

```bash
flutter build apk --release
```

Файлы `key.properties` и `*.jks` указаны в `.gitignore`.

## 4. Скачивание APK с GitHub Actions

Артефакт в разделе **Actions → последний запуск → Artifacts** — это обычный файл `app-release.apk`. На телефоне включите **установку из неизвестных источников** для браузера/файлового менеджера. Подпись **release** (ваш keystore) убирает предупреждение «подписано отладочным ключом» по сравнению с вариантом без секретов.
