# ChatBotApp

A Flutter-based Android application built as part of an internship task.
The app allows users to chat with an AI bot using the Gemini API, maintains session-wise chat history, and stores all data locally on the device.

---

## Features

* Chat with an AI bot powered by the Gemini API
* Session-wise chat history (each conversation stored separately)
* Delete individual chat sessions
* Local persistence of messages and sessions
* Simple profile page (UI only)
* Clean and minimal user interface

---

## Tech Stack

* Flutter (Android)
* Dart
* Gemini API (text generation)
* Local storage (SQLite / local database)

---

## App Flow

1. App opens on the Chat History screen
2. User can:

   * Open an existing chat session
   * Create a new chat session
   * Delete a chat session
3. Selecting a session opens the chat screen
4. Messages are stored locally and restored on app restart
5. Profile page is accessible from the main navigation

---

## Project Structure

```
lib/
├── main.dart
├── models/
│   ├── chat_message.dart
│   └── chat_session.dart
├── screens/
│   ├── session_list_screen.dart
│   ├── chat_screen.dart
│   └── profile_screen.dart
├── services/
│   ├── gemini_service.dart
│   └── local_storage_service.dart
└── widgets/
    └── chat_bubble.dart
```

---

## Setup Instructions

### Prerequisites

* Flutter SDK installed
* Android emulator or physical Android device

### Steps

1. Clone the repository
2. Create a `.env` file in the project root
3. Add your Gemini API key:

```
GEMINI_API_KEY=your_api_key_here
```

4. Install dependencies:

```
flutter pub get
```

5. Run the app:

```
flutter run
```

---

## Local Storage

* All chat messages are stored locally on the device
* Messages are grouped by chat session
* Deleting a session removes all messages associated with it

---

## Security Note

This project stores the Gemini API key on the client side for demonstration purposes only.
In a production environment, API requests should be routed through a secure backend service to prevent exposing API keys in the client application.

---

## Notes

* This project is intended for learning and evaluation purposes
* Focus is on clean structure, session handling, and local persistence
* Profile page is UI-only and does not include backend or user management

---

## Author

Sarthak Miglani
