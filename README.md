# SalaryFlow — Advanced Personal Finance & Salary Cycle Management

A modern, local-first Android personal finance application built with Flutter, Material 3, and SQLite. SalaryFlow is engineered for salaried professionals, students, freelancers, and anyone managing flexible or non-standard salary cycles in Indian Rupees (₹).

---

## 🌟 Key Features

### 1. Advanced Salary & Income Cycle Management
- **Custom Payday Alignment**: Salary periods reflect when money actually enters your account (e.g., 25th to 24th, 1st to 30th/31st), rather than rigid calendar months.
- **Independent Monthly Overrides**: Alter the payday, gross salary, or deductions for any specific past, present, or future month without rewriting historical accounting.
- **Safe Month-End Clamping**: If your preferred payday is the 31st, SalaryFlow automatically clamps to the 28th/29th in February or 30th in shorter months without mutating your master preferences.
- **Gross vs. Deductions vs. Net Salary**: Distinct tracking for PF, Tax (TDS), and Insurance deductions.
- **Carry-Forward Balances**: Surplus or deficits from previous salary cycles transition seamlessly into the active cycle.

### 2. Multi-Account Ledger & Atomic Transfers
- **Account Types**: Salary Bank Account, Savings Bank Account, Cash Wallet, and Custom Accounts.
- **Double-Entry Transfers**: Inter-account transfers debit the source and credit the destination atomically inside SQLite database transactions without distorting income or expense statistics.
- **Editable Opening & Current Balances**: Full transparency over lifetime liquidity and protected wealth.

### 3. Expense & Transaction Flow
- **Fast Entry Interface**: Pre-configured categories, auto-selected accounts, and minimal taps.
- **Full Metadata**: Category, subcategory, merchant/payee, notes, tags, and payment mode indicators (Google Pay, PhonePe, Net Banking, Cash).
- **Search & Filter**: Search by keyword, tag, or merchant; filter by transaction type; sort by date or amount.
- **Full Ledger Controls**: Edit, duplicate, delete with safety confirmation, and swipe actions.

### 4. Dedicated Savings Vault & Goals
- **Protected Savings**: Separates core wealth from disposable daily spending money.
- **Available Spending Balance**: Instantly view what you can safely spend without dipping into your savings account.
- **Goal Progress Tracker**: Define target dates and milestone amounts (e.g., Emergency Fund, Vacation). Add funds directly with a single tap.

### 5. Category Budgets & Recurring Bills
- **Spending Warnings**: Visual alerts transition from teal to amber (>80%) and crimson (>100%).
- **Recurring Transactions**: Track rent, broadband, mutual fund SIPs, and subscriptions.
- **Skip or Pay Individual Occurrences**: Skip a single occurrence without breaking the recurring schedule.

### 6. Reports & Visual Analytics
- **Daily Spending Distribution**: Interactive bar chart displaying daily expense activity.
- **Category-Wise Spending Breakdown**: Visual progress indicators and percentage contribution.
- **Cycle Cashflow Summary**: Inflows vs. outflows vs. deductions, plus projected cycle-end surplus.

### 7. Local-First Privacy & Integrity
- **100% Offline SQLite Storage**: No accounts, no telemetry, no cloud sync required.
- **CSV Ledger Export**: Export your complete transaction history to standard CSV with one click.
- **Realistic Demo Seeder**: Includes a one-click sample dataset for instant testing.

---

## 🏗️ Architecture & Technology Stack

- **Framework**: Flutter 3.x (Dart 3)
- **Design System**: Material Design 3 (Light & Dark themes)
- **Local Database**: SQLite (`sqflite`) with schema indexing and ACID transactions
- **State Management**: Riverpod (`flutter_riverpod`)
- **Data Visualization**: `fl_chart`
- **Calendar**: `table_calendar`
- **Currency Format**: Indian Rupee (`₹`, `en_IN` formatting)

---

## 🚀 How to Build the Release APK (No Android Studio Required!)

Since your laptop does not have Flutter, Android Studio, or the Android CLI installed, you have two flexible options to obtain the installable Android APK:

### Option 1: Automated Zero-Setup Cloud Build via GitHub Actions (Recommended)

SalaryFlow includes a pre-configured GitHub Actions workflow in `.github/workflows/build_apk.yml`. You can build the APK in the cloud for free without installing anything on your laptop:

1. Create a GitHub repository (public or private) and push this repository:
   ```bash
   git init
   git add .
   git commit -m "Initial commit of SalaryFlow"
   git branch -M main
   git remote add origin https://github.com/<your-username>/SalaryFlow.git
   git push -u origin main
   ```
2. Open your repository on GitHub and click on the **Actions** tab.
3. The **Build SalaryFlow Release APK** workflow will run automatically (takes ~3 minutes).
4. When finished, click on the workflow run and download the **SalaryFlow-Release-APK** artifact.
5. Extract the ZIP to get `app-release.apk`.

---

### Option 2: Local Command-Line Build (If you install Flutter Portable)

If you later download the standalone portable Flutter SDK:
1. Extract Flutter into `C:\flutter` and add `C:\flutter\bin` to your system PATH.
2. Inside `e:\SalaryFlow`, execute:
   ```bash
   flutter pub get
   flutter analyze
   flutter test
   flutter build apk --release
   ```
3. The compiled APK will be located at:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

---

## 📱 How to Install the APK on a Physical Android Device

You do **not** need Android Studio or a computer connection once you have the APK file:

1. **Transfer the APK to your phone**:
   - Send `app-release.apk` to yourself via WhatsApp, Telegram, or email.
   - Or upload it to Google Drive and download it on your phone.
   - Or connect your phone via USB cable and copy it into the **Downloads** folder.
2. **Open the APK**:
   - On your Android phone, open the **Files** or **Downloads** app.
   - Tap on `app-release.apk`.
3. **Allow Installation from Unknown Sources**:
   - If Android shows *"For your security, your phone is not allowed to install unknown apps from this source"*, tap **Settings**.
   - Toggle **Allow from this source** to ON.
   - Press the Back button.
4. **Complete Installation**:
   - Tap **Install**.
   - Tap **Open** to launch SalaryFlow!

---

## 🧪 Unit Tests Included

SalaryFlow includes full test coverage for core financial algorithms:
- `test/date_handling_test.dart`: Validates leap years, 28/29/30/31 day months, and non-destructive salary date clamping.
- `test/salary_cycle_test.dart`: Validates default, mid-month (e.g. 25th-24th), and year-end cycle boundaries.
- `test/account_transfers_test.dart`: Validates atomic account transfers and net balance constancy.
- `test/financial_summary_test.dart`: Validates gross/net calculations, deduction totals, available spending balances, refund offsets, and savings rate percentages.

