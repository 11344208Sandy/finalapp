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
            return "第一章・新手村試煉"
        case .chapterTwo:
            return "第二章・迷霧森林"
        case .chapterThree:
            return "第三章・彩石古塔"
        case .chapterFour:
            return "第四章・星火王城"
        case .chapterFive:
            return "第五章・終焉王座"
        }
    }

    var shortTitle: String {
        switch self {
        case .chapterOne:
            return "第一章"
        case .chapterTwo:
            return "第二章"
        case .chapterThree:
            return "第三章"
        case .chapterFour:
            return "第四章"
        case .chapterFive:
            return "第五章"
        }
    }

    var analyticsTitle: String {
        "\(shortTitle)表現"
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
