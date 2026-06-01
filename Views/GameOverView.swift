import SwiftUI

struct GameOverView: View {
    let finalScoreText: String
    let onRestart: () -> Void
    let onHome: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Text("遊戲結束")
                .font(.title2.weight(.heavy))
            Text(finalScoreText)
                .font(.headline)
                .foregroundStyle(.secondary)

            VStack(spacing: 10) {
                Button(action: onRestart) {
                    Label("重新開始", systemImage: "arrow.clockwise")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(.morandiCoral)

                Button(action: onHome) {
                    Label("回到主畫面", systemImage: "house.fill")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
                .tint(.morandiSage)
            }
        }
        .padding(18)
        .background(.white.opacity(0.74), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.8), lineWidth: 1)
        )
    }
}
