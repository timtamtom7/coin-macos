import SwiftUI

struct ScoreView: View {
    let score: Int
    let size: CGFloat

    private var progress: Double {
        Double(score) / 100.0
    }

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Theme.cardBackground, lineWidth: size * 0.06)

            // Progress arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Theme.scoreColor(for: score),
                    style: StrokeStyle(
                        lineWidth: size * 0.06,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progress)

            // Score text
            VStack(spacing: 2) {
                Text("\(score)")
                    .font(.system(size: size * 0.28, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textPrimary)

                Text(Theme.scoreLabel(for: score))
                    .font(.system(size: size * 0.09, weight: .medium))
                    .foregroundColor(Theme.scoreColor(for: score))
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 20) {
        ScoreView(score: 95, size: 120)
        ScoreView(score: 75, size: 120)
        ScoreView(score: 55, size: 120)
        ScoreView(score: 30, size: 120)
    }
    .padding()
    .background(Theme.background)
}
