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




//struct ManagementUserViewListView: View {
//    var user: User
//       var allQuizzes: [Quiz]
//       
//    @State private var showingExportDialog = false
//    var userQuizzes: [Quiz] {
//            allQuizzes.filter { quiz in
//                (user.quizScores?.contains(where: { $0.quizID == quiz.id }) ?? false) ||
//                (quiz.accountTypes.contains(user.accountType ?? ""))
//            }
//        }
//    var body: some View {
//        VStack(spacing: 20) {
//            UserHeader(user: user)
//            QuizListCard(quizzes: userQuizzes, user: user)
//        }
//        .padding()
//        .background(Color(.systemGroupedBackground))
//        .navigationTitle("User Progress")
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: { showingExportDialog = true }) {
//                    Image(systemName: "square.and.arrow.up")
//                }
//            }
//        }
//        .fileExporter(
//            isPresented: $showingExportDialog,
//            document: UserProgressDocument(user: user, quizzes: userQuizzes),
//            contentType: UTType.xlsx,
//            defaultFilename: "\(user.username)_progress.xlsx"
//        ) { result in
//            if case .failure(let error) = result {
//                print("Export failed: \(error.localizedDescription)")
//            }
//        }
//    }
//}
//struct UserProgressDocument: FileDocument {
//    let user: User
//    let quizzes: [Quiz]
//    
//    static var readableContentTypes: [UTType] { [.xlsx] }
//    
//    init(user: User, quizzes: [Quiz]) {
//        self.user = user
//        self.quizzes = quizzes
//    }
//    
//    init(configuration: ReadConfiguration) throws {
//        user = User(firstName: "", lastName: "", facilityName: "", username: "", userUID: "", userEmail: "", accountType: "", NHPAvalible: false)
//        quizzes = []
//    }
//    
//    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
//        let data = createExcelData()
//        return FileWrapper(regularFileWithContents: data)
//    }
//    
//    private func createExcelData() -> Data {
//        let workbook = Workbook()
//        let sheet = workbook.addWorksheet(name: "User Progress")
//        
//        // Add headers
//        let headers = ["Quiz Title", "Account Type", "Score", "Status", "Completion Date", "Due Date"]
//        for (col, header) in headers.enumerated() {
//            sheet.cell(row: 0, column: col).value = header
//        }
//        
//        // Add user info
//        for (index, quiz) in quizzes.enumerated() {
//            let row = index + 1
//            let quizScore = user.quizScores?.first(where: { $0.quizID == quiz.id })
//            
//            sheet.cell(row: row, column: 0).value = quiz.info.title
//            sheet.cell(row: row, column: 1).value = quiz.accountTypes.joined(separator: ", ")
//            sheet.cell(row: row, column: 2).value = quizScore?.scores.max() ?? 0
//            sheet.cell(row: row, column: 3).value = (quizScore?.scores.max() ?? 0) >= 80 ? "Passed" : "Not Passed"
//            sheet.cell(row: row, column: 4).value = quizScore?.completionDates.last?.description ?? "Not Attempted"
//            sheet.cell(row: row, column: 5).value = quiz.dueDate?.description ?? "No Due Date"
//        }
//        
//        return try! workbook.serialize()
//    }
//}


import PDFKit
import UniformTypeIdentifiers

//struct ManagementUserViewListView: View {
//    var user: User
//    var allQuizzes: [Quiz]
//    @StateObject private var viewModel = ManagementUserViewModel()
//    
//    var userQuizzes: [Quiz] {
//        allQuizzes.filter { quiz in
//            (user.quizScores?.contains(where: { $0.quizID == quiz.id }) ?? false) ||
//            (quiz.accountTypes.contains(user.accountType ?? ""))
//        }
//    }
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            UserHeader(user: user)
//            QuizListCard(quizzes: userQuizzes, user: user)
//        }
//        .padding()
//        .background(Color(.systemGroupedBackground))
//        .navigationTitle("User Progress")
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: exportData) {
//                    Image(systemName: "square.and.arrow.up")
//                }
//            }
//        }
//    }
//
//    func exportData() {
//        var csv = "User,Account Type,Quiz Title,Score,Status,Completion Date,Due Date\n"
//        
//        for quiz in userQuizzes {
//            if let quizScore = user.quizScores?.first(where: { $0.quizID == quiz.id }) {
//                let score = quizScore.scores.max() ?? 0
//                let status = score >= 80 ? "Passed" : "Not Passed"
//                let completionDate = quizScore.completionDates.last?.description ?? "Not Attempted"
//                let dueDate = quiz.dueDate?.description ?? "No Due Date"
//                
//                csv += "\(user.username),\(user.accountType ?? ""),\(quiz.info.title),\(score),\(status),\(completionDate),\(dueDate)\n"
//            }
//        }
//        
//        if let data = csv.data(using: .utf8) {
//            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(user.username)_progress.csv")
//            do {
//                try data.write(to: tempURL)
//                let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
//                
//                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                   let window = windowScene.windows.first,
//                   let rootVC = window.rootViewController {
//                    activityVC.popoverPresentationController?.sourceView = window
//                    rootVC.present(activityVC, animated: true)
//                }
//            } catch {
//                print("Export failed: \(error)")
//            }
//        }
//    }
//}



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
   
    func exportAllUsersData() {
       var csv = "User,Account Type,Quiz Title,Score,Status,Completion Date,Due Date\n"
       
       // Create timestamp for filename
       let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
       let timestamp = dateFormatter.string(from: Date())
       
       // Generate CSV content
       for user in viewModel.users {
           for quiz in viewModel.quizzes {
               if let quizScore = user.quizScores?.first(where: { $0.quizID == quiz.id }) {
                   let score = quizScore.scores.max() ?? 0
                   let status = score >= 80 ? "Passed" : "Not Passed"
                   let completionDate = quizScore.completionDates.last?.description ?? "Not Attempted"
                   let dueDate = quiz.dueDate?.description ?? "No Due Date"
                   
                   csv += "\(user.username),\(user.accountType ?? ""),\(quiz.info.title),\(score),\(status),\(completionDate),\(dueDate)\n"
               }
           }
       }
       
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
