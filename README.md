# Novel Mobile App

Flutter mobile app with a FastAPI backend and MySQL database for an Inkitt-style reading experience.

## Stack

- Flutter + Dart frontend
- Python FastAPI backend
- MySQL database through XAMPP

## Project Structure

- `lib/` Flutter UI and API client
- `backend/app/` FastAPI code
- `backend/sql/setup.sql` one-run database and sample data setup
- `story_card_images/` folder for your story card images
- `assets/images/` folder for additional UI images

## 1. Start XAMPP

1. Open XAMPP Control Panel.
2. Start `Apache` and `MySQL`.
3. Make sure MySQL is running on port `3306`.

## 2. Create Database From One SQL File

Option A: phpMyAdmin

1. Open `http://localhost/phpmyadmin`.
2. Select the `novel_app_db` database if it already exists.
3. Click `Import`.
4. Choose `backend/sql/setup.sql`.
5. Set `Format` to `SQL`.
6. Click `Go`.

If phpMyAdmin shows `Incorrect format parameter` but tables were created, do not ignore it immediately.

Run these checks first:

```sql
USE novel_app_db;
SHOW TABLES;
SELECT COUNT(*) AS books_count FROM books;
SELECT COUNT(*) AS notifications_count FROM notifications;
```

If `books_count` or `notifications_count` is `0`, import did not fully finish. Re-run using CLI (recommended).

Option B: MySQL command line (recommended)

```powershell
cd c:\lakmal_code\novel_mobile_app\novel_mobile_app
mysql -u root < backend\sql\setup.sql
```

If your MySQL root user has a password:

```powershell
mysql -u root -p < backend\sql\setup.sql
```

This script will:

- Create the `novel_app_db` database
- Create all required tables
- Insert starter data for the UI

## 3. Run FastAPI Backend

```powershell
cd c:\lakmal_code\novel_mobile_app\novel_mobile_app\backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
Copy-Item .env.example .env
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Backend URL:

- `http://127.0.0.1:8000` on desktop/iOS simulator
- `http://10.0.2.2:8000` from Android emulator

## 4. Run Flutter App

```powershell
cd c:\lakmal_code\novel_mobile_app\novel_mobile_app
flutter pub get
flutter run
```

## 5. Test On Your Physical Android Phone

1. Connect phone with USB and enable USB debugging.
2. Verify device:

```powershell
adb devices
```

3. Keep backend running:

```powershell
cd c:\lakmal_code\novel_mobile_app\novel_mobile_app\backend
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

4. In another terminal run Flutter with direct API override:

```powershell
cd c:\lakmal_code\novel_mobile_app\novel_mobile_app
flutter run --dart-define=API_BASE_URL=http://YOUR_PC_IP:8000
```

Use your computer LAN IP (example `192.168.1.10`).

Alternative over USB (no LAN IP needed):

```powershell
adb reverse tcp:8000 tcp:8000
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

## 6. Add Your Real Images

Put story covers inside `story_card_images/` and any extra UI assets inside `assets/images/`.

Suggested files:

- book covers
- profile banner
- avatar
- achievement art

The app currently uses styled placeholders so it still runs before you add your real assets.

## Notes

- The Flutter app falls back to local sample data if the backend is not running.
- Once you provide your real images, I can wire them into the exact widgets and asset paths.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
