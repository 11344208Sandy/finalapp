import SwiftUI

struct ColorGridView: View {
    let tiles: [ColorTile]
    let sideCount: Int
    let isEnabled: Bool
    let onSelect: (ColorTile) -> Void

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: tileSpacing), count: sideCount)
    }

    private var tileSpacing: CGFloat {
        sideCount >= 8 ? 5 : 8
    }

    var body: some View {
        GeometryReader { proxy in
            let boardSize = min(proxy.size.width, proxy.size.height)

            LazyVGrid(columns: columns, spacing: tileSpacing) {
                ForEach(tiles) { tile in
                    Button {
                        onSelect(tile)
                    } label: {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(tile.color)
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                    .stroke(.white.opacity(0.45), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                    .disabled(!isEnabled)
                    .aspectRatio(1, contentMode: .fit)
                    .accessibilityLabel(tile.isDifferent ? "不同色塊" : "一般色塊")
                }
            }
            .frame(width: boardSize, height: boardSize)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var cornerRadius: CGFloat {
        sideCount >= 8 ? 8 : 14
    }
}
