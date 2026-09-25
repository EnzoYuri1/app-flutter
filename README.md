🏦 NexBank

NexBank is a mobile application developed with Flutter that simulates the basic functionalities of a modern digital banking application.

The project was created with a focus on mobile development, user experience (UX), local data persistence, and Flutter application architecture.

📚 This project was developed for academic and educational purposes.

✨ Features

👤 User registration

🔐 Login and authentication

💾 Session persistence with automatic login

💰 Dynamic balance management

💸 Transfers between accounts

📜 Transfer history

📄 Account statement

🔄 Automatic balance updates after transactions

🌙 Light and dark themes

🎨 Real-time theme switching

👁️ Hide and show balance

📱 Modern and responsive interface

🖼️ Custom application icon

🛠️ Technologies

Flutter

Dart

SQLite — local data persistence

sqflite — SQLite integration

Shared Preferences — session and preference persistence

Material Design 3 — UI components and design system

intl — date and currency formatting

flutter_launcher_icons — application icon generation

📂 Project Structure
lib/
├── models/
├── routes/
├── screens/
├── services/
└── widgets/

Directory Overview
Directory	Description
models/	Data models and application entities
routes/	Application routes and navigation
screens/	Application screens
services/	Database services and business logic
widgets/	Reusable UI components
🎯 Project Goals

The main goal of NexBank is to demonstrate the development of a modern mobile banking application using Flutter while applying fundamental mobile development concepts, such as:

Screen navigation

State management

Local data persistence

SQLite database integration

User authentication

Session management

UI componentization

User experience (UX)

Responsive design

Application architecture

Dynamic themes

📱 Main Functionality
🔐 Authentication

Users can create an account and log in to the application. Authentication data is stored locally, and the session can be persisted to enable automatic login when the application is reopened.

💰 Balance Management

The application provides a dynamic account balance that is automatically updated after transactions.

💸 Transfers

Users can make transfers between accounts. Each transaction is stored locally and can be viewed later through the transfer history.

📜 Account Statement

The statement screen allows users to view their transaction history and monitor their account activity.

🎨 Themes

NexBank supports both light and dark themes, with the ability to switch between them in real time.

Users can also hide their balance to provide additional privacy while using the application.

🚀 Getting Started
Prerequisites

Before running the project, make sure you have the following installed:

Flutter

Dart

Android Studio or another compatible development environment

Android emulator or physical device

1. Clone the repository
git clone YOUR_REPOSITORY_URL

2. Navigate to the project directory
cd nexbank

3. Install dependencies
flutter pub get

4. Run the application
flutter run

📦 Main Dependencies
dependencies:
  sqflite:
  shared_preferences:
  intl:

dev_dependencies:
  flutter_launcher_icons:

🎓 Target Audience

NexBank was developed primarily for academic and educational purposes.

The project serves as practical experience in building mobile applications with Flutter and Dart, while exploring concepts such as local databases, authentication, navigation, state management, and modern UI development.

📚 Concepts Applied

Throughout the development of NexBank, the following concepts were explored:

Flutter mobile development

Dart programming

Application architecture

SQLite databases

Local data persistence

Local authentication

Session persistence

Screen navigation

Reusable components

UI/UX design

Responsive interfaces

Dynamic themes

⚠️ Disclaimer

NexBank is an educational project and does not represent a real banking system.

All data and transactions are stored locally and are intended solely to demonstrate mobile application development concepts.

👨‍💻 Development

Developed using Flutter and Dart as part of a practical study in mobile application development.

NexBank — Academic Mobile Development Project.
