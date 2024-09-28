//
//  QuizManager.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/3/24.
//

import Foundation
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class QuizManager {
    static let shared = QuizManager()
    private let quizCollection = Firestore.firestore().collection("Quiz")
    private func quizDocuments(id: String) -> DocumentReference {
        quizCollection.document(id)
    }

    func uploadquiz(quiz: Quiz) async throws {
        try quizDocuments(id: quiz.id ).setData(from: quiz)
    }
    
    func getAllQuiz() async throws -> [Quiz] {
        let snapshot = try await quizCollection.getDocuments()
        var room: [Quiz] = []
        
        for doc in snapshot.documents {
            let rooms = try doc.data(as: Quiz.self)
            room.append(rooms)
        }
        return room
    }
    
    private func getQuizQuery()  -> Query {
        quizCollection

    }
    private func getQuizList(quiz:String)-> Query {
         quizCollection
       
            .whereField(Quiz.CodingKeys.quizCategory.rawValue, isEqualTo: quiz)
         //   .whereField(Quiz.CodingKeys.quizCategoryID.rawValue, isEqualTo: quiz.quizCategoryID)
             
     }
    
    func fetchQuizzesForAccountTypes(_ accountTypes: [String]) async throws -> [Quiz] {
          let db = Firestore.firestore()
          let quizSnapshot = try await db.collection("Quiz")
              .whereField("accountTypes", arrayContainsAny: accountTypes)
              .getDocuments()
          
          return quizSnapshot.documents.compactMap { document in
              try? document.data(as: Quiz.self)
          }
      }
    
//    func getQuizByTitle(_ title: String) async throws -> Quiz? {
//        let snapshot = try await db.collection("Quizzes").whereField("info.title", isEqualTo: title).getDocuments()
//        return try snapshot.documents.first?.data(as: Quiz.self)
//    }
    
    
//    func getQuizList(category: String?) async throws -> [Quiz]  {
//        var query = getQuizQuery()
//
//        if let category{
//            query = getQuizList(quiz:category)
//        }
//
//        return try await query
//            .getDocumentsWithSnapshot(as: Quiz.self)
//    }
    
    func fetchAllQuizzes() async throws -> [Quiz] {
          let snapshot = try await db.collection("Quiz").getDocuments()
          return snapshot.documents.compactMap { try? $0.data(as: Quiz.self) }
      }
    func getQuizList(category: String) async throws -> [Quiz] {
        var quizzes: [Quiz] = []
        let querySnapshot = try await quizCollection.whereField("quizCategory", isEqualTo: category).getDocuments()
        for document in querySnapshot.documents {
            if let quiz = try? document.data(as: Quiz.self) {
                quizzes.append(quiz)
            }
        }
        return quizzes
    }
    
    
       private let db = Firestore.firestore()

//       func uploadQuizWithQuestions(quiz: Quiz, questions: [Question]) async throws {
//           do {
//               // Upload the quiz document
//               let quizRef = try await db.collection("Quiz").addDocument(from: quiz)
//               let quizId = quizRef.documentID
//
//               // Iterate over the questions and upload each to the "Questions" subcollection
//               for question in questions {
//                   _ = try await db.collection("Quiz").document(quizId).collection("Questions").addDocument(from: question)
//               }
//           } catch {
//               // Propagate errors
//               throw error
//           }
//       }
    
//    func uploadQuizWithQuestions(quiz: Quiz, questions: [Question]) async throws {
//           let db = Firestore.firestore()
//
//           // Upload the quiz document first
//           let quizRef = db.collection("Quiz").document(quiz.id) // Using the provided quiz.id
//           do {
//               try await quizRef.setData([
//                   "id": quiz.id,
//                   "info": [
//                       "title": quiz.info.title,
//                       "description": quiz.info.description,
//                       "peopleAttended": quiz.info.peopleAttended,
//                       "rules": quiz.info.rules
//                   ],
//                   "quizCategory": quiz.quizCategory,
//                   "quizCategoryID": quiz.quizCategoryID
//               ])
//
//               // Now upload each question to the 'Questions' subcollection of this quiz
//               for question in questions {
//                   let questionData: [String: Any] = [
//                       "questionText": question.questionText,
//                       "options": question.options,
//                       "answer": question.answer
//                   ]
//                   _ = try await quizRef.collection("Questions").addDocument(data: questionData)
//               }
//           } catch let error {
//               throw error
//           }
//       }
    
//    func uploadQuizWithQuestions(quiz: Quiz, questions: [Question]) async throws {
//           let db = Firestore.firestore()
//
//           let quizRef = db.collection("Quiz").document(quiz.id)
//
//           let quizData: [String: Any] = [
//               "id": quiz.id,
//               "info": [
//                   "title": quiz.info.title,
//                   "description": quiz.info.description,
//                   "peopleAttended": quiz.info.peopleAttended,
//                   "rules": quiz.info.rules
//               ],
//               "quizCategory": quiz.quizCategory,
//               "quizCategoryID": quiz.quizCategoryID,
//               "accountTypes": quiz.accountTypes, // Make sure this line is included
//               "dateCreated": quiz.dateCreated ?? Date(),
//               "dueDate": quiz.dueDate ?? Date()
//           ]
//
//           try await quizRef.setData(quizData)
//
//           let questionsCollection = quizRef.collection("Questions")
//           for question in questions {
//               let _ = try await questionsCollection.addDocument(data: [
//                   "questionText": question.questionText,
//                   "options": question.options,
//                   "answer": question.answer
//               ])
//           }
//       }
    func updateQuizCompletion(for userId: String, with score: CGFloat, forQuiz quizId: String) async throws {
        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(userId)
        
        // Assuming the structure of your document allows for an update like this
        let newScore: [String: Any] = ["quizId": quizId, "score": score]
        
        // Append the new score to the quizScores array
        // Make sure this field name matches your Firestore document structure
        try await userRef.updateData(["quizScores": FieldValue.arrayUnion([newScore])])
        
        print("Quiz score updated successfully for user \(userId).")
    }
    
    
    // Fecthing User Quizes
    
    func fetchQuizzesByIds(_ quizIds: [String]) async throws -> [Quiz] {
            var quizzes: [Quiz] = []
            for quizId in quizIds {
                let quizRef = db.collection("Quiz").document(quizId)
                let quizSnapshot = try await quizRef.getDocument()
//                if let quiz = try quizSnapshot.data(as: Quiz.self) {
//                    quizzes.append(quiz)
//                }
                
                let quiz = try quizSnapshot.data(as: Quiz.self)
                   quizzes.append(quiz)
            }
            return quizzes
        }
    
    
    
//    func fetchAllQuizzes() async throws -> [Quiz] {
//          let snapshot = try await quizzesCollection.getDocuments()
//          return snapshot.documents.compactMap { try? $0.data(as: Quiz.self) }
//      }
//
//      func fetchQuizzesByIds(_ ids: [String]) async throws -> [Quiz] {
//          let snapshot = try await quizzesCollection.whereField("id", in: ids).getDocuments()
//          return snapshot.documents.compactMap { try? $0.data(as: Quiz.self) }
//      }
    
    func getAllQuizzes() async throws -> [Quiz] {
            let snapshot = try await quizCollection.getDocuments()
            return snapshot.documents.compactMap { document in
                try? document.data(as: Quiz.self)
            }
        }
//    func getQuiz(id: String) async throws -> Quiz {
//         let db = Firestore.firestore()
//         let docSnapshot = try await db.collection("Quiz").document(id).getDocument()
//         
//         guard let data = docSnapshot.data(), docSnapshot.exists else {
//             throw NSError(domain: "QuizManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quiz not found"])
//         }
//         
//         return try Firestore.Decoder().decode(Quiz.self, from: data)
//     }
    func updateQuizDueDate(quizId: String, newDate: Date) async throws {
        let db = Firestore.firestore()
        try await db.collection("quizzes").document(quizId).updateData([
            "dueDate": newDate
        ])
    }
    
//    func getQuizByTitle(_ title: String) async throws -> Quiz? {
//           let snapshot = try await quizCollection.whereField("info.title", isEqualTo: title).getDocuments()
//           return try snapshot.documents.first?.data(as: Quiz.self)
//       }
    
    func getQuestionsForQuiz(quizId: String) async throws -> [Question] {
            let questionsSnapshot = try await quizCollection.document(quizId).collection("Questions").getDocuments()
            return questionsSnapshot.documents.compactMap { document in
                try? document.data(as: Question.self)
            }
        }
    
    func getQuizByTitle(_ title: String) async throws -> Quiz? {
        let snapshot = try await db.collection("Quizzes").whereField("info.title", isEqualTo: title).getDocuments()
        return try snapshot.documents.first?.data(as: Quiz.self)
    }
        
        func updateQuizWithQuestions(quiz: Quiz, questions: [Question]) async throws {
            let db = Firestore.firestore()
            let quizRef = db.collection("Quiz").document(quiz.id)
            
            var quizData: [String: Any] = [
                "info": [
                    "title": quiz.info.title,
                    "description": quiz.info.description,
                    "peopleAttended": quiz.info.peopleAttended,
                    "rules": quiz.info.rules
                ],
                "quizCategory": quiz.quizCategory,
                "quizCategoryID": quiz.quizCategoryID,
                "accountTypes": quiz.accountTypes,
                "dateCreated": quiz.dateCreated ?? FieldValue.serverTimestamp(),
                "dueDate": quiz.dueDate ?? FieldValue.serverTimestamp(),
                "renewalFrequency": quiz.renewalFrequency?.rawValue ?? NSNull(),
                "nextRenewalDate": quiz.nextRenewalDates ?? NSNull()
            ]
            try await quizRef.setData(quizData, merge: true)
            //try await quizRef.updateData(quizData)
            
            // Delete existing questions
            let existingQuestions = try await quizRef.collection("Questions").getDocuments()
            for document in existingQuestions.documents {
                try await document.reference.delete()
            }
            
            // Add updated questions
            let questionsCollection = quizRef.collection("Questions")
            for question in questions {
                let _ = try await questionsCollection.addDocument(data: [
                    "questionText": question.questionText,
                    "options": question.options,
                    "answer": question.answer
                ])
            }
        }
    
    
    func deleteQuiz(_ quiz: Quiz) async throws {
        let quizRef = db.collection("Quiz").document(quiz.id)
        try await quizRef.delete()
    }
    
    func uploadQuizWithQuestions(quiz: Quiz, questions: [Question]) async throws -> String {
        // ... existing upload logic ...
        let db = Firestore.firestore()
        
        let quizRef = db.collection("Quiz").document(quiz.id)
        
        let quizData: [String: Any] = [
            "id": quiz.id,
            "info": [
                "title": quiz.info.title,
                "description": quiz.info.description,
                "peopleAttended": quiz.info.peopleAttended,
                "rules": quiz.info.rules
            ],
            "quizCategory": quiz.quizCategory,
            "quizCategoryID": quiz.quizCategoryID,
            "accountTypes": quiz.accountTypes, // Make sure this line is included
            "dateCreated": quiz.dateCreated ?? Date(),
            "dueDate": quiz.dueDate ?? Date()
        ]
        
        try await quizRef.setData(quizData)
        
        let questionsCollection = quizRef.collection("Questions")
        for question in questions {
            let _ = try await questionsCollection.addDocument(data: [
                "questionText": question.questionText,
                "options": question.options,
                "answer": question.answer
            ])
        }
        return quiz.id
    }

//    func updateQuizWithQuestions(quiz: Quiz, questions: [Question]) async throws {
//        // ... existing update logic ...
//
//        let db = Firestore.firestore()
//
//        let quizRef = db.collection("Quiz").document(quiz.id)
//
//        let quizData: [String: Any] = [
//            "info": [
//                "title": quiz.info.title,
//                "description": quiz.info.description,
//                "peopleAttended": quiz.info.peopleAttended,
//                "rules": quiz.info.rules
//            ],
//            "quizCategory": quiz.quizCategory,
//            "quizCategoryID": quiz.quizCategoryID,
//            "accountTypes": quiz.accountTypes,
//            "dueDate": quiz.dueDate ?? Date()
//        ]
//
//        try await quizRef.updateData(quizData)
//
//        // Delete existing questions
//        let existingQuestions = try await quizRef.collection("Questions").getDocuments()
//        for document in existingQuestions.documents {
//            try await document.reference.delete()
//        }
//
//        // Add updated questions
//        let questionsCollection = quizRef.collection("Questions")
//        for question in questions {
//            let _ = try await questionsCollection.addDocument(data: [
//                "questionText": question.questionText,
//                "options": question.options,
//                "answer": question.answer
//            ])
//        }
//    }
//
    
    
    func getQuizForCategory(category: String) async throws -> Quiz? {
           let quizzes = try await db.collection("Quiz")
               .whereField("quizCategory", isEqualTo: category)
               .getDocuments()
           
           return try quizzes.documents.first?.data(as: Quiz.self)
       }
       
       func getQuiz(id: String) async throws -> Quiz {
           let documentSnapshot = try await db.collection("Quiz").document(id).getDocument()
           guard let quiz = try? documentSnapshot.data(as: Quiz.self) else {
               throw NSError(domain: "QuizManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quiz not found"])
           }
           return quiz
       }
      
}
    

enum AccountType: String, CaseIterable {
    case husbandry = "Husbandry"
    case supervisor = "Supervisor"
    case VetServices = "Vet Services"
    case Admin = "Admin"

    // Add other account types as needed
}

