import SwiftUI

struct FormulaReferenceView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                formulaSection(
                    title: "Cp / Cpk",
                    formulas: [
                        ("Cp", "(USL - LSL) / 6σ"),
                        ("Cpu", "(USL - μ) / 3σ"),
                        ("Cpl", "(μ - LSL) / 3σ"),
                        ("Cpk", "min(Cpu, Cpl)"),
                    ]
                )

                formulaSection(
                    title: "OEE",
                    formulas: [
                        (String(localized: "formula.availability"), "(Planned - Downtime) / Planned × 100"),
                        (String(localized: "formula.performance"), "Ideal Cycle × Total Count / Run Time × 100"),
                        (String(localized: "formula.quality"), "(Total - Defects) / Total × 100"),
                        ("OEE", "A × P × Q / 10000"),
                    ]
                )

                formulaSection(
                    title: String(localized: "formula.sigmaLevel"),
                    formulas: [
                        ("DPMO", "Defects / (Units × Opportunities) × 10⁶"),
                        ("Yield", "(1 - DPMO / 10⁶) × 100"),
                        ("σ Level", "Z⁻¹(1 - DPMO/10⁶) + 1.5"),
                    ]
                )

                formulaSection(
                    title: String(localized: "formula.sampleSize"),
                    formulas: [
                        ("n (proportion)", "Z²·p·(1-p) / E²"),
                        ("n (mean)", "(Z·σ / E)²"),
                        (String(localized: "formula.finiteCorrection"), "n / (1 + (n-1)/N)"),
                    ]
                )

                formulaSection(
                    title: "Pp / Ppk",
                    formulas: [
                        ("Pp", "(USL - LSL) / 6s"),
                        ("Ppk", "min(Ppu, Ppl)"),
                    ]
                )

                formulaSection(
                    title: String(localized: "formula.controlCharts"),
                    formulas: [
                        ("X̄ (CL)", "Grand Mean"),
                        ("UCL (X̄)", "X̄ + A₂·R̄"),
                        ("LCL (X̄)", "X̄ - A₂·R̄"),
                        ("UCL (R)", "D₄·R̄"),
                        ("LCL (R)", "D₃·R̄"),
                    ]
                )

                formulaSection(
                    title: "FMEA",
                    formulas: [
                        ("RPN", "Severity × Occurrence × Detection"),
                    ]
                )
            }
            .padding()
            .frame(maxWidth: 600)
        }
        .navigationTitle(String(localized: "category.formulaReference"))
    }

    private func formulaSection(title: String, formulas: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            Text(title)
                .font(.headline)
                .padding(.horizontal, AppTheme.Spacing.small)

            VStack(spacing: 1) {
                ForEach(formulas, id: \.0) { name, formula in
                    HStack {
                        Text(name)
                            .font(.subheadline.bold())
                            .frame(width: 100, alignment: .leading)
                        Text("=")
                            .foregroundStyle(.secondary)
                        Text(formula)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(AppTheme.Spacing.regular)
                    .background(.regularMaterial)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
        }
    }
}
