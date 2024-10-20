//
//  HusbandryUserProfileView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/28/24.
//

import Foundation
import SwiftUI


struct HusbandryUserProfileView: View {
    @EnvironmentObject var navigationHandler: NavigationHandler
    @ObservedObject var viewModel = HusbandryUserProfileViewModel()
    @State private var batteryLevel: Double = 60
    var userSelected: User?
    let columns = [
        GridItem(.flexible(minimum: 100, maximum: .infinity))
    ]
   
    var body: some View {
        HusbandryUserProfileContentView(viewModel: viewModel)
                 .onAppear {
                     Task {
                         if let selectedUser = userSelected {
                             viewModel.loadUser(selectedUser)
                         } else {
                             await viewModel.fetchCurrentUser()
                         }
                         await viewModel.fetchUserQuizzes()
                     }
                 }
       }
   

    private func gaugeColorForScore(_ score: CGFloat) -> Color {
        switch score {
        case 75...100:
            return .green
        case 50..<75:
            return .yellow
        default:
            return .red
        }
    }
}
struct HusbandryUserProfileContentView: View {
    var user: User?
    @ObservedObject var viewModel: HusbandryUserProfileViewModel
    @State private var selectedDates: [String: Date] = [:]
    @State private var quizToRetake: Quiz?
    @State private var showingQuiz = false
   // @State private var isRefreshing = false
    
    
       @State private var isLoading = false
       @State private var errorMessage: String?
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 10) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    Text(viewModel.user?.username ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding()
                
                // Completed Quizzes
                VStack(alignment: .leading, spacing: 10) {
                    Text("Completed Quizzes")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if viewModel.quizzesWithScores.filter({ $0.score >= 80 }).isEmpty {
                        Text("No completed quizzes yet.")
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    } else {
                        ForEach(viewModel.quizzesWithScores.filter { $0.score >= 80 }, id: \.quiz.id) { quizWithScore in
                            HusbandryCompletedQuizCard(
                                quizWithScore: quizWithScore,
                                onRetakeQuiz: {
                                    quizToRetake = quizWithScore.quiz
                                    showingQuiz = true
                                }
                            )
                        }
                    }
                }
                
                // Uncompleted Quizzes
                VStack(alignment: .leading, spacing: 10) {
                    Text("Incompleted Quizzes")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if viewModel.uncompletedQuizzes.isEmpty {
                        Text("No Incompleted quizzes.")
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    } else {
                        Text("Total Incompleted: \(viewModel.uncompletedQuizzes.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.uncompletedQuizzes, id: \.id) { quiz in
                            HusbandryUncompletedQuizCard(quiz: quiz, user: viewModel.user, viewModel: viewModel, selectedDate: Binding(
                                get: { self.selectedDates[quiz.id] ?? Date() },
                                set: { self.selectedDates[quiz.id] = $0 }
                            ))
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("User Profile")
//        .refreshable {
//                    await refreshData()
//                }
        
        .sheet(item: $quizToRetake) { quiz in
                    HusbandryQuestionView(
                        quizId: quiz.id,
                        quizTitle: quiz.info.title,
                        onFinish: {
                            quizToRetake = nil
                            Task {
                                await viewModel.fetchUserQuizzes()
                            }
                        }
                    )
                }
                .overlay(
                    Group {
                        if isLoading {
                            ProgressView("Loading...")
                        } else if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                )
        .onAppear {
                    if let user = user {
                        Task {
                            await viewModel.fetchCompletedQuizzesAndScoresofUser(user: user)
                        }
                    }
                }
        
    }
//    func refreshData() async {
//            isRefreshing = true
//            if let user = user {
//                await viewModel.fetchCompletedQuizzesAndScoresofUser(user: user)
//            } else {
//                await viewModel.fetchCompletedQuizzesAndScores()
//            }
//            isRefreshing = false
//        }
}
struct HusbandryCircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 8.0)
                .opacity(0.3)
                .foregroundColor(Color.blue)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 8.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.blue)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
            
            Text(String(format: "%.0f%%", min(self.progress, 1.0)*100.0))
                .font(.headline)
                .bold()
        }
    }
}
extension Date {
    func HusbandrytoString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }
}
struct HusbandryCompletedQuizCard: View {
    let quizWithScore: QuizWithScore
    let onRetakeQuiz: () -> Void
    
    var body: some View {
        HStack {
            CircularProgressView(progress: quizWithScore.score / 100)
                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading) {
                Text(quizWithScore.quiz.info.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Button("Retake Quiz") {
                    onRetakeQuiz()
                }
                .foregroundColor(.blue)
                .padding(.top, 4)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
}


struct HusbandryUncompletedQuizCard: View {
    let quiz: Quiz
    let user: User?
    @ObservedObject var viewModel: HusbandryUserProfileViewModel
    @Binding var selectedDate: Date?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "flag.fill")
                    .foregroundColor(.red)
                
                Text(quiz.info.title)
                    .font(.headline)
                
                Spacer()
                
                Text(quizStatus)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if user?.accountType == "admin" {
                DatePicker("Set Due Date", selection: Binding(
                    get: { selectedDate ?? Date() },
                    set: { selectedDate = $0 }
                ), displayedComponents: .date)
                .datePickerStyle(.compact)
                
                Button(action: updateDueDate) {
                    Text("Update")
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            } else {
                Text("Due Date: \(formattedDueDate)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(10)
    }
    
    var quizStatus: String {
        if let quizScore = user?.quizScores?.first(where: { $0.quizID == quiz.id }),
           let highestScore = quizScore.scores.max(), highestScore > 0 {
            return "\(Int(highestScore))%"
        } else {
            return "Not Started"
        }
    }
    
    var formattedDueDate: String {
        print("User: \(user?.username ?? "No user")")
        print("Quiz Scores: \(user?.quizScores?.count ?? 0)")
        if let quizScore = user?.quizScores?.first(where: { $0.quizID == quiz.id }) {
            print("Found quiz score for \(quiz.id)")
            print("Due Dates: \(quizScore.dueDates ?? [:])")
            if let dueDates = quizScore.dueDates,
               let dueDate = dueDates[quiz.id],
               let unwrappedDueDate = dueDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return formatter.string(from: unwrappedDueDate)
            } else {
                print("No due date found for \(quiz.id)")
                return "Not set"
            }
        } else {
            print("No quiz score found for \(quiz.id)")
            return "Not set"
        }
    }
    
    func updateDueDate() {
        if let newDate = selectedDate {
            Task {
              
                await viewModel.fetchCompletedQuizzesAndScoresofUser(user: user!)
                await viewModel.setDueDateForFailedQuiz(user: user!, quizID: quiz.id, newDueDate: newDate)
                await viewModel.updateUserQuizDueDate(for: user, quizID: quiz.id, newDate: newDate)
            }
        }
    }
}
