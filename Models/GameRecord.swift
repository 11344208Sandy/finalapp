import Foundation

struct LevelTimeEntry: Identifiable, Codable, Equatable {
    var id: Int { level }
    let level: Int
    let seconds: Double
}

enum GameEndReason: String, Codable, Equatable {
    case wrongTap
    case timeUp

    var title: String {
        switch self {
        case .wrongTap:
            return "點錯"
        case .timeUp:
            return "時間到"
        }
    }
}

struct GameRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let playedAt: Date
    let score: Int
    let reachedLevel: Int
    let completedLevels: Int
    let totalSeconds: Double
    let levelTimes: [LevelTimeEntry]
    let endReason: GameEndReason
    let difficulty: GameDifficulty

    var sequenceTitle: String {
        playedAt.formatted(date: .numeric, time: .shortened)
    }

    var reachedLevelTitle: String {
        GameLevelName.fullTitle(for: reachedLevel)
    }

    var completedLevelTitle: String {
        guard completedLevels > 0 else { return "尚未破關" }
        return GameLevelName.fullTitle(for: completedLevels)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case playedAt
        case score
        case reachedLevel
        case completedLevels
        case totalSeconds
        case levelTimes
        case endReason
        case difficulty
    }

    init(
        id: UUID,
        playedAt: Date,
        score: Int,
        reachedLevel: Int,
        completedLevels: Int,
        totalSeconds: Double,
        levelTimes: [LevelTimeEntry],
        endReason: GameEndReason,
        difficulty: GameDifficulty
    ) {
        self.id = id
        self.playedAt = playedAt
        self.score = score
        self.reachedLevel = reachedLevel
        self.completedLevels = completedLevels
        self.totalSeconds = totalSeconds
        self.levelTimes = levelTimes
        self.endReason = endReason
        self.difficulty = difficulty
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        playedAt = try container.decode(Date.self, forKey: .playedAt)
        score = try container.decode(Int.self, forKey: .score)
        reachedLevel = try container.decode(Int.self, forKey: .reachedLevel)
        completedLevels = try container.decode(Int.self, forKey: .completedLevels)
        totalSeconds = try container.decode(Double.self, forKey: .totalSeconds)
        levelTimes = try container.decode([LevelTimeEntry].self, forKey: .levelTimes)
        endReason = try container.decodeIfPresent(GameEndReason.self, forKey: .endReason) ?? .wrongTap
        difficulty = try container.decodeIfPresent(GameDifficulty.self, forKey: .difficulty) ?? .chapterOne
    }
}

struct AverageLevelTime: Identifiable, Equatable {
    var id: Int { level }
    let level: Int
    let seconds: Double

    var levelTitle: String {
        GameLevelName.fullTitle(for: level)
    }
}
