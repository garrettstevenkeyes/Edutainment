//
//  ContentView.swift
//  Edutainment
//
//  Created by Garrett Keyes on 11/18/25.
//

import SwiftUI

enum Game {
    enum Difficulty: String, CaseIterable, Identifiable {
        case easy, medium, hard
        var id: String { rawValue }
    }
}

struct ContentView: View {
    @State private var numerator = 0
    @State private var denominator = 0
    @State private var minValue: Double = 1
    @State private var maxValue: Double = 12
    @State private var answerText: String = ""
    @State private var selectedDifficulty: Game.Difficulty = .easy
    @State private var score: Int = 0
    @State private var problems: [(Int, Int)] = []
    @State private var currentIndex: Int = 0

    @State private var showResultAlert: Bool = false
    @State private var lastAnswerWasCorrect: Bool = false
    @State private var showFinalAlert: Bool = false

    private func startGame() {
        // Determine number of problems by difficulty
        let count: Int
        switch selectedDifficulty {
            case .easy:   count = 3
            case .medium: count = 5
            case .hard:   count = 7
        }

        // Build range from sliders
        let lower = Int(minValue)
        let upper = Int(maxValue)
        let range = lower...upper

        // Generate problems: two random numbers within the range
        var generated: [(Int, Int)] = []
        generated.reserveCapacity(count)
        for _ in 0..<count {
            let a = Int.random(in: range)
            let b = Int.random(in: range)
            generated.append((a, b))
        }

        // Reset state for a new game
        score = 0
        answerText = ""
        currentIndex = 0
        problems = generated

        // Show first problem
        if let first = problems.first {
            numerator = first.0
            denominator = first.1
        }
    }
    
    private func checkAnswerAndAdvance() {
        // Parse user's answer
        let userAnswer = Int(answerText) ?? Int.min
        let correctAnswer = numerator * denominator
        let isCorrect = userAnswer == correctAnswer
        lastAnswerWasCorrect = isCorrect
        if isCorrect { score += 1 }

        // Show per-question result alert
        showResultAlert = true
    }

    private func loadNextProblem() {
        // Clear the input for the next question
        answerText = ""

        // Move to next index
        currentIndex += 1
        if currentIndex < problems.count {
            let next = problems[currentIndex]
            numerator = next.0
            denominator = next.1
        } else {
            // No more problems: show final score
            showFinalAlert = true
        }
    }
    
    var body: some View {
        VStack {
            HeaderView()
            RangeSelector(minValue: $minValue, maxValue: $maxValue, bounds: 1...12)
            DifficultySelector(selectedDifficulty: $selectedDifficulty)
            StartButton(action: startGame)
            
            Spacer(minLength: 16)
            NumberView(numerator: numerator, denominator: denominator)
            RainbowDivider()

            // Answer input
            HStack {
                Spacer()
                TextField("Type your answer", text: $answerText.digitsOnly())
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.numberPad)
                    .submitLabel(.done)
                    .onSubmit {
                        checkAnswerAndAdvance()
                    }
                    .numberStyle()
                Button("Check") {
                    checkAnswerAndAdvance()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                Spacer()
            }
            .padding(.top, 8)

            Spacer()
        }
        .backgroundStyle()
        .alert(isPresented: $showResultAlert) {
            Alert(
                title: Text(lastAnswerWasCorrect ? "Correct!" : "Wrong"),
                message: Text(lastAnswerWasCorrect ? "Nice job!" : "The answer was \(numerator * denominator)."),
                dismissButton: .default(Text("Next")) {
                    loadNextProblem()
                }
            )
        }
        .alert("Game Over", isPresented: $showFinalAlert) {
            Button("OK", role: .cancel) {
                // Optionally reset state or leave results visible
            }
        } message: {
            Text("You scored \(score) out of \(problems.count).")
        }
    }
    
    
}

// MARK: - Background construction
struct BackgroundStyle: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            // Richer beige-forward background
            RadialGradient(stops: [
                .init(color: Color(red: 0.82, green: 0.75, blue: 0.66), location: 0.0),   // deeper beige center
                .init(color: Color(red: 0.74, green: 0.66, blue: 0.56), location: 0.45),  // tan
                .init(color: Color(red: 0.58, green: 0.49, blue: 0.40), location: 0.85),  // warm brown
                .init(color: Color(red: 0.40, green: 0.34, blue: 0.28), location: 1.0)    // dark cocoa edge
            ], center: .top, startRadius: 120, endRadius: 900)
            .ignoresSafeArea()

            // Playful color blobs overlay
            ZStack {
                Circle()
                    .fill(Color(red: 1.00, green: 0.48, blue: 0.28).opacity(0.18)) // coral
                    .frame(width: 260, height: 260)
                    .offset(x: -140, y: -80)
                    .blur(radius: 20)

                Circle()
                    .fill(Color(red: 0.26, green: 0.62, blue: 0.92).opacity(0.16)) // sky blue
                    .frame(width: 220, height: 220)
                    .offset(x: 120, y: -20)
                    .blur(radius: 20)

                Circle()
                    .fill(Color(red: 0.36, green: 0.76, blue: 0.44).opacity(0.14)) // mint
                    .frame(width: 280, height: 280)
                    .offset(x: 60, y: 220)
                    .blur(radius: 25)
            }
            .ignoresSafeArea()

            content
        }
    }
}

extension View {
    func backgroundStyle() -> some View {
        self.modifier(BackgroundStyle())
    }
}

// MARK: - Title construction
struct TitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 40, weight: .black, design: .rounded))
            .foregroundStyle(.blue)
    }
}

extension View {
    func titleStyle() -> some View {
        self.modifier(TitleStyle())
    }
}

struct HeaderView: View {
    private let title = "xFun With Math x"
    private let palette: [Color] = [
        .red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue, .indigo, .purple, .pink
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(title.enumerated()), id: \.0) { index, ch in
                let color = palette[index % palette.count]
                Text(String(ch))
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(color)
            }
        }
        .padding(.top, 24)
        .padding(.horizontal, 20)
    }
}

struct RangeSelector: View {
    @Binding var minValue: Double
    @Binding var maxValue: Double
    let bounds: ClosedRange<Double>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Practice range:")
                    .font(.headline)
                Spacer()
                Text("\(Int(minValue)) – \(Int(maxValue))")
                    .font(.headline)
                    .monospacedDigit()
            }
            .padding(.horizontal, 20)

            // Min slider
            HStack {
                Text("Min")
                    .font(.subheadline)
                    .frame(width: 44, alignment: .leading)
                Slider(value: Binding(
                    get: { minValue },
                    set: { newValue in
                        minValue = min(newValue, maxValue) // clamp to not exceed max
                    }
                ), in: bounds)
            }
            .padding(.horizontal, 20)

            // Max slider
            HStack {
                Text("Max")
                    .font(.subheadline)
                    .frame(width: 44, alignment: .leading)
                Slider(value: Binding(
                    get: { maxValue },
                    set: { newValue in
                        maxValue = max(newValue, minValue) // clamp to not go below min
                    }
                ), in: bounds)
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 8)
    }
}

struct DifficultySelector: View {
    @Binding var selectedDifficulty: Game.Difficulty
    
        var body: some View {
            // Difficulty selection
            Picker("Difficulty", selection: $selectedDifficulty) {
                Text("Easy").tag(Game.Difficulty.easy)
                Text("Medium").tag(Game.Difficulty.medium)
                Text("Hard").tag(Game.Difficulty.hard)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.top, 8)
    }
}

struct StartButton: View {
    let action: @MainActor () -> Void

    var body: some View {
        Button(action: action) {
            Text("Start")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.green)
                        .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
                )
        }
        .padding(.top, 8)
    }
}


// MARK: - Body construction
struct NumberStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 64, weight: .heavy, design: .rounded))
            .foregroundStyle(
                LinearGradient(colors: [
                    Color(red: 1.00, green: 0.72, blue: 0.30), // amber
                    Color(red: 0.99, green: 0.45, blue: 0.52), // watermelon
                    Color(red: 0.54, green: 0.76, blue: 1.00)  // sky
                ], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.05)
                        ], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .overlay(
                        Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 6)
            )
            .padding(4)
    }
}

extension View {
    func numberStyle() -> some View {
        self.modifier(NumberStyle())
    }
}

extension Binding where Value == String {
    func digitsOnly() -> Binding<String> {
        Binding<String>(
            get: { self.wrappedValue },
            set: { newValue in
                let filtered = newValue.filter { $0.isNumber }
                self.wrappedValue = filtered
            }
        )
    }
}

struct NumberView: View {
    let numerator: Int
    let denominator: Int

    var body: some View {
        // Compute ordering so layout is consistent
        let top = max(numerator, denominator)
        let bottom = min(numerator, denominator)

        VStack(spacing: 8) {
            // First line: top number, right-aligned
            HStack {
                Spacer(minLength: 0)
                Text("\(top)").numberStyle()
            }
            // Second line: multiplication symbol and bottom number on the same line, right-aligned together
            HStack(spacing: 8) {
                Spacer(minLength: 0)
                Text("×")
                    .font(.system(size: 64, weight: .heavy, design: .rounded))
                    .foregroundStyle(.primary)
                Text("\(bottom)").numberStyle()
            }
        }
        .font(.title2)
        .padding()
    }
}

struct AnswerView: View {
    let text: String
    let correct: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            if correct {
                Text("Correct!")
                    .foregroundColor(.green)
            } else {
                Text("Wrong. The correct answer was:")
                    .foregroundColor(.red)
                Text(text)
            }
        }
    }
}

struct RainbowDivider: View {
    private let colors: [Color] = [
        .red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue, .indigo, .purple, .pink
    ]

    var body: some View {
        LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
            .frame(height: 6)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
            .padding(.horizontal, 20)
            .padding(.top, 8)
    }
}


#Preview {
    ContentView()
}

