import Foundation

enum AnalyticsScope: String, CaseIterable, Identifiable {
    case overall
    case chapterOne
    case chapterTwo
    case chapterThree
    case chapterFour
    case chapterFive

    var id: Self { self }

    var title: String {
        switch self {
        case .overall:
            return "整體表現"
        case .chapterOne:
            return GameDifficulty.chapterOne.analyticsTitle
        case .chapterTwo:
            return GameDifficulty.chapterTwo.analyticsTitle
        case .chapterThree:
            return GameDifficulty.chapterThree.analyticsTitle
        case .chapterFour:
            return GameDifficulty.chapterFour.analyticsTitle
        case .chapterFive:
            return GameDifficulty.chapterFive.analyticsTitle
        }
    }

    var difficulty: GameDifficulty? {
        switch self {
        case .overall:
            return nil
        case .chapterOne:
            return .chapterOne
        case .chapterTwo:
            return .chapterTwo
        case .chapterThree:
            return .chapterThree
        case .chapterFour:
            return .chapterFour
        case .chapterFive:
            return .chapterFive
        }
    }
}
