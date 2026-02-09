# SPC Tools - Quality Engineering Calculator

## Project Info
- **Bundle ID:** com.osmanseven.spctools
- **Team ID:** 5V9A3GUJ32
- **iOS Target:** 17.0+
- **Languages:** TR + EN
- **Architecture:** SwiftUI + MVVM + SwiftData + @Observable

## Build & Test
```bash
# Build
xcodebuild -scheme SPCTools -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Test
xcodebuild test -scheme SPCTools -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Archive
xcodebuild archive -scheme SPCTools -archivePath build/SPCTools.xcarchive
```

## Architecture Rules
- **Engine:** Pure static functions, no dependencies. One per calculator module.
- **ViewModel:** @Observable class, handles input parsing, validation, calls Engine.
- **View:** SwiftUI, uses ViewModel via @State, uses Components.
- **Test:** One test file per Engine, XCTAssertEqual with accuracy: 1e-9.

## New Module Checklist
1. `Engines/XxxEngine.swift` - Static calculation methods
2. `ViewModels/XxxViewModel.swift` - @Observable, input/output state
3. `Views/Xxx/XxxView.swift` - SwiftUI UI with ScrollView + VStack
4. `SPCToolsTests/XxxEngineTests.swift` - Unit tests
5. Add case to `CalculationCategory` enum
6. Add navigation in `ContentView.destinationView(for:)`
7. Add localization keys in `Localizable.xcstrings`
8. Add maxWidth: 600 for iPad support

## Key Patterns
- Input parsing: `Double(text.replacingOccurrences(of: ",", with: "."))`
- All spacing via `AppTheme.Spacing.*`
- All corners via `AppTheme.CornerRadius.*`
- Localization: `String(localized: "key.name")`
- History: `CalculationRecord` SwiftData model
- Premium check: `category.isPremium && !subscriptionManager.hasFullAccess`

## File Structure
```
SPCTools/
├── App/           → SPCToolsApp, AppConstants, AppTheme, SubscriptionManager
├── Models/        → CalculationCategory, CalculationRecord, QualityUnit
├── Engines/       → Pure calculation logic (static structs)
├── ViewModels/    → @Observable state management
├── Views/         → SwiftUI screens (one folder per module)
├── Components/    → Reusable UI (InputFieldView, ResultCardView, etc.)
├── Extensions/    → Double+Formatting, View+HideKeyboard
└── Resources/     → Localizable.xcstrings
```

## Modules (15 Calculators)
### Free (5):
1. Cp/Cpk - Process capability index
2. OEE - Overall Equipment Effectiveness
3. Sigma Level - DPMO ↔ Sigma conversion
4. Sample Size - Confidence level, margin of error → n
5. Formula Reference - Quick-access formula library

### Premium (10):
6. Pp/Ppk - Process performance index
7. Control Charts - X-bar R, I-MR (with Swift Charts)
8. Gage R&R - Measurement System Analysis
9. AQL Table - ISO 2859-1 sampling plans
10. Pareto Analysis - 80/20 rule with cumulative %
11. Histogram - Frequency distribution
12. FMEA - RPN calculation
13. Ishikawa - Fishbone diagram template
14. Alpha/Beta Error - Type I/II error, power analysis
15. Hypothesis Test - t-test, z-test

## Subscription
- Monthly: com.spctools.pro.monthly ($2.99)
- Yearly: com.spctools.pro.yearly ($19.99)
- 7-day free trial

## Git Workflow
- `main` → stable, merge only
- `feature/xxx` → feature branches
- Tags: v0.1-phase1, v0.2-phase2, v1.0-release

## project.pbxproj
- File refs: C1xxxxxx
- Build files: B1xxxxxx
- Groups: D1xxxxxx
- Manual management, no Xcode GUI edits to pbxproj
