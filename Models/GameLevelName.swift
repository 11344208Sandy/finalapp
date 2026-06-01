import Foundation

enum GameLevelName {
    private static let titles = [
        "新手村",
        "青草平原",
        "霧色森林",
        "彩石洞窟",
        "晨曦港口",
        "月影古塔",
        "珊瑚迷宮",
        "浮空花園",
        "星塵城門",
        "終焉王座"
    ]

    static func title(for level: Int) -> String {
        guard level > 0 else { return "新手村" }

        if level <= titles.count {
            return titles[level - 1]
        }

        return "輪迴試煉 \(level - titles.count)"
    }

    static func fullTitle(for level: Int) -> String {
        title(for: level)
    }
}
