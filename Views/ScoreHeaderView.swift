import SwiftUI

struct ScoreHeaderView: View {
    let score: Int
    let highScore: Int
    let levelTitle: String
    let timeRemaining: Int

    var body: some View {
        Grid(horizontalSpacing: 10, verticalSpacing: 10) {
            GridRow {
                MetricPill(title: "分數", value: "\(score)", color: .morandiRose)
                MetricPill(title: "最高", value: "\(highScore)", color: .morandiCoral)
            }
            GridRow {
                MetricPill(title: "冒險地圖", value: levelTitle, color: .morandiSage)
                MetricPill(title: "時間", value: "\(timeRemaining)", color: timeRemaining <= 5 ? .morandiCoral : .morandiBlue)
            }
        }
    }
}

private struct MetricPill: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline.weight(.heavy))
                .minimumScaleFactor(0.72)
                .lineLimit(1)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.24), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(color.opacity(0.45), lineWidth: 1)
        )
    }
}
