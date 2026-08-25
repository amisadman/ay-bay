<div align="center">
  <img src="assets/images/aybay-logo.png" alt="AyBay Logo" width="150" />
  
  # AyBay: The Intelligent Financial Ecosystem
  
  **AyBay** is a comprehensive, AI-powered personal and collaborative finance management application built with Flutter. Take complete control of your income, expenses, budgets, loans, shop management, and shared events with a beautiful flat UI design and your own personal Agentic AI assistant, **Walleo**.
</div>

---

## Overview

Managing money shouldn't be stressful. AyBay brings everything related to your finances into one unified, secure, and offline-first ecosystem with cloud collaboration features. From tracking your daily coffee to managing complex loan installments or splitting budgets for a group vacation, AyBay handles it gracefully.

Meet **Walleo**, the built-in AI agent. Walleo isn't just a chatbot; it's a proactive assistant capable of understanding complex natural language (both English and Bengali). Just tap the mic and say *"I spent 500 taka on groceries"*, and Walleo will automatically categorize and log the transaction into your database.

---

## Features

- **Agentic AI (Walleo)**: Powered by Groq's lightning-fast Llama-3 models, Walleo understands conversational commands, logs transactions via JSON tool calling, and provides deep analytics on your spending habits.
- **"Super-App" Modules**: Go beyond personal finance with dedicated hubs for:
  - **Shop Management**: POS, Inventory, Employee Management, and Daily Logs.
  - **Home & Apartment**: Track rent, tenants, and utility cycles.
  - **Donations**: Dedicated logging for your charitable contributions.
- **Income & Expense Tracking**: Beautifully visualize your cash flow with interactive FL charts.
- **Loans & Owes**: Keep track of money you've lent out or borrowed with partial installments.
- **Advanced Budgeting**: Set monthly budgets per category and track your progress with live progress bars.
- **Shared Event Management**: Planning a trip? Create cloud-synced events (via Firebase), add participants, pool shared budgets, and split expenses seamlessly.
- **Export Data**: Generate professional PDF or Excel reports for your personal records or tax purposes.
- **Offline First**: All your personal financial data is securely stored locally using SQLite. Only collaborative events touch the cloud.
- **Clean Aesthetic**: A gorgeous, minimalist flat UI without unnecessary gradients, featuring fluid micro-animations (Lottie) and bottom-pinned layouts.

---

## App Gallery

<table>
  <tr>
    <td align="center">
      <img src="readme/login_screen.jpg" width="180" />
      <br />
      <b>Login & Security</b>
    </td>
    <td align="center">
      <img src="readme/dashboard_screen.jpg" width="180" />
      <br />
      <b>Smart Dashboard</b>
    </td>
    <td align="center">
      <img src="readme/walleo_ai.jpg" width="180" />
      <br />
      <b>Walleo AI Agent</b>
    </td>
    <td align="center">
      <img src="readme/add_income.jpg" width="180" />
      <br />
      <b>Add Transactions</b>
    </td>
    <td align="center">
      <img src="readme/budget_management.jpg" width="180" />
      <br />
      <b>Budget Management</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="readme/loan.jpg" width="180" />
      <br />
      <b>Loan Tracker</b>
    </td>
    <td align="center">
      <img src="readme/owe_management.jpg" width="180" />
      <br />
      <b>Owe Management</b>
    </td>
    <td align="center">
      <img src="readme/owe_profile.jpg" width="180" />
      <br />
      <b>Owe Profile</b>
    </td>
    <td align="center">
      <img src="readme/daily_analytics.jpg" width="180" />
      <br />
      <b>Daily Analytics</b>
    </td>
    <td align="center">
      <img src="readme/monthly_analytics.jpg" width="180" />
      <br />
      <b>Monthly Analytics</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="readme/yearly_analytics.jpg" width="180" />
      <br />
      <b>Yearly Analytics</b>
    </td>
    <td align="center">
      <img src="readme/expense_history.jpg" width="180" />
      <br />
      <b>Expense History</b>
    </td>
    <td align="center">
      <img src="readme/hostory.jpg" width="180" />
      <br />
      <b>All History</b>
    </td>
    <td align="center">
      <img src="readme/event_management_screen.jpg" width="180" />
      <br />
      <b>Event Management</b>
    </td>
    <td align="center">
      <img src="readme/event_profile_screen.jpg" width="180" />
      <br />
      <b>Event Profile</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="readme/shopmanagement.jpg" width="180" />
      <br />
      <b>Shop Dashboard</b>
    </td>
    <td align="center">
      <img src="readme/shop_pos.jpg" width="180" />
      <br />
      <b>Shop POS</b>
    </td>
    <td align="center">
      <img src="readme/shop_inventory.jpg" width="180" />
      <br />
      <b>Shop Inventory</b>
    </td>
    <td align="center">
      <img src="readme/shop_employee.jpg" width="180" />
      <br />
      <b>Shop Employees</b>
    </td>
    <td align="center">
      <img src="readme/shop_analytics.jpg" width="180" />
      <br />
      <b>Shop Analytics</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="readme/shop_logs.jpg" width="180" />
      <br />
      <b>Shop Logs</b>
    </td>
    <td align="center">
      <img src="readme/join_shop.jpg" width="180" />
      <br />
      <b>Join Shop</b>
    </td>
    <td align="center">
      <img src="readme/home_owner.jpg" width="180" />
      <br />
      <b>Home Owner</b>
    </td>
    <td align="center">
      <img src="readme/appartment_profile.jpg" width="180" />
      <br />
      <b>Apartment Profile</b>
    </td>
    <td align="center">
      <img src="readme/donation_management.jpg" width="180" />
      <br />
      <b>Donations</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="readme/online_backup.jpg" width="180" />
      <br />
      <b>Cloud Backup</b>
    </td>
    <td align="center" colspan="4">
      <!-- Empty space for the last row -->
    </td>
  </tr>
</table>

---

## Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **Local Database**: [sqflite](https://pub.dev/packages/sqflite)
- **Cloud Database**: [Firebase Cloud Firestore](https://firebase.google.com/docs/firestore)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Agentic AI**: Groq REST API for flawless function calling
- **Voice Recognition**: [speech_to_text](https://pub.dev/packages/speech_to_text)
- **Markdown & UI**: [flutter_markdown](https://pub.dev/packages/flutter_markdown), [Lottie](https://pub.dev/packages/lottie), [Animated Text Kit](https://pub.dev/packages/animated_text_kit), [FL Chart](https://pub.dev/packages/fl_chart)
- **Data Export**: [pdf](https://pub.dev/packages/pdf), [excel](https://pub.dev/packages/excel)

---

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0 <4.0.0)
- Android Studio / Xcode for emulators
- A Groq API Key (Free tier works perfectly)

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
   Create a `.env` file in the root directory and add your Groq API Key:
   ```env
   GROQ_API_KEY=gsk_your_actual_key_here
   ```

4. **Run the App:**
   ```bash
   flutter run
   ```
