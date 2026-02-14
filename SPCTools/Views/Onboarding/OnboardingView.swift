import SwiftUI
import RevenueCatUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var selection = 0
    @State private var showPaywall = false

    private let pages: [OnboardingPage] = [
        // Page 1: Identity
        OnboardingPage(
            title: String(localized: "onboarding.identity.title"),
            subtitle: String(localized: "onboarding.identity.subtitle"),
            systemImage: "chart.bar.doc.horizontal",
            highlights: [
                String(localized: "onboarding.identity.highlight1"),
                String(localized: "onboarding.identity.highlight2"),
                String(localized: "onboarding.identity.highlight3")
            ]
        ),
        // Page 2: Trust / Standards
        OnboardingPage(
            title: String(localized: "onboarding.trust.title"),
            subtitle: String(localized: "onboarding.trust.subtitle"),
            systemImage: "checkmark.shield.fill",
            highlights: [
                String(localized: "onboarding.trust.highlight1"),
                String(localized: "onboarding.trust.highlight2"),
                String(localized: "onboarding.trust.highlight3")
            ]
        ),
        // Page 3: Value
        OnboardingPage(
            title: String(localized: "onboarding.value.title"),
            subtitle: String(localized: "onboarding.value.subtitle"),
            systemImage: "chart.bar.doc.horizontal.fill",
            highlights: [
                String(localized: "onboarding.value.highlight1"),
                String(localized: "onboarding.value.highlight2"),
                String(localized: "onboarding.value.highlight3")
            ]
        ),
        // Page 4: Get Started
        OnboardingPage(
            title: String(localized: "onboarding.start.title"),
            subtitle: String(localized: "onboarding.start.subtitle"),
            systemImage: "play.circle.fill",
            highlights: [
                String(localized: "onboarding.start.highlight1"),
                String(localized: "onboarding.start.highlight2"),
                String(localized: "onboarding.start.highlight3")
            ]
        ),
        // Page 5: Trial CTA
        OnboardingPage(
            title: String(localized: "onboarding.trial.title"),
            subtitle: String(localized: "onboarding.trial.subtitle"),
            systemImage: "crown.fill",
            highlights: [
                String(localized: "onboarding.trial.highlight1"),
                String(localized: "onboarding.trial.highlight2"),
                String(localized: "onboarding.trial.highlight3")
            ]
        )
    ]

    private var isTrialPage: Bool {
        selection == pages.count - 1
    }

    private var isStartPage: Bool {
        selection == pages.count - 2
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
                // Skip button
                HStack {
                    Spacer()
                    if !isTrialPage {
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
                .animation(.easeInOut(duration: 0.3), value: selection)

                // Bottom buttons
                VStack(spacing: AppTheme.Spacing.medium) {
                    if isTrialPage {
                        // Trial CTA page
                        Button {
                            showPaywall = true
                        } label: {
                            Text(String(localized: "onboarding.trial.startButton"))
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppTheme.Spacing.large)
                                .background(.blue.gradient, in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.plain)

                        Button {
                            hasSeenOnboarding = true
                        } label: {
                            Text(String(localized: "onboarding.trial.maybeLater"))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)

                        Text(String(localized: "onboarding.trial.disclosure"))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)

                    } else if isStartPage {
                        // Get Started page
                        Button {
                            hasSeenOnboarding = true
                        } label: {
                            Text(String(localized: "onboarding.button.getStarted"))
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppTheme.Spacing.large)
                                .background(.blue.gradient, in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.plain)

                    } else {
                        // Pages 0-2: Next button
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selection += 1
                            }
                        } label: {
                            Text(String(localized: "onboarding.button.next"))
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppTheme.Spacing.large)
                                .background(.blue.gradient, in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.extraLarge)
            .padding(.vertical, AppTheme.Spacing.extraLarge)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallWrapperView()
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
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    OnboardingView()
}
