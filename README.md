# PayQuick — iOS Transaction Viewer

A native iOS app built as part of the PayQuick Engineering Challenge.

---

## Requirements

- iOS 16+
- Xcode 15+
- Swift 5.9+
- Node.js v22+ (for the mock API)

---

## Getting Started

### 1. Clone the repo
```bash
git clone https://github.com/franzhenrideguzman/pay-quick.git
cd pay-quick
```

### 2. Run the mock API
```bash
cd fe_challenge_api
npm install
npm run dev
```
API runs on `http://localhost:3000`

### 3. Open the app
Open `Pay Quick.xcodeproj` in Xcode, select a simulator and hit `Cmd + R`.

### Demo credentials
```
Email:    smith@example.com
Password: pass123
```

---

## Features

- **Login** — Email and password authentication
- **Transaction List** — Grouped by month, newest first
- **Infinite Scroll** — Automatically loads next page when reaching the bottom
- **Token Refresh** — Automatically refreshes expired access tokens on 401
- **Logout** — Clears session and returns to login screen
- **Pull to Refresh** — Swipe down to reload transactions

---

## Architecture

Clean Architecture with MVVM presentation layer.
```
Pay Quick/
├── App/                    → Entry point, Coordinator, AppSession
├── Core/
│   ├── Network/            → APIClient, Endpoints, TokenRefreshInterceptor
│   ├── Keychain/           → Secure token storage
│   └── DI/                 → Dependency injection container
├── Domain/
│   ├── Models/             → User, Transaction (pure Swift, no frameworks)
│   └── Repositories/       → Repository protocols
├── Data/
│   ├── DTOs/               → API response models + mapping
│   └── Repositories/       → Concrete repository implementations
├── Features/
│   ├── Auth/               → Login screen
│   └── Transactions/       → Transaction list screen
└── DesignSystem/           → Colors, fonts, reusable components
```

### Key decisions

| Decision | Reason |
|---|---|
| Clean Architecture | Domain layer is framework-free and fully unit-testable |
| MVVM | Views are purely declarative, no logic |
| Coordinator pattern | Navigation decoupled from ViewModels |
| Keychain storage | Tokens encrypted at rest, device-only |
| TokenRefreshInterceptor | Transparent 401 handling, ViewModels never see token errors |
| Swift actor | Prevents multiple simultaneous refresh calls |

---

## Running Tests
```bash
Cmd + U
```

**22 tests** across:
- `LoginViewModelTests` — 10 tests
- `TransactionListViewModelTests` — 12 tests

---

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/v1/login` | Authenticate user |
| POST | `/api/v1/token/refresh` | Refresh access token |
| GET | `/api/v1/transactions?page=1` | Fetch paginated transactions |
