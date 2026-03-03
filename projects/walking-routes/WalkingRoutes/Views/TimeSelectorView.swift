import SwiftUI

struct TimeSelectorView: View {
    @Binding var selectedTime: Int

    private var sliderValue: Binding<Double> {
        Binding(
            get: { Double(selectedTime) },
            set: { selectedTime = Int($0) }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How much time do you have?")
                .font(.headline)

            HStack {
                Text("\(selectedTime) min")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)

                Spacer()

                HStack(spacing: 8) {
                    StepperButton(icon: "minus") {
                        selectedTime = max(5, selectedTime - 5)
                    }

                    StepperButton(icon: "plus") {
                        selectedTime = min(180, selectedTime + 5)
                    }
                }
            }

            Slider(value: sliderValue, in: 5...180, step: 5)
                .tint(AppTheme.primaryColor)

            HStack {
                Text("5 min")
                Spacer()
                Text("180 min")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}

private struct StepperButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .frame(width: 30, height: 30)
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

struct TimeSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        TimeSelectorView(selectedTime: .constant(60))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
