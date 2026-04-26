# SwiftUI Boilerplate

A production-ready SwiftUI boilerplate with **Clean Architecture**, **FastAPI backend integration**, full **authentication flow**, **onboarding**, **Firebase-ready analytics & crash reporting**, **RevenueCat-ready in-app purchases**, **push notifications**, **theme switching**, and **multilingual (EN/TR/ES/PT) localization** — built for iOS 17.5+.

---

## Features

- **Authentication** — Sign in, sign up, forgot password, change password
- **Session persistence** — Cache-first restore via Keychain; background token validation
- **Onboarding** — 3-page animated onboarding flow with skip support
- **Profile management** — Edit name, bio, job title, location, avatar upload (with compression)
- **User list** — Paginated list with skeleton loading and detail view
- **Settings** — Expo-style settings screen with edit profile, change password, theme toggle, language picker
- **Theme switching** — Light / Dark / System with instant preview
- **Localization** — English, Turkish, Spanish, Portuguese — switchable at runtime without restart
- **In-app purchases** — `PurchaseManager` with RevenueCat integration; no-op when SDK not linked
- **Paywall** — `RevenueCatUI.PaywallView` when linked; clean placeholder otherwise
- **Analytics** — Protocol-driven; ships with no-op implementation; drops in Firebase with zero code changes
- **Crash reporting** — Same pattern as analytics; Firebase-ready
- **Push notifications** — APNs + optional FCM via Firebase; token synced to backend
- **Haptics** — `HapticsManager` for success/error feedback
- **Skeleton loading** — Shimmer effect components for async content
- **Splash screen** — Animated launch screen
- **Clean Architecture** — Domain, Data, Presentation layers fully separated
- **Dependency injection** — Environment-based `AppContainer`

---

## Architecture

The project follows **Clean Architecture** with an **MVVM** presentation pattern using the `@Observable` macro (iOS 17+).

```
┌─────────────────────────────────────────────────┐
│                  Presentation                   │
│         Views (SwiftUI) + ViewModels            │
│              (@Observable MVVM)                 │
├─────────────────────────────────────────────────┤
│                    Domain                       │
│        Entities · Use Cases · Protocols         │
├─────────────────────────────────────────────────┤
│                     Data                        │
│     Repositories · APIDataSource · DTOs         │
├─────────────────────────────────────────────────┤
│                     Core                        │
│  DI · Navigation · Theme · Cache · Services     │
└─────────────────────────────────────────────────┘
```

### Data flow

```
View → ViewModel → UseCase → Repository (Protocol)
                                    ↓
                             APIDataSource (URLSession)
                                    ↓
                          FastAPI Backend (REST)
```

---

## Project Structure

```
swiftui_boilerplate/
│
├── Core/
│   ├── AppDelegate.swift              # UIApplicationDelegate; Firebase + APNs wiring
│   ├── Cache/
│   │   └── UserCache.swift            # Keychain-backed user profile cache
│   ├── Config/
│   │   ├── APIConfig.swift            # Backend base URL (gitignored — copy from .sample)
│   │   ├── APIConfig.swift.sample     # Template to copy and configure
│   │   ├── RevenueCatConfig.swift     # RC API key (gitignored — copy from .sample)
│   │   └── RevenueCatConfig.swift.sample  # Template to copy and configure
│   ├── DI/
│   │   └── AppContainer.swift         # Dependency injection container
│   ├── Extensions/
│   │   ├── Color+Extensions.swift     # Semantic color palette
│   │   ├── String+Extensions.swift    # Validation helpers (email, trimming)
│   │   └── View+Extensions.swift      # UI utility modifiers
│   ├── Localization/
│   │   ├── LocalizationManager.swift  # Runtime language switching
│   │   └── Strings.swift              # Localization key enum
│   ├── Navigation/
│   │   ├── AppRouter.swift            # NavigationStack path manager
│   │   └── Route.swift                # AuthRoute / HomeRoute / SettingsRoute enums
│   ├── Services/
│   │   ├── AnalyticsService.swift     # Protocol + NullAnalyticsService (no-op)
│   │   ├── CrashReporter.swift        # Protocol + NullCrashReporter (no-op)
│   │   ├── FirebaseService.swift      # Typealias: Firebase or Null implementation
│   │   ├── HapticsManager.swift       # UIFeedbackGenerator helpers
│   │   ├── NotificationService.swift  # APNs / FCM token management
│   │   ├── OnboardingManager.swift    # UserDefaults-backed onboarding state
│   │   ├── PurchaseManager.swift      # RevenueCat in-app purchases (no-op without SDK)
│   │   └── TokenManager.swift         # JWT token in Keychain
│   └── Theme/
│       └── ThemeManager.swift         # Light / Dark / System theme
│
├── Data/
│   ├── DataSources/
│   │   └── APIDataSource.swift        # All HTTP calls (URLSession + JWT injection)
│   ├── DTOs/
│   │   └── APIUserDTO.swift           # Decodable user model (snake_case ↔ camelCase)
│   └── Repositories/
│       ├── APIAuthRepository.swift    # Auth operations
│       └── APIUserRepository.swift    # User/profile operations
│
├── Domain/
│   ├── Entities/
│   │   ├── AppError.swift             # Typed error enum
│   │   └── User.swift                 # Core user entity
│   ├── Repositories/
│   │   ├── AuthRepositoryProtocol.swift
│   │   └── UserRepositoryProtocol.swift
│   └── UseCases/
│       ├── FetchUsersUseCase.swift
│       ├── ForgotPasswordUseCase.swift
│       ├── SignInUseCase.swift
│       ├── SignUpUseCase.swift
│       └── UpdateProfileUseCase.swift
│
├── Presentation/
│   ├── Auth/
│   │   ├── AuthFlowView.swift         # NavigationStack root for auth
│   │   ├── ForgotPassword/
│   │   ├── SignIn/
│   │   ├── SignUp/
│   │   └── Welcome/
│   ├── Components/
│   │   ├── AppTextField.swift
│   │   ├── LoadingOverlay.swift
│   │   ├── PrimaryButton.swift
│   │   ├── SecondaryButton.swift
│   │   ├── SkeletonBox.swift          # Shimmer skeleton loading components
│   │   └── UserAvatarView.swift
│   ├── Launch/
│   │   └── LaunchView.swift           # Animated splash screen
│   ├── Paywall/
│   │   └── PaywallView.swift          # RevenueCatUI paywall or placeholder
│   ├── Main/
│   │   ├── Home/
│   │   │   ├── HomeView.swift         # Dashboard with skeleton loading
│   │   │   ├── HomeViewModel.swift
│   │   │   ├── UserDetailView.swift
│   │   │   └── UserRowView.swift
│   │   ├── MainTabView.swift
│   │   └── Settings/
│   │       ├── ChangePasswordView.swift
│   │       ├── ChangePasswordViewModel.swift
│   │       ├── SettingsView.swift     # Expo-style settings layout
│   │       └── SettingsViewModel.swift
│   └── Onboarding/
│       └── OnboardingView.swift       # 3-page animated onboarding
│
├── en.lproj/Localizable.strings       # English strings
├── tr.lproj/Localizable.strings       # Turkish strings
├── es.lproj/Localizable.strings       # Spanish strings
├── pt.lproj/Localizable.strings       # Portuguese strings
└── swiftui_boilerplateApp.swift       # @main entry point
```

---

## Quick Start

### 1. Rename the app

Run the rename script to update the bundle ID and display name in one step:

```bash
./scripts/rename-app.sh \
  --bundle-id com.yourcompany.yourapp \
  --name "Your App Name"

# Optional: also set the version
./scripts/rename-app.sh \
  --bundle-id com.yourcompany.yourapp \
  --name "Your App Name" \
  --version 1.0.0
```

What it updates automatically:
- `PRODUCT_BUNDLE_IDENTIFIER` in `project.pbxproj` (main target, Tests, UITests)
- `INFOPLIST_KEY_CFBundleDisplayName` (home screen name)
- `MARKETING_VERSION` (if `--version` provided)

To rename the Xcode **target and scheme** (optional): open Xcode → Product → Scheme → Manage Schemes.

### 2. Configure the backend URL

```bash
cp swiftui_boilerplate/Core/Config/APIConfig.swift.sample \
   swiftui_boilerplate/Core/Config/APIConfig.swift
```

Edit `APIConfig.swift`:

```swift
enum APIConfig {
    static let baseURL  = "https://api.yourapp.com"  // your backend
    static let apiPrefix = "/api/v1"

    static func authPath(_ endpoint: String) -> String { apiPrefix + "/auth" + endpoint }
    static func apiPath(_ endpoint: String) -> String  { apiPrefix + endpoint }
}
```

> `APIConfig.swift` is gitignored — never committed.

### 3. Open and run

```bash
open swiftui_boilerplate.xcodeproj
```

Select your simulator or device, press **⌘R**.

---

## Backend

This boilerplate is designed to work with the companion **FastAPI backend** (`/backend`).

### Required endpoints

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/v1/auth/sign-in/email` | Sign in → returns `{ user, session: { token, expiresAt } }` |
| `POST` | `/api/v1/auth/sign-up/email` | Sign up → same response shape |
| `POST` | `/api/v1/auth/sign-out` | Sign out |
| `GET`  | `/api/v1/auth/session` | Validate token → returns `{ user, session: { token, expiresAt } }` |
| `POST` | `/api/v1/auth/forgot-password` | Send reset email |
| `GET`  | `/api/v1/users/me` | Current user profile |
| `PATCH`| `/api/v1/users/me` | Update profile |
| `POST` | `/api/v1/users/me/avatar` | Upload avatar (multipart/form-data) |
| `POST` | `/api/v1/users/me/change-password` | Change password `{ current_password, new_password }` |
| `POST` | `/api/v1/users/me/push-token` | Register push token `{ token, platform }` |
| `GET`  | `/api/v1/users` | Paginated user list |

### Authentication

All authenticated requests send `Authorization: Bearer <token>`. The JWT is stored in the Keychain via `TokenManager` and attached by `APIClient.inject(_:)`.

### Session lifetime

The backend issues JWTs with a configurable lifetime (default 1 hour). To increase it for development, set in `backend/.env`:

```env
JWT_LIFETIME_SECONDS=2592000   # 30 days
```

---

## Firebase (Optional)

Firebase is fully optional. The project compiles and runs without it using no-op implementations.

### Without Firebase (default)

`FirebaseService.swift` resolves to:
```swift
typealias AppAnalyticsService = NullAnalyticsService  // no-op
typealias AppCrashReporter    = NullCrashReporter     // no-op
```

### Enabling Firebase

1. Create an iOS app in the [Firebase Console](https://console.firebase.google.com)
2. Download `GoogleService-Info.plist` and drag it into the Xcode project (next to `Info.plist`)
3. Add the Firebase Swift Package in Xcode:
   - **File → Add Package Dependencies**
   - URL: `https://github.com/firebase/firebase-ios-sdk`
   - Select: `FirebaseAnalytics`, `FirebaseCrashlytics`, `FirebaseMessaging`

Once the package is linked, `#if canImport(FirebaseCore)` activates automatically:
```swift
typealias AppAnalyticsService = FirebaseAnalyticsService  // real Firebase
typealias AppCrashReporter    = FirebaseCrashReporter     // real Crashlytics
```

No other code changes needed.

### Push notifications with Firebase (FCM)

When Firebase is linked, the APNs ↔ FCM bridge activates in `AppDelegate`:
- APNs device token → handed to `Messaging.messaging().apnsToken`
- FCM registration token → synced to backend via `POST /users/me/push-token`

Without Firebase, the raw APNs token is synced directly.

---

## RevenueCat (Optional)

RevenueCat is fully optional. The project compiles and runs without it — `PurchaseManager` no-ops and a placeholder paywall is shown.

### Without RevenueCat (default)

`PurchaseManager` compiles with empty `#else` branches:
- `isProUser` is always `false`
- `restorePurchases()` does nothing
- `PaywallView` shows a "Add RevenueCat packages" placeholder

### Enabling RevenueCat

1. Copy the config template and fill in your API key:

```bash
cp swiftui_boilerplate/Core/Config/RevenueCatConfig.swift.sample \
   swiftui_boilerplate/Core/Config/RevenueCatConfig.swift
```

Edit `RevenueCatConfig.swift`:

```swift
enum RevenueCatConfig {
    static let apiKey           = "appl_xxxxxxxxxxxxxxxxxxxx"  // Apple platform key
    static let proEntitlementId = "pro"                        // match your RC dashboard
}
```

> `RevenueCatConfig.swift` is gitignored — never committed.

2. Add the Swift Package in Xcode:
   - **File → Add Package Dependencies**
   - URL: `https://github.com/RevenueCat/purchases-ios`
   - Select: **RevenueCat** + **RevenueCatUI** (pre-built paywall UI)

Once the packages are linked, `#if canImport(RevenueCat)` activates automatically:
- `Purchases.configure(withAPIKey:)` runs at app launch
- Sign-in calls `Purchases.shared.logIn(userId)` to associate purchases with your user
- Sign-out calls `Purchases.shared.logOut()`
- `PurchaseManager.isProUser` reflects the `pro` entitlement in real time

```swift
// PaywallView uses the real RC paywall automatically:
typealias AppPaywallView = RevenueCatUI.PaywallView  // (conceptually)
```

No other code changes needed.

### Paywall presentation

The Settings screen includes a **Subscription** section that:
- Shows **"Upgrade to Pro"** (opens paywall sheet) when the user is not subscribed
- Shows **"Pro Active ✓"** when the `pro` entitlement is active
- Always shows **"Restore Purchases"** to handle reinstalls and device transfers

To present the paywall from anywhere in your app:

```swift
// From any view that has access to AppContainer:
container.purchaseManager.isPresentingPaywall = true
```

### Choosing a payment solution

| Option | Best for | Trade-off |
|--------|----------|-----------|
| **RevenueCat** ✓ | Most apps — cross-platform, great dashboard, A/B testing | Free up to $2.5M tracked revenue, then 1% |
| **Adapty** | High-volume apps needing cheaper pricing | Smaller community, less mature |
| **StoreKit (native)** | Zero dependencies, full control | You build everything: UI, validation, analytics |

This boilerplate ships with RevenueCat. To use StoreKit directly, remove `PurchaseManager` and use `StoreKit.Product` / `StoreKit.Transaction` APIs.

---

## Tech Stack

| Category | Technology |
|---|---|
| Language | Swift 6 |
| UI Framework | SwiftUI |
| State Management | `@Observable` (Observation framework) |
| Networking | `URLSession` async/await |
| Backend | Python FastAPI (REST + JWT) |
| Token storage | Keychain (`Security` framework) |
| User cache | Keychain (`UserCache`) |
| Navigation | `NavigationStack` + path-based routing |
| Analytics | Protocol-based; Firebase-ready |
| Crash reporting | Protocol-based; Firebase-ready |
| Push notifications | APNs / FCM via Firebase |
| In-app purchases | `PurchaseManager`; RevenueCat-ready |
| Localization | Custom `LocalizationManager` (EN / TR / ES / PT) |
| Minimum iOS | 17.5 |

---

## Customization

### Brand colors

Edit `Core/Extensions/Color+Extensions.swift`:

```swift
extension Color {
    static let appPrimary = Color.indigo   // ← your brand color
}
```

### Add a language

The boilerplate ships with **English, Turkish, Spanish, and Portuguese**.

1. Create `xx.lproj/Localizable.strings` (copy from `en.lproj` and translate)
2. Add the locale in Xcode: select the project → **Info** tab → **Localizations** → **+**
3. Add a new case to `AppLanguage` in `LocalizationManager.swift`:

```swift
case french = "fr"

var displayName: String {
    // ...
    case .french: return "Français"
}
var shortCode: String { /* ... case .french: return "FR" */ }
var flag: String      { /* ... case .french: return "🇫🇷" */ }
```

### Add a new screen

1. Create `Presentation/YourFeature/YourView.swift` + `YourViewModel.swift`
2. Add a case to the relevant route enum in `Core/Navigation/Route.swift`
3. Add a `navigationDestination` in the appropriate flow view
4. Add a `navigate(to:)` method in `AppRouter` if needed

### Add an analytics event

Conform to `AnalyticsService` in `Core/Services/AnalyticsService.swift` and call via `container.analytics`:

```swift
container.analytics.trackEvent("button_tapped", parameters: ["name": "subscribe"])
```

---

## Project Conventions

| Convention | Detail |
|---|---|
| State management | `@Observable` — no `ObservableObject` / `@StateObject` |
| `@State` properties | Always `private` |
| Injected observables | `@Bindable` when bindings needed; plain `let` otherwise |
| Async | `async/await` throughout; no Combine |
| Error handling | `AppError` typed enum; localized via `LocalizationManager` |
| Navigation | `NavigationStack` with `[Route]` path arrays |
| Dependency injection | `AppContainer` via SwiftUI `@Environment` |
| Token transport | `Authorization: Bearer` header, injected by `APIClient` |

---

## License

MIT License. See [LICENSE](LICENSE) for details.
