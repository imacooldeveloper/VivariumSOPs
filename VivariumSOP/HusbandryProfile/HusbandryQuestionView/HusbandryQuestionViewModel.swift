//
//  HusbandryQuestionViewModel.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/28/24.
//

import Foundation
import FirebaseStorage
import Combine
import FirebaseFirestore
import FirebaseAuth

final class HusbandryQuestionViewModel: ObservableObject {
    @Published var finalScore: CGFloat = 0
    @Published var quizInfo: Info?
    @Published var questions: [Question] = []
    @Published var userAnswers: [String] = []
    
    @Published var isLoading = true
    private let db = Firestore.firestore()
    
    
//    @MainActor
//       func fetchQuizInfoAndQuestions(quizId: String) async {
//           DispatchQueue.main.async {
//                      self.isLoading = true
//                  }
//           
//           do {
//               print("Fetching questions for quiz ID: \(quizId)")
//               let questionDocumentsSnapshot = try await db.collection("Quiz").document(quizId).collection("Questions").getDocuments()
//               print("Found \(questionDocumentsSnapshot.documents.count) questions in Firestore")
//               
//               var questions = questionDocumentsSnapshot.documents.compactMap { document -> Question? in
//                   guard var question = try? document.data(as: Question.self) else {
//                       print("Failed to decode question with ID \(document.documentID): \(document.data())")
//                       return nil
//                   }
//                   question.id = document.documentID // Manually set the ID here
//                   return question
//               }
//               questions.shuffle()
//               
//               // Select only 5 random questions
//               let selectedQuestions = Array(questions.prefix(5))
//               
//               print("Successfully decoded \(questions.count) questions")
//               
//               await MainActor.run {
//                   self.questions = selectedQuestions
//                   self.userAnswers = Array(repeating: "", count: selectedQuestions.count) // Initialize with empty answers
//               }
//           } catch {
//               print("Error fetching questions: \(error)")
//           }
//       }
       
    func fetchQuizInfoAndQuestions(quizId: String) async {
           DispatchQueue.main.async {
               self.isLoading = true
           }
           
           do {
               print("Fetching questions for quiz ID: \(quizId)")
               let questionDocumentsSnapshot = try await db.collection("Quiz").document(quizId).collection("Questions").getDocuments()
               print("Found \(questionDocumentsSnapshot.documents.count) questions in Firestore")
               
               var questions = questionDocumentsSnapshot.documents.compactMap { document -> Question? in
                   guard var question = try? document.data(as: Question.self) else {
                       print("Failed to decode question with ID \(document.documentID): \(document.data())")
                       return nil
                   }
                   question.id = document.documentID // Manually set the ID here
                   return question
               }
               questions.shuffle()
               
               // Select only 5 random questions
               let selectedQuestions = Array(questions.prefix(5))
               
               print("Successfully decoded \(questions.count) questions")
               
               await MainActor.run {
                   self.questions = selectedQuestions
                   self.userAnswers = Array(repeating: "", count: selectedQuestions.count) // Initialize with empty answers
                   self.isLoading = false
               }
           } catch {
               print("Error fetching questions: \(error)")
               await MainActor.run {
                   self.isLoading = false
               }
           }
       }
    
//    func calculateFinalScore() {
//           let totalCorrectAnswers = userAnswers.enumerated().filter { index, answer in
//               return questions[index].answer == answer
//           }.count
//           finalScore = CGFloat(totalCorrectAnswers) / CGFloat(questions.count) * 100
//           print("Final score calculated: \(finalScore)")
//       }
    
    func calculateFinalScore() {
         let answeredQuestions = min(userAnswers.count, questions.count)
         let totalCorrectAnswers = zip(questions.prefix(answeredQuestions), userAnswers.prefix(answeredQuestions))
             .filter { $0.0.answer == $0.1 }
             .count
         
         if questions.isEmpty {
             finalScore = 0
         } else {
             finalScore = CGFloat(totalCorrectAnswers) / CGFloat(questions.count) * 100
         }
         
         print("Final score calculated: \(finalScore)")
         print("Total questions: \(questions.count), Answered questions: \(answeredQuestions), Correct answers: \(totalCorrectAnswers)")
     }
       
//       @MainActor
//       func updateQuizScoreForUser(userId: String, quizId: String, finalScore: CGFloat) async {
//           let userRef = Firestore.firestore().collection("Users").document(userId)
//           let userDocument = try? await userRef.getDocument().data(as: User.self)
//
//           var newUserQuizScores = userDocument?.quizScores ?? []
//           
//           if let index = newUserQuizScores.firstIndex(where: { $0.quizID == quizId }) {
//               let currentHighestScore = newUserQuizScores[index].scores.max() ?? 0
//               if currentHighestScore < finalScore {
//                   newUserQuizScores[index].scores.append(finalScore)
//                   newUserQuizScores[index].completionDates.append(Date())
//               }
//           } else {
//               let newQuizScore = UserQuizScore(quizID: quizId, scores: [finalScore], completionDates: [Date()])
//               newUserQuizScores.append(newQuizScore)
//           }
//
//           let updateData: [String: Any] = ["quizScores": newUserQuizScores.map { ["quizID": $0.quizID, "scores": $0.scores, "completionDates": $0.completionDates] }]
//           
//           do {
//               try await userRef.setData(updateData, merge: true)
//               print("Quiz score updated successfully")
//           } catch let error {
//               print("Error updating quiz score: \(error.localizedDescription)")
//           }
//       }

      
    @MainActor
      func updateQuizScoreForUser(userId: String, quizId: String, finalScore: CGFloat) async {
          let userRef = Firestore.firestore().collection("Users").document(userId)
          do {
              let userDocument = try await userRef.getDocument().data(as: User.self)
              var newUserQuizScores = userDocument.quizScores ?? []
              
              if let index = newUserQuizScores.firstIndex(where: { $0.quizID == quizId }) {
                  // Update existing quiz score
                  newUserQuizScores[index].scores.append(finalScore)
                  newUserQuizScores[index].completionDates.append(Date())
              } else {
                  // Add new quiz score
                  let newQuizScore = UserQuizScore(quizID: quizId, scores: [finalScore], completionDates: [Date()])
                  newUserQuizScores.append(newQuizScore)
              }

              let updateData: [String: Any] = [
                  "quizScores": newUserQuizScores.map { [
                      "quizID": $0.quizID,
                      "scores": $0.scores,
                      "completionDates": $0.completionDates,
                      "dueDates": $0.dueDates ?? [:] // Preserve existing dueDates
                  ] }
              ]
              
              try await userRef.setData(updateData, merge: true)
              print("Quiz score updated successfully")
          } catch let error {
              print("Error updating quiz score: \(error.localizedDescription)")
          }
      }
    
    @MainActor
       func finalizeQuizAndRecordScore(forQuiz quizId: String) async {
           calculateFinalScore()
           if let userId = Auth.auth().currentUser?.uid {
               await updateQuizScoreForUser(userId: userId, quizId: quizId, finalScore: finalScore)
           }
       }
    
    
    
}

