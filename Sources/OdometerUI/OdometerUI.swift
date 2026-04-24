import SwiftUI

public struct OdometerNumberView: View {
    private let value: Int
    private let stepDuration: Double
    private let maxAnimationDuration: Double

    @State private var displayedValue: Int
    @State private var animationTask: Task<Void, Never>?

    public init(
        value: Int,
        stepDuration: Double = 0.1,
        maxAnimationDuration: Double = 0.9
    ) {
        self.value = value
        self.stepDuration = stepDuration
        self.maxAnimationDuration = maxAnimationDuration
        displayedValue = value
    }

    public var body: some View {
        Text(displayedValue.description)
            .contentTransition(.numericText(value: Double(displayedValue)))
            .animation(.easeInOut(duration: stepDuration), value: displayedValue)
            .onChange(of: value) { _, newValue in
                animateToValue(newValue)
            }
            .onDisappear {
                animationTask?.cancel()
            }
    }

    @MainActor
    private func animateToValue(_ newValue: Int) {
        animationTask?.cancel()

        let startValue = displayedValue
        guard startValue != newValue else { return }

        let distance = abs(newValue - startValue)
        let effectiveStepDuration = min(
            stepDuration,
            maxAnimationDuration / Double(distance)
        )

        animationTask = Task {
            let step = newValue > startValue ? 1 : -1
            var current = startValue

            while current != newValue {
                do {
                    try await Task.sleep(for: .seconds(effectiveStepDuration))
                } catch {
                    break
                }

                current += step
                displayedValue = current
            }
        }
    }
}

#Preview {
    struct NumericView: View {
        @State private var value = 1

        var body: some View {
            VStack(spacing: 24) {
                // Odometer-style animation: intermediate values are rendered step by step.
                OdometerNumberView(value: value)
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                
                // Native numericText transition for side-by-side comparison.
                Text(value.description)
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                    .animation(.default, value: value)
                
                controls
            }
            .padding()
        }
        
        private var controls: some View {
            HStack(spacing: 12) {
                Button("-3") {
                    value -= 3
                }
                .buttonStyle(.bordered)

                Button("+1") {
                    value += 1
                }
                .buttonStyle(.borderedProminent)

                Button("+3") {
                    value += 3
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    return NumericView()
}
