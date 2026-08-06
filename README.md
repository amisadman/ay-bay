<div align="center">
  <img src="assets/images/aybay-logo.png" alt="AyBay Logo" width="150" />
  
  # AyBay: The Intelligent Financial Manager
  
  **AyBay** is a comprehensive, AI-powered personal and collaborative finance management application built with Flutter. Take complete control of your income, expenses, budgets, loans, and shared events with a beautiful, flat UI design and your own personal Agentic AI assistant, **Walleo**.
</div>

---

## Overview

Managing money shouldn't be stressful. AyBay brings everything related to your finances into one unified, secure, and offline-first ecosystem with cloud collaboration features. From tracking your daily coffee to managing complex loan installments or splitting budgets for a group vacation, AyBay handles it gracefully.

Meet **Walleo**, the built-in AI agent. Walleo isn't just a chatbot; it's a proactive assistant capable of understanding complex natural language (both English and Bengali). Just tap the mic and say *"I spent 500 taka on groceries"*, and Walleo will automatically categorize and log the transaction into your database.

---

## Features

- **Agentic AI (Walleo)**: Powered by Google's Gemini, Walleo understands conversational commands, records transactions for you, and provides deep analytics on your spending habits to help you save money.
- **Income & Expense Tracking**: Beautifully visualize your cash flow with interactive charts and categorizations.
- **Loans & Owes**: Keep track of money you've lent out or borrowed. Record partial installments until fully settled.
- **Advanced Budgeting**: Set monthly budgets per category and track your progress with live progress bars.
- **Shared Event Management**: Planning a trip? Create cloud-synced events (via Firebase), add participants, pool shared budgets, and split expenses seamlessly.
- **Export Data**: Generate professional PDF or Excel reports for your personal records or tax purposes.
- **Offline First**: All your personal financial data is securely stored locally using SQLite. Only collaborative events touch the cloud.
- **Clean Aesthetic**: A gorgeous, minimalist flat UI without unnecessary gradients, ensuring a premium user experience.

---



## Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **Local Database**: [sqflite](https://pub.dev/packages/sqflite)
- **Cloud Database**: [Firebase Cloud Firestore](https://firebase.google.com/docs/firestore)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Agentic AI**: [Google Generative AI (Gemini)](https://pub.dev/packages/google_generative_ai)
- **Voice Recognition**: [speech_to_text](https://pub.dev/packages/speech_to_text)
- **UI & Animations**: [Lottie](https://pub.dev/packages/lottie), [Animated Text Kit](https://pub.dev/packages/animated_text_kit), [FL Chart](https://pub.dev/packages/fl_chart)
- **Data Export**: [pdf](https://pub.dev/packages/pdf), [excel](https://pub.dev/packages/excel)

---

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0 <4.0.0)
- Android Studio / Xcode for emulators
- A Google Gemini API Key

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/amisadman/ay-bay.git
   cd ay-bay
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure the Environment:**
   Create a `.env` file in the root directory and add your Gemini API Key:
   ```env
   GEMINI_API_KEY=AIzaSy...your_actual_key_here
   ```

4. **Run the App:**
   ```bash
   flutter run
   ```
