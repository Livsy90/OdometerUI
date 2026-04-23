# OdometerUI

`OdometerUI` provides a SwiftUI view called `OdometerNumberView` that animates integer changes in an odometer-style sequence.

Instead of jumping directly from one number to another, it renders intermediate values step by step (for example, `1 -> 2 -> 3 -> 4`).

[Demo](https://www.youtube.com/watch?v=19YJQK6JzXY)


## Features

- Odometer-style incremental/decremental animation
- Smooth numeric text transition with `contentTransition(.numericText(...))`
- Automatic cancellation of in-flight animation when a new value arrives
- Configurable timing with per-step and max-total duration controls

## Component

### `OdometerNumberView`

```swift
public init(
    value: Int,
    stepDuration: Double = 0.1,
    maxAnimationDuration: Double = 0.9
)
```

#### Parameters

- `value`: Target integer value to display.
- `stepDuration`: Preferred duration between consecutive intermediate values.
- `maxAnimationDuration`: Upper bound for total animation time. The view automatically reduces effective step duration for large jumps so the animation does not exceed this limit.

## Usage

```swift
import SwiftUI
import OdometerUI

struct ContentView: View {
    @State private var value = 42

    var body: some View {
        VStack(spacing: 16) {
            OdometerNumberView(value: value)
                .font(.system(size: 64, weight: .bold, design: .rounded))

            HStack {
                Button("-10") { value -= 10 }
                Button("+1") { value += 1 }
                Button("+10") { value += 10 }
            }
        }
        .padding()
    }
}
```

## How It Works

When `value` changes:

1. Any previous animation task is cancelled.
2. The component computes direction (`+1` or `-1`) and distance.
3. It calculates an effective step duration:
   - `min(stepDuration, maxAnimationDuration / distance)`
4. It advances `displayedValue` one step at a time until the target is reached.

This keeps the animation readable for small changes and bounded for large jumps.

## Preview

A SwiftUI preview is included in `Sources/OdometerUI/OdometerUI.swift` with controls to compare odometer-style stepping against native `numericText` transition.

## Requirements

- SwiftUI
- A platform/runtime that supports `contentTransition(.numericText(...))`
