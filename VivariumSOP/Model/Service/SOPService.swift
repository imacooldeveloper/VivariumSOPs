//
//  SOPService.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/2/24.
//

import Foundation
final class SOPService: ObservableObject {
    @Published var SOPForStaffTittle = ""
    @Published var pdfName = ""
    @Published var nameOFCategory = ""
    
    
    
    @Published  var pdfList: [PDFCategory] = []
    @Published var currentUserProgress: UserPDFProgress?
    @Published var quiz: Quiz?
    @Published var quizzes: [Quiz] = []
   // @MainActor
//    func fetchPDFList(title: String, nameOfPdf: String) async {
//        do {
//            print(nameOfPdf)
//            print(title)
//            pdfList = try await CategoryManager.shared.getCategoryPDFList(title: title, nameOfPdf: nameOfPdf).sorted { $0.pdfName < $1.pdfName }
//        } catch {
//            print("Error getting pdf")
//        }
//    }
//
//    @MainActor
//    func fetchUserProgress(userUID: String) async {
//        let userDocRef = Firestore.firestore().collection("Users").document(userUID)
//
//        do {
//            let snapshot = try await userDocRef.getDocument()
//            if let userPDFProgressData = snapshot.data()?["userPDFProgress"] as? [String: Any],
//               let userID = userPDFProgressData["userID"] as? String,
//               let completedPDFsArray = userPDFProgressData["completedPDFs"] as? [String] {
//                let userPDFProgress = UserPDFProgress(userID: userID, completedPDFs: completedPDFsArray)
//                self.currentUserProgress = userPDFProgress
//            } else {
//                print("Unable to decode userPDFProgress")
//            }
//        } catch {
//            print("Error fetching user progress: \(error)")
//        }
//    }
//
//    func areAllPDFsCompleted() -> Bool {
//        guard let completedPDFs = currentUserProgress?.completedPDFs else {
//            return false
//        }
//        return pdfList.allSatisfy { pdfCategory in
//            completedPDFs.contains(pdfCategory.id)
//        }
//    }
//
//    func isPDFCompleted(pdfId: String) -> Bool {
//        guard let completedPDFs = currentUserProgress?.completedPDFs else {
//            return false
//        }
//        return completedPDFs.contains(pdfId)
//    }
//
//    @MainActor
//    func fetchQuizFor(category: String) async {
//        do {
//            let quizzes = try await QuizManager.shared.getQuizList(category: category)
//            self.quiz = quizzes.first
//        } catch {
//            print("Error getting quiz")
//        }
//    }
//    @MainActor
//    func fecthALlQuiz() async throws {
//        do {
//            let quizz = try await QuizManager.shared.fetchAllQuizzes()
//            quizzes = try await QuizManager.shared.fetchAllQuizzes()
//            self.quiz = quizz.first
//        } catch {
//            print("Error getting quiz")
//        }
//        
//    }
//    
//
//    func isQuizCompleted(quizId: String) -> Bool {
//            guard let completedQuizzes = currentUserProgress?.completedPDFs else {
//                return false
//            }
//            return completedQuizzes.contains(quizId)
//        }
//    
//    @MainActor
//    func checkAndScheduleNotifications() async throws {
//        do {
//            try await fecthALlQuiz() // Fetch quizzes first
//
//            print("Starting notification check...")
//            print("Number of quizzes to check: \(quizzes.count)")
//            for quiz in quizzes {
//                print("Checking quiz with ID: \(quiz.id)")
//
//                if !isPDFCompleted(pdfId: quiz.id) {
//                    print("Quiz with ID \(quiz.id) is not completed. Scheduling notification.")
//
//                    scheduleNotification(
//                        forQuiz: quiz,
//                        daysBefore: 0, // Set daysBefore to 0 for immediate testing
//                        title: "Reminder",
//                        body: "You have a pending quiz to complete!"
//                    )
//                } else {
//                    print("Quiz with ID \(quiz.id) is already completed.")
//                }
//            }
//        } catch {
//            print("Failed to schedule notifications: \(error)")
//        }
//
//        print("Notification check completed.")
//    }
//
//    
//    func scheduleNotification(forQuiz quiz: Quiz, daysBefore: Int, title: String, body: String) {
//        guard let date = quiz.dueDate else { return }
//        
//        let calendar = Calendar.current
//        if let notificationDate = calendar.date(byAdding: .day, value: -daysBefore, to: date) {
//            let content = UNMutableNotificationContent()
//            content.title = title
//            content.body = body
//            content.sound = UNNotificationSound.default
//
//            let triggerDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date().addingTimeInterval(10)) // For immediate testing
//            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
//
//            let request = UNNotificationRequest(identifier: quiz.id ?? UUID().uuidString, content: content, trigger: trigger)
//
//            UNUserNotificationCenter.current().add(request) { error in
//                if let error = error {
//                    print("Error scheduling notification: \(error.localizedDescription)")
//                } else {
//                    print("Notification scheduled for quiz with ID: \(quiz.id ?? "Unknown")")
//                }
//            }
//        }
//    }
//   
//
//
//    @MainActor
//    func fecthAllPDFs() async throws {
//        do {
//            pdfList = try await CategoryManager.shared.getAllCategoryPDF()
//        } catch{
//            print("faild")
//        }
//    }
    
}
