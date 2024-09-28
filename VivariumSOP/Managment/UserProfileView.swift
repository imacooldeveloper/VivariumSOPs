//
//  UserProfileView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/25/24.
//

//
//  UserProfileView.swift
//  SOPProject
//
//  Created by Martin Gallardo on 1/22/24.
//

import SwiftUI


struct UserProfileView: View {
    @EnvironmentObject var navigationHandler: NavigationHandler
    @ObservedObject var viewModel = UserProfileViewModel()
    @State private var batteryLevel: Double = 60
    var userSelected: User?
    let columns = [
        GridItem(.flexible(minimum: 100, maximum: .infinity))
    ]
   
    var body: some View {
        UserProfileContentView(viewModel: viewModel)
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


//
//struct UserProfileContentView: View {
//    var user: User?
//    @ObservedObject var viewModel: UserProfileViewModel
//    @State private var selectedDates: [String: Date] = [:]
//    @State private var quizToRetake: Quiz?
//   // @State private var isRefreshing = false
//    
//    @State private var refreshID = UUID()
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                // Profile Header
//                VStack(spacing: 10) {
//                    Image(systemName: "person.circle.fill")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 100, height: 100)
//                        .foregroundColor(.blue)
//                    
//                    Text(viewModel.user?.username ?? "")
//                        .font(.title)
//                        .fontWeight(.bold)
//                }
//                .padding()
//                
//                // Completed Quizzes
//                VStack(alignment: .leading, spacing: 10) {
//                    Text("Completed Quizzes")
//                        .font(.headline)
//                        .padding(.horizontal)
//                    
//                    if viewModel.quizzesWithScores.filter({ $0.score >= 80 }).isEmpty {
//                        Text("No completed quizzes yet.")
//                            .foregroundColor(.secondary)
//                            .padding(.horizontal)
//                    } else {
//                        ForEach(viewModel.quizzesWithScores.filter { $0.score >= 80 }, id: \.quiz.id) { quizWithScore in
//                            CompletedQuizCard(
//                                quizWithScore: quizWithScore,
//                                onRetakeQuiz: {
//                                    quizToRetake = quizWithScore.quiz
//                                }
//                            )
//                        }
//                    }
//                }
//                
//                // Uncompleted Quizzes
//                VStack(alignment: .leading, spacing: 10) {
//                    Text("Uncompleted Quizzes")
//                        .font(.headline)
//                        .padding(.horizontal)
//                    
//                    if viewModel.uncompletedQuizzes.isEmpty {
//                        Text("No uncompleted quizzes.")
//                            .foregroundColor(.secondary)
//                            .padding(.horizontal)
//                    } else {
//                        Text("Total Uncompleted: \(viewModel.uncompletedQuizzes.count)")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                            .padding(.horizontal)
//                        
//                        ForEach(viewModel.uncompletedQuizzes, id: \.id) { quiz in
//                            UncompletedQuizCard(quiz: quiz, user: viewModel.user, viewModel: viewModel, selectedDate: Binding(
//                                get: { self.selectedDates[quiz.id] ?? Date() },
//                                set: { self.selectedDates[quiz.id] = $0 }
//                            ),
//                                                onDateUpdated: {
//                                                    refreshData()  // Add this line
//                                                })
//                        }
//                    }
//                }
//            }
//            .padding()
//            .id(refreshID)
//        }
//        .navigationTitle("User Profile")
////        .refreshable {
////                    await refreshData()
////                }
////        .onAppear {
////                    if let user = user {
////                        Task {
////                            await viewModel.fetchCompletedQuizzesAndScoresofUser(user: user)
////                        }
////                    }
////                }
//                                                
//                                .onAppear {
//                                           refreshData()
//                                       }
//        
//    }
////    func refreshData() async {
////            isRefreshing = true
////            if let user = user {
////                await viewModel.fetchCompletedQuizzesAndScoresofUser(user: user)
////            } else {
////                await viewModel.fetchCompletedQuizzesAndScores()
////            }
////            isRefreshing = false
////        }
//                                                
//                                                
//    private func refreshData() {
//           Task {
//               if let user = viewModel.user {
//                   await viewModel.fetchCompletedQuizzesAndScoresofUser(user: user)
//                   await MainActor.run {
//                       refreshID = UUID()  // This will force the view to redraw
//                   }
//               }
//           }
//       }
//}

struct UserProfileContentView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @State private var selectedDates: [String: Date] = [:]
    @State private var quizToRetake: Quiz?
    @State private var isRefreshing = false

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
                            CompletedQuizCard(
                                quizWithScore: quizWithScore,
                                onRetakeQuiz: {
                                    quizToRetake = quizWithScore.quiz
                                }
                            )
                        }
                    }
                }
                
                // Uncompleted Quizzes
                VStack(alignment: .leading, spacing: 10) {
                    Text("Uncompleted Quizzes")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if viewModel.uncompletedQuizzes.isEmpty {
                        Text("No uncompleted quizzes.")
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    } else {
                        Text("Total Uncompleted: \(viewModel.uncompletedQuizzes.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.uncompletedQuizzes, id: \.id) { quiz in
                            UncompletedQuizCard(
                                quiz: quiz,
                                user: viewModel.user,
                                viewModel: viewModel,
                                selectedDate: Binding(
                                    get: { self.selectedDates[quiz.id] ?? Date() },
                                    set: { self.selectedDates[quiz.id] = $0 }
                                ),
                                onDateUpdated: {
                                    refreshData()
                                }
                            )
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("User Profile")
        .refreshable {
            await refreshData()
        }
        .onAppear {
            refreshData()
        }
    }

    private func refreshData() {
        Task {
            isRefreshing = true
            if let user = viewModel.user {
                await viewModel.fetchCompletedQuizzesAndScoresofUser(user: user)
            }
            isRefreshing = false
        }
    }
}
struct CompletedQuizCard: View {
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


//struct UncompletedQuizCard: View {
//    let quiz: Quiz
//       let user: User?
//       @ObservedObject var viewModel: UserProfileViewModel
//       @Binding var selectedDate: Date
//       @State private var showingDatePicker = false
//    var onDateUpdated: () -> Void  // Add this line
//       var body: some View {
//           VStack(alignment: .leading, spacing: 10) {
//               HStack {
//                   Image(systemName: "flag.fill")
//                       .foregroundColor(.red)
//                   
//                   Text(quiz.info.title)
//                       .font(.headline)
//                   
//                   Spacer()
//                   
//                   Text(quizStatus)
//                       .font(.subheadline)
//                       .foregroundColor(.secondary)
//               }
//               
//               Text("Due Date: \(formattedDueDate)")
//                   .font(.subheadline)
//                   .foregroundColor(.secondary)
//               
//               Button(action: {
//                             showingDatePicker = true
//                         }) {
//                             Text("Change Due Date")
//                                 .foregroundColor(.white)
//                                 .padding(.horizontal, 20)
//                                 .padding(.vertical, 10)
//                                 .background(Color.blue)
//                                 .cornerRadius(8)
//                         }
//           }
//           .padding()
//           .background(Color.green.opacity(0.1))
//           .cornerRadius(10)
//           .sheet(isPresented: $showingDatePicker) {
//                      DatePickerView(selectedDate: $selectedDate, showingDatePicker: $showingDatePicker, onSave: {
//                          updateDueDate()
//                          onDateUpdated()  // Call this after updating the date
//                      })
//                  }
//       }
//    
//    var quizStatus: String {
//        if let quizScore = user?.quizScores?.first(where: { $0.quizID == quiz.id }),
//           let highestScore = quizScore.scores.max(), highestScore > 0 {
//            return "\(Int(highestScore))%"
//        } else {
//            return "Not Started"
//        }
//    }
//    
//    var formattedDueDate: String {
//        print("User: \(user?.username ?? "No user")")
//        print("Quiz Scores: \(user?.quizScores?.count ?? 0)")
//        if let quizScore = user?.quizScores?.first(where: { $0.quizID == quiz.id }) {
//            print("Found quiz score for \(quiz.id)")
//            print("Due Dates: \(quizScore.dueDates ?? [:])")
//            if let dueDates = quizScore.dueDates,
//               let dueDate = dueDates[quiz.id],
//               let unwrappedDueDate = dueDate {
//                let formatter = DateFormatter()
//                formatter.dateStyle = .medium
//                return formatter.string(from: unwrappedDueDate)
//            } else {
//                print("No due date found for \(quiz.id)")
//                return "Not set"
//            }
//        } else {
//            print("No quiz score found for \(quiz.id)")
//            return "Not set"
//        }
//    }
//    
//    func updateDueDate() {
//           Task {
//               await viewModel.setDueDateForFailedQuiz(user: user!, quizID: quiz.id, newDueDate: selectedDate)
//               await viewModel.updateUserQuizDueDate(for: user, quizID: quiz.id, newDate: selectedDate)
//           }
//       }
//}

struct UncompletedQuizCard: View {
    let quiz: Quiz
    let user: User?
    @ObservedObject var viewModel: UserProfileViewModel
    @Binding var selectedDate: Date
    @State private var showingDatePicker = false
    var onDateUpdated: () -> Void
   
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
            
            Text("Due Date: \(formattedDueDate)")
                           .font(.subheadline)
                           .foregroundColor(.secondary)
                       
                       Button(action: {
                           showingDatePicker = true
                       }) {
                           Text("Change Due Date")
                               .foregroundColor(.white)
                               .padding(.horizontal, 20)
                               .padding(.vertical, 10)
                               .background(Color.blue)
                               .cornerRadius(8)
                       }
                   }
                   .padding()
                   .background(Color.green.opacity(0.1))
                   .cornerRadius(10)
                   .sheet(isPresented: $showingDatePicker) {
                       DatePickerView(selectedDate: $selectedDate, showingDatePicker: $showingDatePicker, onSave: {
                           updateDueDate()
                       })
                   }
        }
    

    private var quizStatus: String {
        if let quizScore = user?.quizScores?.first(where: { $0.quizID == quiz.id }),
           let highestScore = quizScore.scores.max(), highestScore > 0 {
            return "\(Int(highestScore))%"
        } else {
            return "Not Started"
        }
    }
//
//private var formattedDueDates: String {
//        if let quizScore = viewModel.user?.quizScores?.first(where: { $0.quizID == quiz.id }),
//           let dueDates = quizScore.dueDate,
//           let dueDate = dueDates[quiz.id],
//           let unwrappedDueDate = dueDate {
//            let formatter = DateFormatter()
//            formatter.dateStyle = .medium
//            return formatter.string(from: unwrappedDueDate)
//        } else {
//            return "Not set"
//        }
//    }
    private var formattedDueDate: String {
        if let quizScore = viewModel.user?.quizScores?.first(where: { $0.quizID == quiz.id }),
           let dueDates = quizScore.dueDates,
           let dueDate = dueDates[quiz.id],
           let unwrappedDueDate = dueDate {  // Unwrap the inner optional
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: unwrappedDueDate)
        } else {
            return "Not set"
        }
    }
    private func updateDueDate() {
        Task {
            let newRenewalDate = Calendar.current.date(byAdding: .month, value: 3, to: selectedDate) ?? selectedDate
            await viewModel.setDueDateForFailedQuiz(user: viewModel.user!, quizID: quiz.id, newDueDate: selectedDate, newRenewalDate: newRenewalDate)
            await viewModel.updateUserQuizDueDate(for: viewModel.user, quizID: quiz.id, newDate: selectedDate)
            onDateUpdated()
        }
    }
}

struct CircularProgressView: View {
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
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }
}

#Preview {
    NavigationStack{
        UserProfileView()
    }
}
struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Binding var showingDatePicker: Bool
    var onSave: () -> Void

    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select Due Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                
                Button("Save") {
                    onSave()
                    showingDatePicker = false
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .navigationTitle("Change Due Date")
            .navigationBarItems(trailing: Button("Cancel") {
                showingDatePicker = false
            })
        }
    }
}
