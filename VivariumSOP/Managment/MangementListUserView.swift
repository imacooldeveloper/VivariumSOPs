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

import SwiftUI
import Firebase
import FirebaseFirestore

import UniformTypeIdentifiers
//import XLSX


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



import Combine
@MainActor
final class ManagementUserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var quizzes: [Quiz] = []
    @AppStorage("organizationId")  var organizationId: String = ""
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
    
    //    func fetchAllUsersAndQuizzes() async {
    //        do {
    //            // Fetch users
    //            self.users = try await UserProfileViewModel().fecthAllUserReturn()
    //
    //            // Fetch all unique account types from users
    //            let accountTypes = Set(users.compactMap { $0.accountType })
    //
    //            // Fetch quizzes for these account types
    //            self.quizzes = try await QuizManager.shared.fetchQuizzesForAccountTypes(Array(accountTypes), organizationId: organizationId)
    //
    //            print("Fetched \(users.count) users and \(quizzes.count) quizzes")
    //        } catch {
    //            print("Failed to fetch data: \(error)")
    //        }
    //    }
    //
    
    //    @MainActor
    //    func fetchAllUsersAndQuizzes() async {
    //        do {
    //            // Fetch and filter users by organization
    //            let allUsers = try await UserProfileViewModel().fecthAllUserReturn()
    //            self.users = allUsers.filter { $0.organizationId == organizationId }
    //
    //            // Get account types from organization's users
    //            let accountTypes = Set(self.users.map { $0.accountType })
    //
    //            // Fetch quizzes for the organization and these account types
    //            self.quizzes = try await QuizManager.shared.fetchQuizzesForAccountTypes(
    //                Array(accountTypes),
    //                organizationId: organizationId
    //            )
    //
    //            print("Fetched \(self.users.count) users and \(self.quizzes.count) quizzes for organization \(organizationId)")
    //        } catch {
    //            print("Failed to fetch data: \(error.localizedDescription)")
    //        }
    //    }
    ///
    ///
    ///
    ///
    ///
    ///
    ///
    ///
    ///this one was working
//    @MainActor
//    func fetchAllUsersAndQuizzes() async {
//        do {
//            // Validate organizationId
//            guard !organizationId.isEmpty else {
//                print("Error: Organization ID is empty")
//                return
//            }
//            
//            // Fetch and filter users by organization
//            let allUsers = try await UserProfileViewModel().fecthAllUserReturn()
//            self.users = allUsers.filter { $0.organizationId == organizationId }
//            
//            // Get unique account types from organization's users
//            let accountTypes = Set(self.users.map { $0.accountType })
//            print("Found account types: \(accountTypes)")
//            
//            // Convert to array, handling empty case
//            let accountTypesArray = Array(accountTypes)
//            
//            // Fetch quizzes for the organization
//            self.quizzes = try await QuizManager.shared.fetchQuizzesForAccountTypes(
//                accountTypesArray,
//                organizationId: organizationId
//            )
//            
//            print("Fetched \(self.users.count) users and \(self.quizzes.count) quizzes for organization \(organizationId)")
//        } catch {
//            print("Failed to fetch data: \(error.localizedDescription)")
//        }
//    }
//    
    @MainActor
      func fetchAllUsersAndQuizzes() async {
          do {
              // Only fetch users from the current organization
              self.users = try await UserManager.shared.getAllUser().filter { user in
                  user.organizationId == organizationId
              }
              self.quizzes = try await QuizManager.shared.getAllQuizzes(for: organizationId)
          } catch {
              print("Error fetching users and quizzes: \(error)")
          }
      }
    
}




import PDFKit
import UniformTypeIdentifiers


struct ExportAllUsersView: View {
   @StateObject private var viewModel = ManagementUserViewModel()
   @State private var isLoading = false
   
   var body: some View {
       VStack(spacing: 20) {
           Image(systemName: "square.and.arrow.up.circle.fill")
               .resizable()
               .frame(width: 60, height: 60)
               .foregroundColor(.blue)
           
           Text("Export All Users Data")
               .font(.title2)
               .fontWeight(.semibold)
           
           Button(action: {
               Task {
                   isLoading = true
                   exportAllUsersData()
                   isLoading = false // Reset loading state after export
               }
           }) {
               HStack {
                   if isLoading {
                       ProgressView()
                           .padding(.trailing, 5)
                   }
                   Text("Export to CSV")
               }
               .frame(minWidth: 200)
               .padding()
               .background(Color.blue)
               .foregroundColor(.white)
               .cornerRadius(10)
               .shadow(radius: 5)
           }
           .disabled(isLoading)
       }
       .padding()
       .frame(maxWidth: .infinity, maxHeight: .infinity)
       .background(Color(.systemGroupedBackground))
       .task {
           await viewModel.fetchAllUsersAndQuizzes()
       }
   }
   
//    func exportAllUsersData() {
//       var csv = "User,Account Type,Quiz Title,Score,Status,Completion Date,Due Date\n"
//       
//       // Create timestamp for filename
//       let dateFormatter = DateFormatter()
//       dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
//       let timestamp = dateFormatter.string(from: Date())
//       
//       // Generate CSV content
//       for user in viewModel.users {
//           for quiz in viewModel.quizzes {
//               if let quizScore = user.quizScores?.first(where: { $0.quizID == quiz.id }) {
//                   let score = quizScore.scores.max() ?? 0
//                   let status = score >= 80 ? "Passed" : "Not Passed"
//                   let completionDate = quizScore.completionDates.last?.description ?? "Not Attempted"
//                   let dueDate = quiz.dueDate?.description ?? "No Due Date"
//                   
//                   csv += "\(user.username),\(user.accountType ?? ""),\(quiz.info.title),\(score),\(status),\(completionDate),\(dueDate)\n"
//               }
//           }
//       }
//       
//       if let data = csv.data(using: .utf8) {
//           let filename = "users_progress_\(timestamp).csv"
//           let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
//           
//           do {
//               try data.write(to: tempURL)
//               let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
//               
//               if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                  let window = windowScene.windows.first,
//                  let rootVC = window.rootViewController {
//                   activityVC.popoverPresentationController?.sourceView = window
//                   rootVC.present(activityVC, animated: true)
//               }
//           } catch {
//               print("Export failed: \(error)")
//           }
//       }
//    }
//    
    func exportAllUsersData() {
        // Create timestamp for filename
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        
        // Sort all quizzes alphabetically for consistent column order
        let sortedQuizzes = viewModel.quizzes.sorted { $0.info.title < $1.info.title }
        
        // Create headers with quiz titles
        var csv = "User,Account Type"
        for quiz in sortedQuizzes {
            // Escape any commas in quiz titles
            let safeTitle = quiz.info.title.replacingOccurrences(of: ",", with: " ")
            csv += ",\(safeTitle)"
        }
        csv += "\n"
        
        // Sort users alphabetically
        let sortedUsers = viewModel.users.sorted { $0.username < $1.username }
        
        // Add each user as a row
        for user in sortedUsers {
            // Add user info
            csv += "\(user.username),\(user.accountType ?? "")"
            
            // Add score for each quiz
            for quiz in sortedQuizzes {
                if let quizScore = user.quizScores?.first(where: { $0.quizID == quiz.id }) {
                    let score = quizScore.scores.max() ?? 0
                    let passed = score >= 80 ? "P" : "F" // P for passed, F for failed
                    csv += ",\(score)(\(passed))"
                } else if quiz.accountTypes.contains(user.accountType ?? "") {
                    // Quiz is assigned but not attempted
                    csv += ",Not Attempted"
                } else {
                    // Quiz is not assigned to this user
                    csv += ",N/A"
                }
            }
            csv += "\n"
        }
        
        // Write and share the CSV file
        if let data = csv.data(using: .utf8) {
            let filename = "users_progress_\(timestamp).csv"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            
            do {
                try data.write(to: tempURL)
                let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    activityVC.popoverPresentationController?.sourceView = window
                    rootVC.present(activityVC, animated: true)
                }
            } catch {
                print("Export failed: \(error)")
            }
        }
    }
    
}
