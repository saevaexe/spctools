import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var selection = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: String(localized: "onboarding.welcome.title"),
            subtitle: String(localized: "onboarding.welcome.subtitle"),
            systemImage: "chart.bar.doc.horizontal",
            highlights: [
                String(localized: "onboarding.welcome.highlight1"),
                String(localized: "onboarding.welcome.highlight2"),
                String(localized: "onboarding.welcome.highlight3")
            ]
        ),
        OnboardingPage(
            title: String(localized: "onboarding.features.title"),
            subtitle: String(localized: "onboarding.features.subtitle"),
            systemImage: "square.grid.2x2",
            highlights: [
                String(localized: "onboarding.features.highlight1"),
                String(localized: "onboarding.features.highlight2"),
                String(localized: "onboarding.features.highlight3")
            ]
        ),
        OnboardingPage(
            title: String(localized: "onboarding.getStarted.title"),
            subtitle: String(localized: "onboarding.getStarted.subtitle"),
            systemImage: "bolt.circle",
            highlights: [
                String(localized: "onboarding.getStarted.highlight1"),
                String(localized: "onboarding.getStarted.highlight2"),
                String(localized: "onboarding.getStarted.highlight3")
            ]
        )
    ]

    private var isLastPage: Bool {
        selection == pages.count - 1
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemBackground), Color(.systemTeal).opacity(0.12)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: AppTheme.Spacing.extraLarge) {
                HStack {
                    Spacer()
                    if !isLastPage {
                        Button(String(localized: "onboarding.button.skip")) {
                            hasSeenOnboarding = true
                        }
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                    }
                }

                TabView(selection: $selection) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                            .padding(.horizontal, AppTheme.Spacing.extraLarge)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .animation(.easeInOut, value: selection)

                Button {
                    if isLastPage {
                        hasSeenOnboarding = true
                    } else {
                        selection += 1
                    }
                } label: {
                    Text(isLastPage
                         ? String(localized: "onboarding.button.getStarted")
                         : String(localized: "onboarding.button.next"))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.Spacing.large)
                        .background(.blue.gradient, in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, AppTheme.Spacing.extraLarge)
            .padding(.vertical, AppTheme.Spacing.extraLarge)
        }
    }
}

private struct OnboardingPage {
    let title: String
    let subtitle: String
    let systemImage: String
    let highlights: [String]
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: AppTheme.Spacing.extraLarge) {
            Image(systemName: page.systemImage)
                .font(.system(size: 64, weight: .semibold))
                .foregroundStyle(.blue)
                .padding(.top, AppTheme.Spacing.extraLarge)

            VStack(spacing: AppTheme.Spacing.medium) {
                Text(page.title)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: AppTheme.Spacing.regular) {
                ForEach(page.highlights, id: \.self) { item in
                    HStack(spacing: AppTheme.Spacing.medium) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text(item)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppTheme.Spacing.large)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    OnboardingView()
}
