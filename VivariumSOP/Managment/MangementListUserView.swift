//
//  MangementListUserView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/25/24.
//

//
//  ManagementUserViewListView.swift
//  SOPProject
//
//  Created by Martin Gallardo on 8/6/24.
//

import SwiftUI

///working
//struct ManagementUserViewListView: View {
//
//   // @StateObject private var viewModel = ManagementUserViewModel()
//    var user: User
//    var allQuizzes: [Quiz] // This should be the list of all quizzes available
//    let passingScore: CGFloat = 80.0
//
//    var body: some View {
//        VStack {
//            Text(user.username)
//                .font(.title)
//                .foregroundStyle(.black)
//                .padding()
//
//            ForEach(allQuizzes, id: \.id) { quiz in
//                if let score = user.quizScores?.first(where: { $0.quizID == quiz.id })?.scores.max() {
//                   // print("Quiz attempted: \(quiz.info.title) with score \(score)")
//                    QuizRow(quiz: quiz, score: score)
//                } else {
//                   // print("Quiz not attempted: \(quiz.info.title)")
//                    QuizRow(quiz: quiz, score: nil) // Handling the case where the quiz has not been attempted
//                }
//
//            }
//
//        }
//        .padding()
//        .background{
//            RoundedRectangle(cornerRadius: 12)
//                .foregroundStyle(.gray.opacity(0.6))
//
//        }
//        .onAppear {
//
//        }
//    }
//
//    @ViewBuilder
//    func QuizRow(quiz: Quiz, score: CGFloat?) -> some View {
//        HStack {
//            Text(quiz.info.title)
//                .font(.headline)
//            Spacer()
//            if let score = score {
//                Text("\(score, specifier: "%.0f")%")
//                    .foregroundColor(score >= passingScore ? .green : .red)
//            } else {
//                Text("Not Attempted")
//                    .foregroundColor(.red)
//            }
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(10)
//        .shadow(radius: 3)
//    }
//}

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct ManagementUserViewListView: View {
    var user: User
    var allQuizzes: [Quiz]
    
    var userQuizzes: [Quiz] {
        allQuizzes.filter { quiz in
            (user.quizScores?.contains(where: { $0.quizID == quiz.id }) ?? false) ||
            (quiz.accountTypes.contains(user.accountType ?? ""))
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            UserHeader(user: user)
            
            QuizListCard(quizzes: userQuizzes, user: user)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .navigationTitle("User Progress")
    }
}

struct UserHeader: View {
    var user: User
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
            
            Text(user.username)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(user.accountType ?? "No account type")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(15)
    }
}

struct QuizListCard: View {
    var quizzes: [Quiz]
    var user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if quizzes.isEmpty {
                Text("No quizzes assigned")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(quizzes, id: \.id) { quiz in
                    QuizRow(quiz: quiz, score: user.quizScores?.first(where: { $0.quizID == quiz.id })?.scores.max())
                    
                    if quiz.id != quizzes.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
    }
}

struct QuizRow: View {
    var quiz: Quiz
    var score: CGFloat?
    let passingScore: CGFloat = 80.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                          Image(systemName: "doc.text.fill")
                              .foregroundColor(.blue)
                          Text("Quiz: \(quiz.info.title)")
                              .font(.headline)
                              .foregroundColor(.blue)
                          
                          Spacer()
                          
                          Text(quiz.accountTypes.joined(separator: ", "))
                              .font(.caption)
                              .foregroundColor(.secondary)
                      }
            
            if let score = score {
                HStack {
                    ProgressView(value: score, total: 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: score >= passingScore ? .green : .red))
                        .frame(height: 8)
                    
                    Text("\(Int(score))%")
                        .font(.subheadline)
                        .foregroundColor(score >= passingScore ? .green : .red)
                        .frame(width: 50, alignment: .trailing)
                }
                
                Text(score >= passingScore ? "Passed" : "Failed")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(score >= passingScore ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .foregroundColor(score >= passingScore ? .green : .red)
                    .cornerRadius(8)
            } else {
                Text("Not Attempted")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
        }
    }
}



// This extension should be in your QuizManager file

import Combine
@MainActor
final class ManagementUserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var quizzes: [Quiz] = []
    
//    func fetchAllUsersAndQuizzes() async {
//        do {
//               // Fetch users and quizzes concurrently
//               async let fetchedUsers = UserProfileViewModel().fecthAllUserReturn()
//               async let fetchedQuizzes = QuizManager.shared.fetchAllQuizzes()
//               
//               // Await both tasks concurrently
//               self.users = try await fetchedUsers
//               self.quizzes = try await fetchedQuizzes
//               
//               print("Fetched \(users.count) users and \(quizzes.count) quizzes")
//           } catch {
//               print("Failed to fetch data: \(error)")
//           }
//    }
    
    func fetchAllUsersAndQuizzes() async {
        do {
            // Fetch users
            self.users = try await UserProfileViewModel().fecthAllUserReturn()
            
            // Fetch all unique account types from users
            let accountTypes = Set(users.compactMap { $0.accountType })
            
            // Fetch quizzes for these account types
            self.quizzes = try await QuizManager.shared.fetchQuizzesForAccountTypes(Array(accountTypes))
            
            print("Fetched \(users.count) users and \(quizzes.count) quizzes")
        } catch {
            print("Failed to fetch data: \(error)")
        }
    }
}

