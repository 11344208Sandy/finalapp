import SwiftUI

struct GameView: View {
    @Bindable var viewModel: GameViewModel
    @State private var isShowingData = false

    var body: some View {
        ZStack {
            Color.morandiPurpleBackground
                .ignoresSafeArea()

            content
                .padding(20)

            if viewModel.state == .resting {
                eyeBreakOverlay
            }

            if viewModel.state == .gameOver {
                gameOverOverlay
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if isShowingData {
            dataScreen
        } else if viewModel.state == .idle {
            homeScreen
        } else {
            gameScreen
        }
    }

    private var homeScreen: some View {
        VStack(spacing: 28) {
            Spacer()
            header
            homePanel
            Spacer()
        }
    }

    private var gameScreen: some View {
        VStack(spacing: 20) {
            header

            ScoreHeaderView(
                score: viewModel.score,
                highScore: viewModel.highScore,
                levelTitle: viewModel.currentLevelTitle,
                timeRemaining: viewModel.timeRemaining
            )

            ColorGridView(
                tiles: viewModel.tiles,
                sideCount: viewModel.gridSideCount,
                isEnabled: viewModel.state == .playing,
                onSelect: viewModel.selectTile
            )
            .frame(maxHeight: .infinity)
        }
    }

    private var dataScreen: some View {
        VStack(spacing: 16) {
            HStack {
                Button {
                    isShowingData = false
                } label: {
                    Label("返回", systemImage: "chevron.left")
                        .font(.headline.weight(.bold))
                }
                .buttonStyle(.bordered)
                .tint(.morandiSage)

                Spacer()
            }

            ScrollView {
                VStack(spacing: 18) {
                    header
                    GrowthDashboardView(viewModel: viewModel)
                }
            }
        }
    }

    private var eyeBreakOverlay: some View {
        ZStack {
            Color.black.opacity(0.18)
                .ignoresSafeArea()

            VStack(spacing: 10) {
                Text("眼保健操👁️👁️")
                    .font(.title.weight(.heavy))
                    .foregroundStyle(.primary)
                Text("\(viewModel.restRemaining) 秒後繼續")
                    .font(.headline.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            .padding(24)
            .frame(maxWidth: 300)
            .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(.white.opacity(0.9), lineWidth: 1)
            )
        }
    }

    private var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(0.22)
                .ignoresSafeArea()

            GameOverView(
                finalScoreText: viewModel.finalScoreText,
                onRestart: {
                    isShowingData = false
                    viewModel.startGame()
                },
                onHome: {
                    isShowingData = false
                    viewModel.returnToHome()
                }
            )
            .frame(maxWidth: 320)
            .padding(20)
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("火👀驚睛大挑戰")
                .font(.largeTitle.weight(.heavy))
                .foregroundStyle(.primary)
            Text("找出唯一不同的莫蘭迪色塊")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }

    private var homePanel: some View {
        VStack(spacing: 16) {
            DifferenceIcon()
                .frame(width: 74, height: 74)

            Picker("冒險章節", selection: $viewModel.selectedDifficulty) {
                ForEach(GameDifficulty.allCases) { difficulty in
                    Text(difficulty.title)
                        .tag(difficulty)
                }
            }
            .pickerStyle(.menu)
            .tint(.morandiBlue)
            .frame(maxWidth: .infinity, alignment: .center)
            .accessibilityLabel("冒險章節")

            Button {
                isShowingData = false
                viewModel.startGame()
            } label: {
                Label("開始遊戲", systemImage: "play.fill")
                    .font(.headline.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.morandiSage)

            Button {
                isShowingData = true
            } label: {
                Label("查看數據", systemImage: "chart.xyaxis.line")
                    .font(.headline.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.bordered)
            .tint(.morandiBlue)
        }
        .padding(22)
        .frame(maxWidth: 320)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.8), lineWidth: 1)
        )
    }
}

private struct DifferenceIcon: View {
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size.width
            let dotSize = size * 0.22

            ZStack {
                Circle()
                    .fill(Color.morandiSage.opacity(0.22))
                    .frame(width: size, height: size)

                Circle()
                    .fill(Color.morandiSage)
                    .frame(width: dotSize, height: dotSize)
                    .offset(x: -size * 0.18, y: size * 0.04)

                Circle()
                    .fill(Color.morandiSage)
                    .frame(width: dotSize, height: dotSize)
                    .offset(x: size * 0.12, y: size * 0.04)

                Circle()
                    .fill(Color.morandiCoral)
                    .frame(width: dotSize * 0.82, height: dotSize * 0.82)
                    .overlay(
                        Circle()
                            .stroke(Color.morandiCoral.opacity(0.5), lineWidth: 3)
                            .frame(width: dotSize * 1.25, height: dotSize * 1.25)
                    )
                    .offset(x: size * 0.24, y: -size * 0.20)
            }
            .frame(width: size, height: size)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}

extension Color {
    static let morandiPurpleBackground = Color(red: 0.92, green: 0.89, blue: 0.96)
    static let morandiCream = Color(red: 0.98, green: 0.91, blue: 0.62)
    static let morandiPeach = Color(red: 0.96, green: 0.70, blue: 0.58)
    static let morandiMint = Color(red: 0.62, green: 0.84, blue: 0.67)
    static let morandiSky = Color(red: 0.55, green: 0.76, blue: 0.91)
    static let morandiLavender = Color(red: 0.76, green: 0.65, blue: 0.90)
    static let morandiRose = Color(red: 0.90, green: 0.55, blue: 0.66)
    static let morandiSage = Color(red: 0.45, green: 0.72, blue: 0.55)
    static let morandiBlue = Color(red: 0.42, green: 0.65, blue: 0.88)
    static let morandiCoral = Color(red: 0.92, green: 0.50, blue: 0.42)
}
