import SwiftUI

// MARK: - Animation Extensions

extension Animation {
    static let taskComplete = Animation.spring(response: 0.4, dampingFraction: 0.7)
    static let taskDelete = Animation.spring(response: 0.3, dampingFraction: 0.8)
    static let cardAppear = Animation.spring(response: 0.5, dampingFraction: 0.8)
    static let quick = Animation.easeInOut(duration: 0.2)
}

// MARK: - View Modifiers

struct FadeInModifier: ViewModifier {
    let delay: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(0)
            .offset(y: 10)
            .animation(
                .spring(response: 0.5, dampingFraction: 0.8).delay(delay),
                value: true
            )
    }
}

extension View {
    func fadeIn(delay: Double = 0) -> some View {
        modifier(FadeInModifier(delay: delay))
    }
    
    func bounceOnAppear() -> some View {
        modifier(BounceOnAppearModifier())
    }
}

struct BounceOnAppearModifier: ViewModifier {
    @State private var scale: CGFloat = 0.8
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
    }
}

// MARK: - Custom Animations

struct StrikethroughAnimation: ViewModifier {
    let isStrikethrough: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay {
                Rectangle()
                    .fill(Color.secondary)
                    .frame(height: 1)
                    .frame(maxWidth: isStrikethrough ? .infinity : 0)
                    .animation(.easeInOut(duration: 0.3), value: isStrikethrough)
            }
    }
}

extension View {
    func strikethroughAnimated(_ isStrikethrough: Bool) -> some View {
        modifier(StrikethroughAnimation(isStrikethrough: isStrikethrough))
    }
}

// MARK: - Completion Animation

struct TaskCompleteAnimation: ViewModifier {
    @Binding var isCompleted: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isCompleted {
                    Circle()
                        .stroke(Color.green, lineWidth: 2)
                        .scaleEffect(1.5)
                        .opacity(0)
                        .animation(.easeOut(duration: 0.5), value: isCompleted)
                }
            }
    }
}

// MARK: - Shake Animation

struct ShakeAnimation: ViewModifier {
    @Binding var isShaking: Bool
    
    func body(content: Content) -> some View {
        content
            .offset(x: isShaking ? 5 : 0)
            .animation(
                isShaking ? 
                    Animation.default.repeatCount(4).speed(10) :
                    .default,
                value: isShaking
            )
            .onChange(of: isShaking) { _, newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        isShaking = false
                    }
                }
            }
    }
}

extension View {
    func shake(isShaking: Binding<Bool>) -> some View {
        modifier(ShakeAnimation(isShaking: isShaking))
    }
}
