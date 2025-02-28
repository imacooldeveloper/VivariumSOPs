//
//  HusbandryQuestionView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/28/24.
//

import SwiftUI

import FirebaseAuth
import FirebaseFirestore
//struct HusbandryQuestionView: View {
//    @StateObject var vm: HusbandryQuestionViewModel
//    var quizId: String
//    var onFinish: () -> Void
//    
//    init(quizId: String, onFinish: @escaping () -> Void) {
//        self.quizId = quizId
//        self.onFinish = onFinish
//        self._vm = StateObject(wrappedValue: HusbandryQuestionViewModel())
//    }
//    
//    @Environment(\.dismiss) private var dismiss
//    @State private var currentIndex: Int = 0
//    @State private var showScoreCard: Bool = false
//    @State private var answerSelected = false
//
//    private var progress: CGFloat {
//        guard !vm.questions.isEmpty else { return 0 }
//        return CGFloat(currentIndex + 1) / CGFloat(vm.questions.count)
//    }
//    
//    var body: some View {
//        VStack {
//            // Header
//            HStack {
//                Button(action: dismiss.callAsFunction) {
//                    Image(systemName: "xmark")
//                        .font(.title3)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.white)
//                }
//                Spacer()
//                Text(vm.quizInfo?.title ?? "Quiz")
//                    .font(.title)
//                    .fontWeight(.semibold)
//                Spacer()
//            }
//            .padding()
//            
//            // Progress bar
//            GeometryReader { geometry in
//                ZStack(alignment: .leading) {
//                    Rectangle().fill(Color.gray.opacity(0.2))
//                    Rectangle().fill(Color.blue).frame(width: progress * geometry.size.width)
//                }
//                .clipShape(Capsule())
//            }
//            .frame(height: 20)
//            .padding(.horizontal)
//            
//            // Question content
//            if currentIndex < vm.questions.count {
//                questionContent(vm.questions[currentIndex])
//            }
//            
//            Spacer()
//        }
//        .onAppear {
//            Task {
//                await vm.fetchQuizInfoAndQuestions(quizId: quizId)
//            }
//        }
//        .fullScreenCover(isPresented: $showScoreCard) {
//            ScoreCardView(score: vm.finalScore, onDismiss: onFinish, onRedo: restartQuiz)
//        }
//        .padding()
//        .background(Color("Background"))
//        .edgesIgnoringSafeArea(.all)
//    }
//
//    @ViewBuilder
//    private func questionContent(_ question: Question) -> some View {
//        VStack(alignment: .leading, spacing: 20) {
//            Text("Question \(currentIndex + 1) of \(vm.questions.count)")
//                .font(.headline)
//            
//            Text(question.questionText)
//                .font(.title2)
//                .fontWeight(.semibold)
//            
//            ForEach(question.options.indices, id: \.self) { index in
//                Button(action: {
//                    selectAnswer(question.options[index])
//                }) {
//                    OptionView(
//                        option: question.options[index],
//                        isSelected: vm.userAnswers[currentIndex] == question.options[index]
//                    )
//                }
//            }
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(10)
//        .shadow(radius: 5)
//    }
//    
//    private func selectAnswer(_ answer: String) {
//        withAnimation(.easeInOut) {
//            vm.userAnswers[currentIndex] = answer
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                if currentIndex < vm.questions.count - 1 {
//                    currentIndex += 1
//                } else {
//                    finishQuiz()
//                }
//            }
//        }
//    }
//    
//    private func finishQuiz() {
//        Task {
//            await vm.finalizeQuizAndRecordScore(forQuiz: quizId)
//            showScoreCard = true
//        }
//    }
//    
//    private func restartQuiz() {
//        currentIndex = 0
//        vm.userAnswers = Array(repeating: "", count: vm.questions.count)
//        showScoreCard = false
//        Task {
//            await vm.fetchQuizInfoAndQuestions(quizId: quizId)
//        }
//    }
//}

//struct HusbandryQuestionView: View {
//    @StateObject var vm = HusbandryQuestionViewModel()
//      var quizId: String
//      var quizTitle: String
//      var onFinish: () -> Void
//      
//      @State private var currentIndex: Int = 0
//      @State private var showScoreCard: Bool = false
//
//      var body: some View {
//          VStack {
//              if vm.isLoading {
//                  ProgressView("Loading quiz...")
//              } else if vm.questions.isEmpty {
//                  Text("No questions available")
//              } else {
//                  // Quiz content
//                  Text(quizTitle)
//                      .font(.headline)
//                      .padding()
//                  
//                  if currentIndex < vm.questions.count {
//                      QuestionView(
//                          question: vm.questions[currentIndex],
//                          onAnswer: { answer in
//                              if currentIndex < vm.userAnswers.count {
//                                  vm.userAnswers[currentIndex] = answer
//                              } else {
//                                  vm.userAnswers.append(answer)
//                              }
//                              moveToNextQuestion()
//                          }
//                      )
//                  } else {
//                      Button("Finish Quiz") {
//                          finishQuiz()
//                      }
//                  }
//              }
//          }
//          .onAppear {
//              Task {
//                  await vm.fetchQuizInfoAndQuestions(quizId: quizId)
//              }
//          }
//          .sheet(isPresented: $showScoreCard) {
//              ScoreCardView(
//                  score: vm.finalScore,
//                  onDismiss: onFinish,
//                  onRedo: redoQuiz
//              )
//          }
//      }
//      
//      private func moveToNextQuestion() {
//          if currentIndex < vm.questions.count - 1 {
//              currentIndex += 1
//          } else {
//              finishQuiz()
//          }
//      }
//      
//      private func finishQuiz() {
//          vm.calculateFinalScore()
//          Task {
//              await vm.finalizeQuizAndRecordScore(forQuiz: quizId)
//              showScoreCard = true
//          }
//      }
//      
//      private func redoQuiz() {
//          currentIndex = 0
//          vm.userAnswers.removeAll()
//          showScoreCard = false
//          Task {
//              await vm.fetchQuizInfoAndQuestions(quizId: quizId)
//          }
//      }
//    private func selectAnswer(_ answer: String) {
//        vm.userAnswers.append(answer)
//        if currentIndex < vm.questions.count - 1 {
//            currentIndex += 1
//        } else {
//            finishQuiz()
//        }
//    }
//    
////    private func finishQuiz() {
////        Task {
////            await vm.finalizeQuizAndRecordScore(forQuiz: quizId)
////            showScoreCard = true
////        }
////    }
//    
//    private func restartQuiz() {
//        currentIndex = 0
//        vm.userAnswers = []
//        showScoreCard = false
//        Task {
//            await vm.fetchQuizInfoAndQuestions(quizId: quizId)
//        }
//    }
//}
//
//struct QuestionView: View {
//    let question: Question
//    let onAnswer: (String) -> Void
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 20) {
//            Text(question.questionText)
//                .font(.title2)
//            
//            ForEach(question.options, id: \.self) { option in
//                Button(action: {
//                    onAnswer(option)
//                }) {
//                    Text(option)
//                        .padding()
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .background(Color.blue.opacity(0.1))
//                        .cornerRadius(8)
//                }
//            }
//        }
//        .padding()
//    }
//}
//struct OptionView: View {
//    let option: String
//    let isSelected: Bool
//    
//    var body: some View {
//        Text(option)
//            .foregroundColor(isSelected ? .white : .primary)
//            .padding()
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
//            .cornerRadius(10)
//    }
//}
struct HusbandryQuestionView: View {
    @StateObject var vm = HusbandryQuestionViewModel()
    var quizId: String
    var quizTitle: String
    var onFinish: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int = 0
    @State private var showScoreCard: Bool = false
    @State private var answerSelected = false
    @State private var showCorrectAnswer = false

    private var progress: CGFloat {
        guard !vm.questions.isEmpty else { return 0 }
        return CGFloat(currentIndex + 1) / CGFloat(vm.questions.count)
    }
  
    var body: some View {
        Group {
            if vm.questions.isEmpty  {
                QuizAcknowledgmentView(quiz:Quiz(
                    id: quizId,
                    info: Info(
                        title: "Vivarium Safety Protocol",
                        description: "This quiz tests your knowledge on vivarium safety protocols.",
                        peopleAttended: 50,
                        rules: ["Answer all questions correctly to pass", "Review the SOP before starting the quiz"]
                    ),
                    quizCategory: "Vivarium Safety",
                    quizCategoryID: "safety123",
                    accountTypes: ["admin", "staff"],
                    dateCreated: Date(),
                    dueDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()),
                    renewalFrequency: .yearly,
                    nextRenewalDates: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
                    customRenewalDate: nil,
                    organizationId: "org1",
                    verificationType: .quiz,
                    acknowledgmentText: "Please acknowledge that you have read the safety SOP before starting.",
                    questions: [
                        Question(
                            id: "q1",
                            questionText: "What is the first thing you should do when entering a vivarium?",
                            options: ["Wash hands", "Check animal records", "Wear protective gear"],
                            answer: "Wear protective gear"
                        ),
                        Question(
                            id: "q2",
                            questionText: "How often should safety equipment be inspected?",
                            options: ["Once a year", "Once every 6 months", "Once a month"],
                            answer: "Once every 6 months"
                        ),
                        Question(
                            id: "q3",
                            questionText: "Which of the following is a biohazard risk in a vivarium?",
                            options: ["Excessive noise", "Animal waste", "Poor lighting"],
                            answer: "Animal waste"
                        )
                    ],
                    acknowledgmentMetadata: Quiz.AcknowledgmentMetadata(
                        requiredReadingTime: 600, // 10 minutes
                        acknowledgmentStatement: "I have read and understood the vivarium safety SOP.",
                        additionalNotes: "Make sure to wear gloves when handling animals.",
                        requireSignature: true
                    )
                )) {
                    
                }
//                if let quiz = vm.quiz {
//                    QuizAcknowledgmentView(quiz: quiz, onFinish: onFinish)
//                }
                //QuizAcknowledgmentView(quiz: vm.quiz, onFinish: onFinish)
            }
            
          
            else { VStack {
                // Header
                HStack {
                    Button(action: dismiss.callAsFunction) {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text(quizTitle)
                        .font(.title)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding()
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle().fill(Color.gray.opacity(0.2))
                        Rectangle().fill(Color.blue).frame(width: progress * geometry.size.width)
                    }
                    .clipShape(Capsule())
                }
                .frame(height: 20)
                .padding(.horizontal)
                
                // Question content
                if currentIndex < vm.questions.count {
                    questionContent(vm.questions[currentIndex])
                }
                
                Spacer()
            }
            }
        }
        .onAppear {
            Task {
                await vm.fetchQuizInfoAndQuestions(quizId: quizId)
            }
        }
        .fullScreenCover(isPresented: $showScoreCard) {
            ScoreCardView(score: vm.finalScore, onDismiss: onFinish, onRedo: restartQuiz)
        }
        .padding()
        .background(Color("Background"))
        .edgesIgnoringSafeArea(.all)
    }

    @ViewBuilder
    private func questionContent(_ question: Question) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Question \(currentIndex + 1) of \(vm.questions.count)")
                .font(.headline)
            
            Text(question.questionText)
                .font(.title2)
                .fontWeight(.semibold)
            
            ForEach(question.options.indices, id: \.self) { index in
                Button(action: {
                    selectAnswer(question.options[index])
                }) {
                    OptionView(
                        option: question.options[index],
                        isSelected: vm.userAnswers[currentIndex] == question.options[index],
                        isCorrect: question.answer == question.options[index],
                        showCorrectAnswer: showCorrectAnswer
                    )
                }
                .disabled(answerSelected)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    private func selectAnswer(_ answer: String) {
        withAnimation(.easeInOut) {
            vm.userAnswers[currentIndex] = answer
            answerSelected = true
            showCorrectAnswer = vm.questions[currentIndex].answer != answer
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                if currentIndex < vm.questions.count - 1 {
                    currentIndex += 1
                    answerSelected = false
                    showCorrectAnswer = false
                } else {
                    finishQuiz()
                }
            }
        }
    }
    
    private func finishQuiz() {
        Task {
            await vm.finalizeQuizAndRecordScore(forQuiz: quizId)
            showScoreCard = true
        }
    }
    
    private func restartQuiz() {
        currentIndex = 0
        vm.userAnswers = Array(repeating: "", count: vm.questions.count)
        showScoreCard = false
        answerSelected = false
        showCorrectAnswer = false
        Task {
            await vm.fetchQuizInfoAndQuestions(quizId: quizId)
        }
    }
}

struct OptionView: View {
    let option: String
    let isSelected: Bool
    let isCorrect: Bool
    let showCorrectAnswer: Bool
    
    var body: some View {
        Text(option)
            .foregroundColor(foregroundColor)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
            .cornerRadius(10)
    }
    
    private var foregroundColor: Color {
        if isSelected {
            return .white
        } else if showCorrectAnswer && isCorrect {
            return .white
        } else {
            return .primary
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return isCorrect ? .green : .blue
        } else if showCorrectAnswer && isCorrect {
            return .red
        } else {
            return Color.gray.opacity(0.2)
        }
    }
}
//struct OptionView: View {
//    let option: String
//    let isSelected: Bool
//    
//    var body: some View {
//        Text(option)
//            .foregroundColor(isSelected ? .white : .primary)
//            .padding()
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
//            .cornerRadius(10)
//    }
//}
