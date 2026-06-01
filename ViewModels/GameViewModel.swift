import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class GameViewModel {
    private(set) var score = 0
    private(set) var level = 1
    private(set) var timeRemaining = 30
    private(set) var restRemaining = 0
    private(set) var state: GameState = .idle
    private(set) var tiles: [ColorTile] = []
    private(set) var records: [GameRecord] = []
    var selectedDifficulty: GameDifficulty = .chapterOne
    var selectedAnalyticsScope: AnalyticsScope = .overall
    var recordSearchText = ""

    private var countdownTask: Task<Void, Never>?
    private var restTask: Task<Void, Never>?
    private var levelStartedAt = Date()
    private var successfulLevelTimes: [LevelTimeEntry] = []
    private let startingTime = 30
    private let eyeBreakSeconds = 3
    private let eyeBreakStartingLevel = 15
    private let scorePerLevel = 10
    private let recordsStorageKey = "colorDifferenceGameRecords"
    private let maxStoredRecords = 100

    init() {
        loadRecords()
    }

    var gridSideCount: Int {
        max(level + 2, 3)
    }

    var highScore: Int {
        max(records.map(\.score).max() ?? 0, score)
    }

    var lowScore: Int {
        records.map(\.score).min() ?? 0
    }

    var analyticsRecords: [GameRecord] {
        guard let difficulty = selectedAnalyticsScope.difficulty else { return records }
        return records.filter { $0.difficulty == difficulty }
    }

    var analyticsHighScore: Int {
        analyticsRecords.map(\.score).max() ?? 0
    }

    var analyticsLowScore: Int {
        analyticsRecords.map(\.score).min() ?? 0
    }

    var analyticsAverageScore: Int {
        guard !analyticsRecords.isEmpty else { return 0 }
        let totalScore = analyticsRecords.reduce(0) { $0 + $1.score }
        return totalScore / analyticsRecords.count
    }

    var analyticsTimeUpEndCount: Int {
        analyticsRecords.filter { $0.endReason == .timeUp }.count
    }

    var analyticsWrongTapEndCount: Int {
        analyticsRecords.filter { $0.endReason == .wrongTap }.count
    }

    var currentLevelTitle: String {
        GameLevelName.fullTitle(for: level)
    }

    var finalScoreText: String {
        "最終分數：\(score)"
    }

    var analyticsScoreTrendRecords: [GameRecord] {
        Array(analyticsRecords.reversed().suffix(12))
    }

    var analyticsAverageLevelTimes: [AverageLevelTime] {
        let groupedTimes = analyticsRecords
            .flatMap(\.levelTimes)
            .reduce(into: [Int: [Double]]()) { partialResult, entry in
                partialResult[entry.level, default: []].append(entry.seconds)
            }

        return groupedTimes
            .map { level, seconds in
                AverageLevelTime(
                    level: level,
                    seconds: seconds.reduce(0, +) / Double(seconds.count)
                )
            }
            .sorted { $0.level < $1.level }
    }

    var filteredRecords: [GameRecord] {
        let query = recordSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return analyticsRecords }

        return analyticsRecords.filter { record in
            record.sequenceTitle.localizedCaseInsensitiveContains(query)
                || record.difficulty.title.localizedCaseInsensitiveContains(query)
                || record.difficulty.shortTitle.localizedCaseInsensitiveContains(query)
                || record.reachedLevelTitle.localizedCaseInsensitiveContains(query)
                || GameLevelName.title(for: record.completedLevels).localizedCaseInsensitiveContains(query)
                || "\(record.score)".contains(query)
                || "\(record.reachedLevel)".contains(query)
                || "\(record.completedLevels)".contains(query)
        }
    }

    func startGame() {
        countdownTask?.cancel()
        restTask?.cancel()
        restTask = nil
        restRemaining = 0
        score = 0
        level = 1
        successfulLevelTimes = []
        state = .playing
        startLevel()
    }

    func returnToHome() {
        countdownTask?.cancel()
        countdownTask = nil
        restTask?.cancel()
        restTask = nil
        restRemaining = 0
        score = 0
        level = 1
        timeRemaining = startingTime
        successfulLevelTimes = []
        tiles = []
        state = .idle
    }

    func selectTile(_ tile: ColorTile) {
        guard state == .playing else { return }

        if tile.isDifferent {
            recordSuccessfulLevelTime()
            score += scorePerLevel
            let completedLevel = level
            level += 1

            if completedLevel >= eyeBreakStartingLevel {
                startEyeBreak()
            } else {
                startLevel()
            }
        } else {
            endGame(reason: .wrongTap)
        }
    }

    func endGame(reason: GameEndReason) {
        guard state == .playing else {
            countdownTask?.cancel()
            countdownTask = nil
            return
        }

        storeCurrentGameRecord(endReason: reason)
        state = .gameOver
        countdownTask?.cancel()
        countdownTask = nil
    }

    private func startLevel() {
        countdownTask?.cancel()
        restTask?.cancel()
        restTask = nil
        restRemaining = 0
        timeRemaining = startingTime
        levelStartedAt = Date()
        generateTiles()
        state = .playing
        startCountdown()
    }

    private func startEyeBreak() {
        countdownTask?.cancel()
        countdownTask = nil
        restTask?.cancel()
        restRemaining = eyeBreakSeconds
        state = .resting

        restTask = Task { [weak self] in
            guard let self else { return }
            while self.restRemaining > 1 {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                self.restRemaining -= 1
            }

            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            self.startLevel()
        }
    }

    private func startCountdown() {
        countdownTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                guard let self else { return }

                if self.timeRemaining > 1 {
                    self.timeRemaining -= 1
                } else {
                    self.timeRemaining = 0
                    self.endGame(reason: .timeUp)
                    return
                }
            }
        }
    }

    private func recordSuccessfulLevelTime() {
        let elapsedSeconds = min(Date().timeIntervalSince(levelStartedAt), Double(startingTime))
        successfulLevelTimes.append(
            LevelTimeEntry(
                level: level,
                seconds: max(elapsedSeconds, 0.1)
            )
        )
    }

    private func storeCurrentGameRecord(endReason: GameEndReason) {
        let failedLevelSeconds = min(Date().timeIntervalSince(levelStartedAt), Double(startingTime))
        let completedSeconds = successfulLevelTimes.reduce(0) { $0 + $1.seconds }
        let record = GameRecord(
            id: UUID(),
            playedAt: Date(),
            score: score,
            reachedLevel: level,
            completedLevels: successfulLevelTimes.count,
            totalSeconds: completedSeconds + max(failedLevelSeconds, 0),
            levelTimes: successfulLevelTimes,
            endReason: endReason,
            difficulty: selectedDifficulty
        )

        records.insert(record, at: 0)
        if records.count > maxStoredRecords {
            records = Array(records.prefix(maxStoredRecords))
        }
        saveRecords()
    }

    private func loadRecords() {
        guard let data = UserDefaults.standard.data(forKey: recordsStorageKey) else { return }
        records = (try? JSONDecoder().decode([GameRecord].self, from: data)) ?? []
    }

    private func saveRecords() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        UserDefaults.standard.set(data, forKey: recordsStorageKey)
    }

    private func generateTiles() {
        let totalCount = gridSideCount * gridSideCount
        let differentIndex = Int.random(in: 0..<totalCount)
        let baseColor = MorandiPalette.randomBaseColor()
        let differentColor = MorandiPalette.differentColor(
            from: baseColor,
            level: level,
            difficulty: selectedDifficulty
        )

        tiles = (0..<totalCount).map { index in
            ColorTile(
                id: index,
                color: index == differentIndex ? differentColor : baseColor.color,
                isDifferent: index == differentIndex
            )
        }
    }
}

private struct MorandiColor {
    let red: Double
    let green: Double
    let blue: Double

    var color: Color {
        Color(red: red, green: green, blue: blue)
    }
}

private enum MorandiPalette {
    private static let colors = [
        MorandiColor(red: 0.90, green: 0.55, blue: 0.61),
        MorandiColor(red: 0.93, green: 0.70, blue: 0.47),
        MorandiColor(red: 0.90, green: 0.82, blue: 0.42),
        MorandiColor(red: 0.60, green: 0.78, blue: 0.55),
        MorandiColor(red: 0.43, green: 0.75, blue: 0.70),
        MorandiColor(red: 0.45, green: 0.68, blue: 0.88),
        MorandiColor(red: 0.62, green: 0.58, blue: 0.88),
        MorandiColor(red: 0.78, green: 0.55, blue: 0.82),
        MorandiColor(red: 0.90, green: 0.58, blue: 0.76),
        MorandiColor(red: 0.72, green: 0.80, blue: 0.46),
        MorandiColor(red: 0.55, green: 0.80, blue: 0.88),
        MorandiColor(red: 0.88, green: 0.63, blue: 0.50)
    ]

    static func randomBaseColor() -> MorandiColor {
        colors.randomElement() ?? MorandiColor(red: 0.82, green: 0.63, blue: 0.63)
    }

    static func differentColor(from baseColor: MorandiColor, level: Int, difficulty: GameDifficulty) -> Color {
        let delta = differenceAmount(for: level) * difficulty.colorDifferenceScale
        let direction = Bool.random() ? 1.0 : -1.0
        let channel = Int.random(in: 0...2)

        let red = adjusted(baseColor.red, channel: 0, targetChannel: channel, delta: delta, direction: direction)
        let green = adjusted(baseColor.green, channel: 1, targetChannel: channel, delta: delta, direction: direction)
        let blue = adjusted(baseColor.blue, channel: 2, targetChannel: channel, delta: delta, direction: direction)

        return Color(red: red, green: green, blue: blue)
    }

    private static func differenceAmount(for level: Int) -> Double {
        switch level {
        case 1...5:
            return 0.095
        case 6...15:
            return 0.078
        default:
            return 0.065
        }
    }

    private static func adjusted(
        _ value: Double,
        channel: Int,
        targetChannel: Int,
        delta: Double,
        direction: Double
    ) -> Double {
        guard channel == targetChannel else { return value }
        return min(max(value + delta * direction, 0.0), 1.0)
    }
}
