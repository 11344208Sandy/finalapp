import Foundation

enum GameDifficulty: String, CaseIterable, Identifiable, Codable {
    case chapterOne
    case chapterTwo
    case chapterThree
    case chapterFour
    case chapterFive

    var id: Self { self }

    var title: String {
        switch self {
        case .chapterOne:
            return "觀察入門"
        case .chapterTwo:
            return "穩定挑戰"
        case .chapterThree:
            return "敏銳試煉"
        case .chapterFour:
            return "極限辨色"
        case .chapterFive:
            return "大師模式"
        }
    }

    var shortTitle: String {
        title
    }

    var analyticsTitle: String {
        "\(title)表現"
    }

    var colorDifferenceScale: Double {
        switch self {
        case .chapterOne:
            return 1.35
        case .chapterTwo:
            return 1.18
        case .chapterThree:
            return 1.04
        case .chapterFour:
            return 0.92
        case .chapterFive:
            return 0.82
        }
    }
}
