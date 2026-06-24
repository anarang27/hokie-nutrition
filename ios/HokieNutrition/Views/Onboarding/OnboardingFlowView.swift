import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject var appState: AppState
    @State private var step = 0

    var body: some View {
        VStack(spacing: 20) {
            ProgressView(value: Double(step + 2) / 8.0)
                .tint(HokieColors.primary)
                .padding(.horizontal)

            TabView(selection: $step) {
                basicsStep.tag(0)
                bodyStep.tag(1)
                activityStep.tag(2)
                goalStep.tag(3)
                summaryStep.tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: step)
        }
        .padding(.top, 8)
        .navigationTitle("Hokie Nutrition")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var basicsStep: some View {
        stepContainer(title: "About you", subtitle: "A few basics to personalize your targets.") {
            DatePicker("Date of birth", selection: $appState.profile.dob, displayedComponents: .date)
            Picker("Sex (for BMR calculation)", selection: $appState.profile.sex) {
                ForEach(UserSex.allCases) { s in Text(s.rawValue.capitalized).tag(s) }
            }
            Picker("Class year (optional)", selection: Binding(
                get: { appState.profile.classYear ?? .freshman },
                set: { appState.profile.classYear = $0 }
            )) {
                ForEach(ClassYear.allCases) { y in Text(y.label).tag(y) }
            }
            nextButton { step = 1 }
        }
    }

    private var bodyStep: some View {
        stepContainer(title: "Body metrics", subtitle: "Used to calculate your daily calorie and macro targets.") {
            HStack {
                Text("Height")
                Spacer()
                let (ft, inch) = UnitConverter.cmToFeetInches(appState.profile.heightCm)
                Stepper("\(ft)' \(inch)\"", value: Binding(
                    get: { Int(appState.profile.heightCm) },
                    set: { appState.profile.heightCm = Double($0) }
                ), in: 140...220, step: 2)
            }
            HStack {
                Text("Weight")
                Spacer()
                Stepper(String(format: "%.0f lbs", UnitConverter.kgToLbs(appState.profile.weightKg)), value: Binding(
                    get: { Int(UnitConverter.kgToLbs(appState.profile.weightKg)) },
                    set: { appState.profile.weightKg = UnitConverter.lbsToKg(Double($0)) }
                ), in: 80...350, step: 1)
            }
            nextButton { step = 2 }
        }
    }

    private var activityStep: some View {
        stepContainer(title: "Activity", subtitle: "How often do you train?") {
            Stepper("Workouts per week: \(appState.profile.workoutsPerWeek)", value: $appState.profile.workoutsPerWeek, in: 0...14)
            Picker("Activity level", selection: $appState.profile.activityLevel) {
                ForEach(ActivityLevel.allCases) { level in
                    Text(level.label).tag(level)
                }
            }
            nextButton { step = 3 }
        }
    }

    private var goalStep: some View {
        stepContainer(title: "Your gym goal", subtitle: "We'll tailor recommendations to match.") {
            Picker("Goal", selection: $appState.profile.goal) {
                ForEach(GymGoal.allCases) { g in Text(g.label).tag(g) }
            }
            .pickerStyle(.wheel)
            .frame(height: 140)

            if appState.profile.goal == .cutting || appState.profile.goal == .bulking {
                Picker("Pace", selection: $appState.profile.pace) {
                    ForEach(GoalPace.allCases) { p in Text(p.label).tag(p) }
                }
                .pickerStyle(.segmented)
            }

            Picker("Dietary pattern", selection: $appState.profile.dietaryPattern) {
                ForEach(DietaryPattern.allCases) { d in Text(d.label).tag(d) }
            }

            nextButton { step = 4 }
        }
    }

    private var summaryStep: some View {
        let targets = NutritionCalculator.computeTargets(for: appState.profile)
        return stepContainer(title: "Your targets", subtitle: "You can adjust these later in Settings.") {
            targetRow("Calories", "\(targets.calories) kcal")
            targetRow("Protein", "\(targets.protein)g")
            targetRow("Carbs", "\(targets.carbs)g")
            targetRow("Fat", "\(targets.fat)g")

            Button("Continue") {
                appState.profile.targets = targets
                appState.completeOnboarding()
            }
            .buttonStyle(HokiePrimaryButtonStyle())
        }
    }

    private func stepContainer<Content: View>(title: String, subtitle: String, @ViewBuilder content: () -> Content) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(title).font(.system(size: 24, weight: .bold))
                Text(subtitle).foregroundStyle(HokieColors.onSurfaceVariant)
                content()
            }
            .padding(16)
        }
    }

    private func targetRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).fontWeight(.semibold).foregroundStyle(HokieColors.primary)
        }
        .padding()
        .background(HokieColors.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func nextButton(action: @escaping () -> Void) -> some View {
        Button("Next", action: action)
            .buttonStyle(HokiePrimaryButtonStyle())
            .padding(.top, 8)
    }
}
