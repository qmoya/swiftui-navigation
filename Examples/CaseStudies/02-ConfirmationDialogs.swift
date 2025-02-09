import SwiftUI
import SwiftUINavigation

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
struct OptionalConfirmationDialogs: View {
  @ObservedObject private var model = FeatureModel()

  var body: some View {
    List {
      Stepper("Number: \(self.model.count)", value: self.$model.count)
      Button(action: { self.model.numberFactButtonTapped() }) {
        HStack {
          Text("Get number fact")
          if self.model.isLoading {
            Spacer()
            ProgressView()
          }
        }
      }
      .disabled(self.model.isLoading)
    }
    .confirmationDialog(
      title: { Text("Fact about \($0.number)") },
      titleVisibility: .visible,
      unwrapping: self.$model.fact,
      actions: {
        Button("Get another fact about \($0.number)") {
          self.model.numberFactButtonTapped()
        }
      },
      message: { Text($0.description) }
    )
    .navigationTitle("Dialogs")
  }
}

private class FeatureModel: ObservableObject {
  @Published var count = 0
  @Published var isLoading = false
  @Published var fact: Fact?

  func numberFactButtonTapped() {
    Task { @MainActor in
      self.isLoading = true
      defer { self.isLoading = false }
      self.fact = await getNumberFact(self.count)
    }
  }
}
