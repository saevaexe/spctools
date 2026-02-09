import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var showPaywall = false

    private var columns: [GridItem] {
        let count = sizeClass == .regular ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: AppTheme.Spacing.large), count: count)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                SearchBarView(
                    text: $viewModel.searchText,
                    placeholder: String(localized: "search.placeholder")
                )
                .padding(.horizontal)

                subscriptionBanner

                LazyVGrid(columns: columns, spacing: AppTheme.Spacing.large) {
                    ForEach(Array(viewModel.filteredCategories.enumerated()), id: \.element.id) { index, category in
                        let needsPaywall = category.isPremium && !subscriptionManager.hasFullAccess

                        if needsPaywall {
                            Button {
                                showPaywall = true
                            } label: {
                                CategoryCardView(
                                    category: category,
                                    animationDelay: Double(index) * 0.05,
                                    showProBadge: true
                                )
                            }
                            .buttonStyle(.plain)
                        } else {
                            NavigationLink(value: category) {
                                CategoryCardView(
                                    category: category,
                                    animationDelay: Double(index) * 0.05
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(String(localized: "app.title"))
    }

    @ViewBuilder
    private var subscriptionBanner: some View {
        if subscriptionManager.isSubscribed {
            EmptyView()
        } else if subscriptionManager.isTrialActive {
            HStack {
                Image(systemName: "clock.fill")
                Text(String(localized: "subscription.trial.banner \(subscriptionManager.trialDaysRemaining)"))
                    .font(.subheadline.bold())
                Spacer()
            }
            .foregroundStyle(.white)
            .padding()
            .background(.blue.gradient, in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
            .padding(.horizontal)
        } else {
            Button {
                showPaywall = true
            } label: {
                HStack {
                    Image(systemName: "star.fill")
                    Text(String(localized: "subscription.expired.banner"))
                        .font(.subheadline.bold())
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(.white)
                .padding()
                .background(.orange.gradient, in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
        }
    }
}
