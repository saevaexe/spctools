import SwiftUI
import SwiftData

struct HistoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CalculationRecord.timestamp, order: .reverse) private var records: [CalculationRecord]
    @State private var viewModel = HistoryViewModel()
    @State private var showDeleteAlert = false

    var body: some View {
        Group {
            if records.isEmpty {
                ContentUnavailableView(
                    String(localized: "history.empty"),
                    systemImage: "clock.arrow.circlepath",
                    description: Text(String(localized: "history.emptyDescription"))
                )
            } else {
                VStack(spacing: 0) {
                    Picker(String(localized: "history.filter"), selection: $viewModel.filter) {
                        ForEach(HistoryFilter.allCases, id: \.self) { filter in
                            Text(filter.title).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    let filtered = viewModel.filteredRecords(records)
                    if filtered.isEmpty {
                        ContentUnavailableView(
                            String(localized: "history.noFavorites"),
                            systemImage: "star.slash",
                            description: Text(String(localized: "history.noFavoritesDescription"))
                        )
                    } else {
                        List {
                            ForEach(filtered) { record in
                                HistoryRowView(record: record) {
                                    viewModel.toggleFavorite(record)
                                }
                            }
                            .onDelete { indexSet in
                                let filteredList = filtered
                                for index in indexSet {
                                    viewModel.deleteRecord(filteredList[index], modelContext: modelContext)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(String(localized: "tab.history"))
        .toolbar {
            if !records.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .alert(String(localized: "history.deleteAll"), isPresented: $showDeleteAlert) {
            Button(String(localized: "action.delete"), role: .destructive) {
                viewModel.deleteAll(modelContext: modelContext)
            }
            Button(String(localized: "action.cancel"), role: .cancel) {}
        }
    }
}
