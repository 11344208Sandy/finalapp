import Charts
import SwiftUI

struct GrowthDashboardView: View {
    @Bindable var viewModel: GameViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            analyticsScopePicker
            dashboardHeader
            ProgressChartView(records: viewModel.analyticsScoreTrendRecords)
            AverageLevelTimeView(levelTimes: viewModel.analyticsAverageLevelTimes)
            RecordSearchView(
                searchText: $viewModel.recordSearchText,
                records: viewModel.filteredRecords
            )
        }
        .padding(16)
        .background(.white.opacity(0.64), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.75), lineWidth: 1)
        )
    }

    private var analyticsScopePicker: some View {
        Picker("分析範圍", selection: $viewModel.selectedAnalyticsScope) {
            ForEach(AnalyticsScope.allCases) { scope in
                Text(scope.title)
                    .tag(scope)
            }
        }
        .pickerStyle(.menu)
        .tint(.morandiBlue)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityLabel("分析範圍")
    }

    private var dashboardHeader: some View {
        Grid(horizontalSpacing: 12, verticalSpacing: 12) {
            GridRow {
                StatBadge(title: "最高分", value: "\(viewModel.analyticsHighScore)", color: .morandiCoral)
                StatBadge(title: "遊玩次數", value: "\(viewModel.analyticsRecords.count)", color: .morandiBlue)
            }
            GridRow {
                StatBadge(title: "平均分", value: "\(viewModel.analyticsAverageScore)", color: .morandiSage)
                StatBadge(title: "時間到", value: "\(viewModel.analyticsTimeUpEndCount)", color: .morandiLavender)
            }
            GridRow {
                StatBadge(title: "點錯", value: "\(viewModel.analyticsWrongTapEndCount)", color: .morandiRose)
                StatBadge(title: "最低分", value: "\(viewModel.analyticsLowScore)", color: .morandiMint)
            }
        }
    }
}

private struct ProgressChartView: View {
    let records: [GameRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("歷程折線圖", systemImage: "chart.xyaxis.line")
                .font(.headline.weight(.bold))

            if records.count >= 2 {
                Chart(Array(records.enumerated()), id: \.element.id) { index, record in
                    LineMark(
                        x: .value("局數", index + 1),
                        y: .value("分數", record.score)
                    )
                    .foregroundStyle(Color.morandiCoral)
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("局數", index + 1),
                        y: .value("分數", record.score)
                    )
                    .foregroundStyle(Color.morandiBlue)
                }
                .chartYAxisLabel("分數")
                .chartXAxisLabel("最近局數")
                .frame(height: 180)
            } else {
                EmptyAnalyticsView(text: "完成至少 2 局後顯示進步折線圖")
                    .frame(height: 120)
            }
        }
    }
}

private struct AverageLevelTimeView: View {
    let levelTimes: [AverageLevelTime]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("每關平均花費時間", systemImage: "timer")
                .font(.headline.weight(.bold))

            if levelTimes.isEmpty {
                EmptyAnalyticsView(text: "答對關卡後開始統計平均耗時")
                    .frame(height: 96)
            } else {
                Chart(levelTimes.prefix(12)) { item in
                    BarMark(
                        x: .value("冒險地圖", item.levelTitle),
                        y: .value("秒數", item.seconds)
                    )
                    .foregroundStyle(Color.morandiSage)
                }
                .chartYAxisLabel("秒")
                .chartXAxisLabel("冒險地圖")
                .frame(height: 160)
            }
        }
    }
}

private struct RecordSearchView: View {
    @Binding var searchText: String
    let records: [GameRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("紀錄搜尋", systemImage: "magnifyingglass")
                .font(.headline.weight(.bold))

            TextField("搜尋日期、分數、章節或冒險地圖", text: $searchText)
                .textFieldStyle(.roundedBorder)

            if records.isEmpty {
                EmptyAnalyticsView(text: "沒有符合的遊戲紀錄")
                    .frame(height: 72)
            } else {
                VStack(spacing: 8) {
                    ForEach(records.prefix(6)) { record in
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(record.sequenceTitle)
                                    .font(.subheadline.weight(.semibold))
                                Text("\(record.difficulty.shortTitle)・\(record.endReason.title)結束，完成 \(record.completedLevelTitle)，總耗時 \(record.totalSeconds.formatted(.number.precision(.fractionLength(1)))) 秒")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 3) {
                                Text("\(record.score)")
                                    .font(.headline.weight(.heavy))
                                    .monospacedDigit()
                                Text(record.reachedLevelTitle)
                                    .font(.caption)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.76)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(10)
                        .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
            }
        }
    }
}

private struct StatBadge: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline.weight(.heavy))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.22), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct EmptyAnalyticsView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.white.opacity(0.42), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
