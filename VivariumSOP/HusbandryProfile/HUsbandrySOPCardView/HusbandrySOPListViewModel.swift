//
//  HusbandrySOPListViewModel.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/28/24.
//

import Foundation
import FirebaseStorage
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
@Observable
class HusbandrySOPListViewModel {
    var pdfList: [PDFCategory] = []
    var currentUserProgress: UserPDFProgress?
    var quiz: Quiz?
    
    
    
    @MainActor
    func fetchPDFList(title: String, nameOfPdf: String) async {
        do {
            print(nameOfPdf)
            print(title)
            pdfList = try await CategoryManager.shared.getCategoryPDFList(title: title, nameOfPdf: nameOfPdf).sorted { $0.pdfName < $1.pdfName }
        } catch {
            print("Error getting pdf")
        }
    }

    @MainActor
    func fetchUserProgress(userUID: String) async {
        let userDocRef = Firestore.firestore().collection("Users").document(userUID)

        do {
            let snapshot = try await userDocRef.getDocument()
            if let userPDFProgressData = snapshot.data()?["userPDFProgress"] as? [String: Any],
               let userID = userPDFProgressData["userID"] as? String,
               let completedPDFsArray = userPDFProgressData["completedPDFs"] as? [String] {
                let userPDFProgress = UserPDFProgress(userID: userID, completedPDFs: completedPDFsArray)
                self.currentUserProgress = userPDFProgress
            } else {
                print("Unable to decode userPDFProgress")
            }
        } catch {
            print("Error fetching user progress: \(error)")
        }
    }

    func areAllPDFsCompleted() -> Bool {
        guard let completedPDFs = currentUserProgress?.completedPDFs else {
            return false
        }
        return pdfList.allSatisfy { pdfCategory in
            completedPDFs.contains(pdfCategory.id)
        }
    }

    func isPDFCompleted(pdfId: String) -> Bool {
        guard let completedPDFs = currentUserProgress?.completedPDFs else {
            return false
        }
        return completedPDFs.contains(pdfId)
    }

    @MainActor
    func fetchQuizFor(category: String) async {
        do {
            let quizzes = try await QuizManager.shared.getQuizList(category: category)
            self.quiz = quizzes.first
        } catch {
            print("Error getting quiz")
        }
    }
    @MainActor
    func fecthALlQuiz() async throws {
        do {
            let quizz = try await QuizManager.shared.fetchAllQuizzes()
            self.quiz = quizz.first
        } catch {
            print("Error getting quiz")
        }
        
    }

//    @MainActor
//    func uploadTestCageChangeQuiz() async throws {
//        do {
//            try await QuizManager.shared.uploadQuizWithQuestions(quiz: sampleQuiz, questions: sampleQuestions)
//            print("Quiz and questions uploaded successfully.")
//        } catch {
//            print("Failed to upload quiz and questions: \(error.localizedDescription)")
//        }
//    }
//    
    
    // view all pdfList

    @MainActor
    func fecthAllPDFs() async throws {
        do {
            pdfList = try await CategoryManager.shared.getAllCategoryPDF()
        } catch{
            print("faild")
        }
    }
}
