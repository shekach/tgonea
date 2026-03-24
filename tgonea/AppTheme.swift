import SwiftUI

enum AppTheme {
    static let accent = Color(red: 0.49, green: 0.14, blue: 0.18)
    static let accentDeep = Color(red: 0.29, green: 0.08, blue: 0.11)
    static let gold = Color(red: 0.88, green: 0.67, blue: 0.27)
    static let sky = Color(red: 0.31, green: 0.57, blue: 0.75)
    static let mint = Color(red: 0.38, green: 0.67, blue: 0.61)
    static let ink = Color(red: 0.15, green: 0.18, blue: 0.22)
    static let softText = Color(red: 0.37, green: 0.41, blue: 0.47)
    static let canvas = Color(red: 0.96, green: 0.94, blue: 0.90)
    static let cardFill = Color.white.opacity(0.72)
    static let glassFill = Color.white.opacity(0.28)
    static let border = Color.white.opacity(0.55)
    static let shadow = Color.black.opacity(0.12)

    static let pageGradient = LinearGradient(
        colors: [
            Color(red: 0.95, green: 0.90, blue: 0.83),
            Color(red: 0.94, green: 0.95, blue: 0.97),
            Color(red: 0.89, green: 0.94, blue: 0.92)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let heroGradient = LinearGradient(
        colors: [
            accent,
            accentDeep,
            Color(red: 0.18, green: 0.28, blue: 0.34)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct AppScreenBackground: View {
    var body: some View {
        ZStack {
            AppTheme.pageGradient
                .ignoresSafeArea()

            Circle()
                .fill(AppTheme.gold.opacity(0.20))
                .frame(width: 320, height: 320)
                .blur(radius: 30)
                .offset(x: 150, y: -260)

            Circle()
                .fill(AppTheme.sky.opacity(0.18))
                .frame(width: 280, height: 280)
                .blur(radius: 28)
                .offset(x: -160, y: -120)

            Circle()
                .fill(AppTheme.mint.opacity(0.18))
                .frame(width: 260, height: 260)
                .blur(radius: 36)
                .offset(x: -120, y: 260)
        }
    }
}

struct AppSectionHeader: View {
    let eyebrow: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(eyebrow.uppercased())
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(AppTheme.accent)

            Text(title)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(AppTheme.ink)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(AppTheme.softText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AppChip: View {
    let icon: String
    let title: String
    var isActive: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(title)
                .lineLimit(1)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(isActive ? Color.white : AppTheme.ink)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(isActive ? AppTheme.heroGradient : LinearGradient(colors: [Color.white.opacity(0.72), Color.white.opacity(0.48)], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .overlay(
            Capsule()
                .stroke(isActive ? Color.white.opacity(0.18) : AppTheme.border, lineWidth: 1)
        )
        .shadow(color: AppTheme.shadow.opacity(isActive ? 1 : 0.45), radius: 12, y: 6)
    }
}

struct AppPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppTheme.heroGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: AppTheme.accent.opacity(0.28), radius: 14, y: 10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

private struct AppCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(AppTheme.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .shadow(color: AppTheme.shadow, radius: 18, y: 10)
    }
}

private struct AppGlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(AppTheme.glassFill)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .shadow(color: AppTheme.shadow.opacity(0.9), radius: 18, y: 10)
    }
}

private struct AppFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.86))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.78), lineWidth: 1)
            )
            .shadow(color: AppTheme.shadow.opacity(0.35), radius: 10, y: 6)
    }
}

private struct StagedAppearModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 18)
            .scaleEffect(isVisible ? 1 : 0.98)
            .animation(.spring(response: 0.65, dampingFraction: 0.84).delay(delay), value: isVisible)
            .onAppear {
                isVisible = true
            }
    }
}

extension View {
    func appCardStyle() -> some View {
        modifier(AppCardModifier())
    }

    func appGlassCardStyle() -> some View {
        modifier(AppGlassCardModifier())
    }

    func stagedAppear(_ delay: Double = 0) -> some View {
        modifier(StagedAppearModifier(delay: delay))
    }

    func appFieldStyle() -> some View {
        modifier(AppFieldModifier())
    }
}
