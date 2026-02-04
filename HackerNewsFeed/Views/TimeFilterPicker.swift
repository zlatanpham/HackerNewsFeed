import SwiftUI

struct TimeFilterPicker: View {
    @Binding var selection: TimeFilter

    var body: some View {
        Picker("Time Filter", selection: $selection) {
            ForEach(TimeFilter.allCases) { filter in
                Text(filter.title).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }
}

#Preview {
    TimeFilterPicker(selection: .constant(.all))
        .padding()
}
