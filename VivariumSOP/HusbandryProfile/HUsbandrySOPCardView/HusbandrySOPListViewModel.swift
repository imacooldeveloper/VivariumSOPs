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
import FirebaseAuth
import SwiftUI
//@Observable
class HusbandrySOPListViewModel: ObservableObject {
    @Published var pdfList: [PDFCategory] = []
    @Published var currentUserProgress: UserPDFProgress?
    @Published var quiz: Quiz?
    @AppStorage("organizationId") private var organizationId: String = ""
    
    
    //    @MainActor
    //    func fetchPDFList(title: String, nameOfPdf: String) async {
    //        do {
    //            print(nameOfPdf)
    //            print(title)
    //            pdfList = try await CategoryManager.shared.getCategoryPDFList(title: title, nameOfPdf: nameOfPdf).sorted { $0.pdfName < $1.pdfName }
    //        } catch {
    //            print("Error getting pdf")
    //        }
    //    }
    
//    @MainActor
//    func fetchPDFList(title: String, nameOfPdf: String) async {
//        do {
//            print(nameOfPdf)
//            print(title)
//            // Note: Make sure CategoryManager's getCategoryPDFList is updated to handle organizationId
//            pdfList = try await CategoryManager.shared.getCategoryPDFList(title: title, nameOfPdf: nameOfPdf)
//                .filter { $0.organizationId == organizationId }
//                .sorted { $0.pdfName < $1.pdfName }
//        } catch {
//            print("Error getting pdf: \(error)")
//        }
//    }
//    
    
    
    @MainActor
        func fetchPDFList(title: String, nameOfPdf: String) async {
            do {
                pdfList = try await CategoryManager.shared.getCategoryPDFList(title: title, nameOfPdf: nameOfPdf, organizationId: organizationId)
                    .sorted { $0.pdfName < $1.pdfName }
            } catch {
                print("Error getting pdfs: \(error)")
            }
        }
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
    //    func areAllPDFsCompleted() -> Bool {
    //        guard let completedPDFs = currentUserProgress?.completedPDFs else {
    //            return false
    //        }
    //        return pdfList.allSatisfy { pdfCategory in
    //            completedPDFs.contains(pdfCategory.id)
    //        }
    //    }
    
    func areAllPDFsCompleted() -> Bool {
        guard let completedPDFs = currentUserProgress?.completedPDFs else {
            return false
        }
        return pdfList.allSatisfy { pdfCategory in
            completedPDFs.contains(pdfCategory.id)
        }
    }
    
    //    func isPDFCompleted(pdfId: String) -> Bool {
    //        guard let completedPDFs = currentUserProgress?.completedPDFs else {
    //            return false
    //        }
    //        return completedPDFs.contains(pdfId)
    //    }
    func isPDFCompleted(pdfId: String) -> Bool {
        guard let completedPDFs = currentUserProgress?.completedPDFs else {
            return false
        }
        return completedPDFs.contains(pdfId)
    }
    //    @MainActor
    //    func fetchQuizFor(category: String) async {
    //        do {
    //            let quizzes = try await QuizManager.shared.getQuizList(category: category)
    //            self.quiz = quizzes.first
    //        } catch {
    //            print("Error getting quiz")
    //        }
    //    }
    //
    @MainActor
    func fetchQuizFor(category: String) async {
        do {
            let quizzes = try await QuizManager.shared.getQuizList(category: category)
                .filter { $0.organizationId == organizationId }
            self.quiz = quizzes.first
        } catch {
            print("Error getting quiz: \(error)")
        }
    }
    
//    @MainActor
//    func fecthALlQuiz() async throws {
//        do {
//            let quizz = try await QuizManager.shared.fetchAllQuizzes()
//            self.quiz = quizz.first
//        } catch {
//            print("Error getting quiz")
//        }
//        
//    }
    
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
    
//    @MainActor
//    func fecthAllPDFs() async throws {
//        do {
//            pdfList = try await CategoryManager.shared.getAllCategoryPDF()
//        } catch{
//            print("faild")
//        }
//    }
//    
    
    @MainActor
       func fetchAllQuizzes() async {
           do {
               let quizzes = try await QuizManager.shared.getAllQuizzes(for: organizationId)
               self.quiz = quizzes.first
           } catch {
               print("Error getting quizzes: \(error)")
           }
       }

       @MainActor
       func fetchAllPDFs() async {
           do {
               // Filter PDFs by organization
               pdfList = try await CategoryManager.shared.getAllCategoryPDF()
                   .filter { $0.organizationId == organizationId }
           } catch {
               print("Failed to fetch PDFs: \(error)")
           }
       }
    
}


