# SPC Tools - Quality Engineering Calculator

## Build & Test
```bash
xcodebuild -scheme SPCTools -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
xcodebuild test -scheme SPCTools -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Architecture: SwiftUI + MVVM + SwiftData + @Observable (iOS 17+)
- **Engine** → Pure static functions. No side effects, no imports beyond Foundation. Why: testability and reuse.
- **ViewModel** → @Observable class. Handles input parsing, validation, calls Engine. Why: keeps Views thin.
- **View** → SwiftUI. Uses ViewModel via @State. Always wrap in ScrollView + VStack. Why: consistent UX across all modules.
- **Test** → One file per Engine. XCTAssertEqual with accuracy: 1e-9. Why: floating-point math needs explicit tolerance.

## Critical Patterns (break these = bugs)
- Input parsing: `Double(text.replacingOccurrences(of: ",", with: "."))` — Turkish locale uses comma for decimals
- Spacing: `AppTheme.Spacing.*` only — hardcoded values cause inconsistency on iPad
- Corners: `AppTheme.CornerRadius.*` only
- Localization: `String(localized: "key.name")` — all user-facing strings, no hardcoded text
- iPad support: `.frame(maxWidth: 600)` on every calculator view — without this, views stretch ugly on iPad
- Premium gate: `category.isPremium && !subscriptionManager.hasFullAccess` — never bypass this check
- History: save via `CalculationRecord` SwiftData model after every successful calculation

## New Module Checklist
1. `Engines/XxxEngine.swift` — static methods
2. `ViewModels/XxxViewModel.swift` — @Observable
3. `Views/Xxx/XxxView.swift` — ScrollView + VStack
4. `SPCToolsTests/XxxEngineTests.swift` — min 5 test cases
5. Add case to `CalculationCategory` enum + set isPremium
6. Add navigation in `ContentView.destinationView(for:)`
7. Add localization keys in `Localizable.xcstrings` (TR + EN)

## Do NOT
- Create extra files or abstractions I didn't ask for — this codebase is intentionally flat
- Add error handling for impossible states — Engine inputs are already validated by ViewModel
- Modify project.pbxproj via Xcode GUI — manual management only (refs: C1, builds: B1, groups: D1)
- Rename or restructure folders — the 1:1 mapping (Engine:ViewModel:View:Test) is deliberate
- Add third-party dependencies without explicit approval — RevenueCat is the only external dep

## Subscription (RevenueCat)
- Entitlement ID: `"pro"` — 5 free calculators, 10 premium
- 7-day free trial on both plans

## Known Gotchas
- `PRODUCT_NAME` must be `"$(TARGET_NAME)"` — was broken before as `"$(ElcCalc)"` typo from Xcode GUI
- Device must be in Developer Mode + registered before archive
- pbxproj edits: always verify ref IDs don't collide with existing ones
