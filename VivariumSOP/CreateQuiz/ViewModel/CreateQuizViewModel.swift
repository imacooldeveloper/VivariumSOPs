//
//  CreateQuizViewModel.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/3/24.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import PDFKit
import Vision
import UIKit
import OpenAI
//class CreateQuizViewModel: ObservableObject {
//    @Published var quizTitle = ""
//    @Published var quizCategory = ""
//    @Published var quizDueDate = Date()
//    @Published var questions: [Question] = []
//    @Published var quizzes: [Quiz] = []
//    @Published var users: [User] = []
//    
//    private let quizManager = QuizManager.shared
//    private let userManager = UserManager.shared
//    
//    func uploadQuiz() async throws {
//        let newQuiz = Quiz(id: UUID().uuidString,
//                           info: Info(title: quizTitle, description: "", peopleAttended: 0, rules: [""]),
//                           quizCategory: quizCategory,
//                           quizCategoryID: UUID().uuidString,
//                           accountTypes: [],
//                           dateCreated: Date(),
//                           dueDate: quizDueDate)
//        
//        try await quizManager.uploadQuizWithQuestions(quiz: newQuiz, questions: questions)
//    }
//    
//    func fetchAllQuizzes() async {
//        do {
//            quizzes = try await quizManager.fetchAllQuizzes()
//        } catch {
//            print("Error fetching quizzes: \(error)")
//        }
//    }
//    
//    func fetchQuizzesByCategory(_ category: String) async {
//        do {
//            quizzes = try await quizManager.getQuizList(category: category)
//        } catch {
//            print("Error fetching quizzes by category: \(error)")
//        }
//    }
//    
//    func fetchQuizzesByIds(_ ids: [String]) async {
//        do {
//            quizzes = try await quizManager.fetchQuizzesByIds(ids)
//        } catch {
//            print("Error fetching quizzes by IDs: \(error)")
//        }
//    }
//    
//    func updateQuizDueDate(quizId: String, newDate: Date) async {
//        do {
//            try await quizManager.updateQuizDueDate(quizId: quizId, newDate: newDate)
//            // Optionally, refresh the quizzes after updating
//            await fetchAllQuizzes()
//        } catch {
//            print("Error updating quiz due date: \(error)")
//        }
//    }
//    
//    func fetchAllUsers() async {
//        do {
//            users = try await userManager.getAllUsers()
//        } catch {
//            print("Error fetching users: \(error)")
//        }
//    }
//    
//    func fetchUsersWithCompletedQuizzes(quizId: String? = nil) async {
//        do {
//            users = try await userManager.getUsersWithCompletedQuizzes(quizId: quizId)
//        } catch {
//            print("Error fetching users with completed quizzes: \(error)")
//        }
//    }
//    
//    func fetchUser(by userId: String) async {
//        do {
//            let user = try await userManager.fetchUser(by: userId)
//            users = [user] // Replace the users array with the single fetched user
//        } catch {
//            print("Error fetching user: \(error)")
//        }
//    }
//    
//    func updateUserQuizScore(userID: String, quizID: String, newScore: CGFloat) async {
//        do {
//            try await userManager.updateUserQuizScore(userID: userID, quizID: quizID, newScore: newScore)
//            // Optionally, refresh the user data after updating
//            await fetchUser(by: userID)
//        } catch {
//            print("Error updating user quiz score: \(error)")
//        }
//    }
//}


///sk-TNul9OUs6epHIddYi9RrtRe5PfnJWlWG0MR15DSkTuT3BlbkFJSUC6M0MBEOVFyWlM-aRNQ55WzuRY8cIhgwdzEofREA
@MainActor
//class CreateQuizViewModel: ObservableObject {
//    @Published var quizTitle: String
//    @Published var quizDescription = ""
//    @Published var quizCategory: String
//    @Published var quizCategoryID = UUID().uuidString
//    @Published var quizDueDate = Date()
//    @Published var questions: [Question] = []
//    @Published var selectedAccountTypes = Set<String>()
//    @Published var quizExists = false
//    @Published var showAlert = false
//    @Published var isLoading = false
//    
//    //api "sk-TNul9OUs6epHIddYi9RrtRe5PfnJWlWG0MR15DSkTuT3BlbkFJSUC6M0MBEOVFyWlM-aRNQ55WzuRY8cIhgwdzEofREA"
//    //openai
//    @Published var isGeneratingQuestions = false
//        //private let openAI: OpenAISwift
//   
////    init(quizCategory: String, quizTitle: String) {
////          self.quizCategory = quizCategory
////          self.quizTitle = quizTitle
////        if let apiKey = ProcessInfo.processInfo.environment["sk-TNul9OUs6epHIddYi9RrtRe5PfnJWlWG0MR15DSkTuT3BlbkFJSUC6M0MBEOVFyWlM-aRNQ55WzuRY8cIhgwdzEofREA"] {
////            self.openAI = OpenAI<Chat>(apiToken: apiKey)
////        } else {
////            fatalError("OpenAI API key not found in environment variables")
////        }
////      }
//
//    @Published var pdfUrls: [String] = []
//     @Published var isLoadingPDFs = false
//
//     private let storage = Storage.storage()
//    private let openAI: OpenAIProtocol
//    @Published var pdfDocuments: [PDFDocument] = []
////        @Published var isLoadingPDFs = false
////        @Published var isGeneratingQuestions = false
//       init(quizCategory: String, quizTitle: String) {
//           self.quizCategory = quizCategory
//           self.quizTitle = quizTitle
//        
//           let apiKey = "sk-TNul9OUs6epHIddYi9RrtRe5PfnJWlWG0MR15DSkTuT3BlbkFJSUC6M0MBEOVFyWlM-aRNQ55WzuRY8cIhgwdzEofREA" // Replace with your actual API key or method to retrieve it
//           self.openAI = OpenAI(apiToken: apiKey)
//           
//           checkQuizExists()
//       }
////    init(category: String, quizTitle: String) {
////        self.quizCategory = category
////        self.quizTitle = quizTitle
////        print("CreateQuizViewModel initialized with category: \(category), title: \(quizTitle)")
////        
//    //}
//    @Published var pdfContents: [String] = []
//    
//    
//    func fetchPDFsFromFirebase() {
//         isLoadingPDFs = true
//         pdfDocuments.removeAll() // Clear existing documents
//         
//         let storageRef = storage.reference().child("pdfs/Husbandry/\(quizCategory)")
//         print("Fetching PDFs from path: pdfs/Husbandry/\(quizCategory)")
//
//         storageRef.listAll { [weak self] (result, error) in
//             guard let self = self else { return }
//
//             if let error = error {
//                 print("Error fetching PDFs: \(error.localizedDescription)")
//                 DispatchQueue.main.async {
//                     self.isLoadingPDFs = false
//                 }
//                 return
//             }
//
//             guard let items = result?.items else {
//                 print("No items found in the specified path")
//                 DispatchQueue.main.async {
//                     self.isLoadingPDFs = false
//                 }
//                 return
//             }
//
//             print("Found \(items.count) items in the specified path")
//
//             let group = DispatchGroup()
//
//             for item in items {
//                 group.enter()
//                 // If a specific PDF is selected, only fetch that one
//                 if self.quizTitle != self.quizCategory && item.name != self.quizTitle {
//                     group.leave()
//                     continue
//                 }
//                 
//                 item.downloadURL { (url, error) in
//                     defer { group.leave() }
//                     
//                     if let error = error {
//                         print("Error getting download URL for \(item.name): \(error.localizedDescription)")
//                         return
//                     }
//                     
//                     if let downloadURL = url {
//                         let pdfDocument = PDFDocument(
//                             name: item.name,
//                             category: self.quizCategory,
//                             pdfName: item.name,
//                             downloadURL: downloadURL
//                         )
//                         DispatchQueue.main.async {
//                             self.pdfDocuments.append(pdfDocument)
//                         }
//                         print("Added PDF: \(item.name)")
//                     } else {
//                         print("Download URL is nil for \(item.name)")
//                     }
//                 }
//             }
//
//             group.notify(queue: .main) {
//                 self.isLoadingPDFs = false
//                 print("Finished loading PDFs. Total count: \(self.pdfDocuments.count)")
//             }
//         }
//     }
//    func generateQuestionsFromAllPDFs() async {
//           isGeneratingQuestions = true
//           for pdfDocument in pdfDocuments {
//               if let url = pdfDocument.downloadURL,
//                  let pdfContent = try? String(contentsOf: url) {
//                   await generateAIQuestions(pdfContent: pdfContent)
//               }
//           }
//           isGeneratingQuestions = false
//       }
//
//    func generateAIQuestions(pdfContent: String) async {
//        isGeneratingQuestions = true
//        
//        let promptContent = """
//        Based on the following PDF content, generate 5 multiple-choice questions with 4 options each.
//        Provide the correct answer for each question. Format the output as follows:
//
//        Q1: [Question]
//        A: [Option A]
//        B: [Option B]
//        C: [Option C]
//        D: [Option D]
//        Correct Answer: [A/B/C/D]
//
//        PDF Content:
//        \(pdfContent)
//        """
//
//        do {
//            let userMessage = ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam(
//                content: .string(promptContent)
//            )
//            let message = ChatQuery.ChatCompletionMessageParam.user(userMessage)
//            let query = ChatQuery(messages: [message], model: .gpt3_5Turbo)
//            let result = try await openAI.chats(query: query)
//            
//            if let generatedContent = result.choices.first?.message.content {
//                switch generatedContent {
//                case .string(let generatedText):
//                    let newQuestions = parseGeneratedQuestions(generatedText)
//                    await MainActor.run {
//                        self.questions.append(contentsOf: newQuestions)
//                        self.isGeneratingQuestions = false
//                    }
//                case .vision:
//                    print("Received vision content instead of text")
//                    await MainActor.run {
//                        self.isGeneratingQuestions = false
//                    }
//                }
//            } else {
//                print("No generated content received from OpenAI")
//                await MainActor.run {
//                    self.isGeneratingQuestions = false
//                }
//            }
//        } catch {
//            print("Error generating questions: \(error)")
//            await MainActor.run {
//                self.isGeneratingQuestions = false
//            }
//        }
//    }
//    private func parseGeneratedQuestions(_ generatedText: String) -> [Question] {
//           let questionBlocks = generatedText.components(separatedBy: "\n\n")
//           var parsedQuestions: [Question] = []
//
//           for block in questionBlocks {
//               let lines = block.components(separatedBy: "\n")
//               guard lines.count == 6 else { continue }
//
//               let questionText = lines[0].replacingOccurrences(of: "Q\\d+: ", with: "", options: .regularExpression)
//               let options = lines[1...4].map { $0.replacingOccurrences(of: "^[A-D]: ", with: "", options: .regularExpression) }
//               let answer = lines[5].replacingOccurrences(of: "Correct Answer: ", with: "")
//
//               let question = Question(questionText: questionText, options: options, answer: options[getAnswerIndex(answer)])
//               parsedQuestions.append(question)
//           }
//
//           return parsedQuestions
//       }
//
//       private func getAnswerIndex(_ answer: String) -> Int {
//           switch answer {
//           case "A": return 0
//           case "B": return 1
//           case "C": return 2
//           case "D": return 3
//           default: return 0
//           }
//       }
//    
//    
//    
//    //storage 
//    
//    
////    func fetchPDFsFromFirebase() {
////            isLoadingPDFs = true
////            let storageRef = storage.reference().child("pdfs") // Adjust this path as needed
////
////            storageRef.listAll { (result, error) in
////                if let error = error {
////                    print("Error fetching PDFs: \(error)")
////                    self.isLoadingPDFs = false
////                    return
////                }
////
////                guard let items = result?.items else {
////                    self.isLoadingPDFs = false
////                    return
////                }
////
////                for item in items {
////                    item.downloadURL { (url, error) in
////                        if let error = error {
////                            print("Error getting download URL: \(error)")
////                            return
////                        }
////                        if let urlString = url?.absoluteString {
////                            DispatchQueue.main.async {
////                                self.pdfUrls.append(urlString)
////                            }
////                        }
////                    }
////                }
////                DispatchQueue.main.async {
////                    self.isLoadingPDFs = false
////                }
////            }
////        }
//
////        func generateQuestionsFromAllPDFs() async {
////            isGeneratingQuestions = true
////            for pdfUrl in pdfUrls {
////                if let pdfContent = await fetchPDFContent(from: pdfUrl) {
////                    await generateAIQuestions(pdfContent: pdfContent)
////                }
////            }
////            isGeneratingQuestions = false
////        }
//
//        private func fetchPDFContent(from urlString: String) async -> String? {
//            guard let url = URL(string: urlString) else { return nil }
//            do {
//                let (data, _) = try await URLSession.shared.data(from: url)
//                return String(data: data, encoding: .utf8)
//            } catch {
//                print("Error fetching PDF content: \(error)")
//                return nil
//            }
//        }
//    
//    
//    
//    //
//    
//    let availableAccountTypes = ["Husbandry", "Supervisor"] // Add more account types as needed
//    private var existingQuizId: String?
//    private let quizManager = QuizManager.shared
//    
//   
//    
//    func refreshQuiz() {
//            isLoading = true
//            Task {
//                do {
//                    if let existingQuiz = try await quizManager.getQuizByTitle(quizTitle) {
//                        updateViewModelWithExistingQuiz(existingQuiz)
//                    }
//                    await MainActor.run {
//                        isLoading = false
//                    }
//                } catch {
//                    print("Error refreshing quiz: \(error)")
//                    await MainActor.run {
//                        isLoading = false
//                    }
//                }
//            }
//        }
//    
//    func checkQuizExists() {
//           Task {
//               do {
//                   let existingQuiz = try await quizManager.getQuizByTitle(quizTitle)
//                   await MainActor.run {
//                       self.quizExists = existingQuiz != nil
//                       self.showAlert = self.quizExists
//                       if let quiz = existingQuiz {
//                           self.existingQuizId = quiz.id // Store the existing quiz ID
//                           self.updateViewModelWithExistingQuiz(quiz)
//                       }
//                   }
//               } catch {
//                   print("Error checking if quiz exists: \(error)")
//               }
//           }
//       }
//       
//       func uploadQuiz() async throws {
//           let quizToUpload = Quiz(
//               id: existingQuizId ?? UUID().uuidString, // Use existing ID if available
//               info: Info(
//                   title: quizTitle,
//                   description: quizDescription,
//                   peopleAttended: 0,
//                   rules: [""]
//               ),
//               quizCategory: quizCategory,
//               quizCategoryID: quizCategoryID,
//               accountTypes: Array(selectedAccountTypes),
//               dateCreated: existingQuizId == nil ? Date() : nil, // Only set creation date for new quizzes
//               dueDate: quizDueDate
//           )
//           
//           if existingQuizId != nil {
//               // Update existing quiz
//               try await quizManager.updateQuizWithQuestions(quiz: quizToUpload, questions: questions)
//           } else {
//               // Create new quiz
//               try await quizManager.uploadQuizWithQuestions(quiz: quizToUpload, questions: questions)
//           }
//       }
//    
//    private func updateViewModelWithExistingQuiz(_ quiz: Quiz) {
//            self.quizDescription = quiz.info.description
//            self.quizCategory = quiz.quizCategory
//            self.quizCategoryID = quiz.quizCategoryID
//            self.quizDueDate = quiz.dueDate ?? Date()
//            self.selectedAccountTypes = Set(quiz.accountTypes)
//            self.existingQuizId = quiz.id
//            
//            // Fetch questions for the existing quiz
//            Task {
//                do {
//                    let fetchedQuestions = try await quizManager.getQuestionsForQuiz(quizId: quiz.id)
//                    await MainActor.run {
//                        self.questions = fetchedQuestions
//                    }
//                } catch {
//                    print("Error fetching questions for existing quiz: \(error)")
//                }
//            }
//        }
//}
//import SwiftUI
//import FirebaseStorage
//import FirebaseFirestore

//@MainActor






class CreateQuizViewModel: ObservableObject {
    @Published var quizTitle: String
    @Published var quizDescription = ""
    @Published var quizCategory: String
    @Published var quizCategoryID = UUID().uuidString
    @Published var quizDueDate = Date()
    @Published var questions: [Question] = []
    @Published var selectedAccountTypes = Set<String>()
    @Published var quizExists = false
    @Published var showAlert = false
    @Published var isLoading = false
    let availableAccountTypes = ["Husbandry", "Supervisor"] // Add more account types as needed
    private var existingQuizId: String?
    private let quizManager = QuizManager.shared
    
    init(category: String, quizTitle: String) {
        self.quizCategory = category
        self.quizTitle = quizTitle
        print("CreateQuizViewModel initialized with category: \(category), title: \(quizTitle)")
        checkQuizExists()
    }
    
    func refreshQuiz() {
            isLoading = true
            Task {
                do {
                    if let existingQuiz = try await quizManager.getQuizByTitle(quizTitle) {
                        updateViewModelWithExistingQuiz(existingQuiz)
                    }
                    await MainActor.run {
                        isLoading = false
                    }
                } catch {
                    print("Error refreshing quiz: \(error)")
                    await MainActor.run {
                        isLoading = false
                    }
                }
            }
        }
    
    func checkQuizExists() {
           Task {
               do {
                   let existingQuiz = try await quizManager.getQuizByTitle(quizTitle)
                   await MainActor.run {
                       self.quizExists = existingQuiz != nil
                       self.showAlert = self.quizExists
                       if let quiz = existingQuiz {
                           self.existingQuizId = quiz.id // Store the existing quiz ID
                           self.updateViewModelWithExistingQuiz(quiz)
                       }
                   }
               } catch {
                   print("Error checking if quiz exists: \(error)")
               }
           }
       }
       
       func uploadQuiz() async throws {
           let quizToUpload = Quiz(
               id: existingQuizId ?? UUID().uuidString, // Use existing ID if available
               info: Info(
                   title: quizTitle,
                   description: quizDescription,
                   peopleAttended: 0,
                   rules: [""]
               ),
               quizCategory: quizCategory,
               quizCategoryID: quizCategoryID,
               accountTypes: Array(selectedAccountTypes),
               dateCreated: existingQuizId == nil ? Date() : nil, // Only set creation date for new quizzes
               dueDate: quizDueDate
           )
           
           if existingQuizId != nil {
               // Update existing quiz
               try await quizManager.updateQuizWithQuestions(quiz: quizToUpload, questions: questions)
           } else {
               // Create new quiz
               try await quizManager.uploadQuizWithQuestions(quiz: quizToUpload, questions: questions)
           }
       }
    
    private func updateViewModelWithExistingQuiz(_ quiz: Quiz) {
            self.quizDescription = quiz.info.description
            self.quizCategory = quiz.quizCategory
            self.quizCategoryID = quiz.quizCategoryID
            self.quizDueDate = quiz.dueDate ?? Date()
            self.selectedAccountTypes = Set(quiz.accountTypes)
            self.existingQuizId = quiz.id
            
            // Fetch questions for the existing quiz
            Task {
                do {
                    let fetchedQuestions = try await quizManager.getQuestionsForQuiz(quizId: quiz.id)
                    await MainActor.run {
                        self.questions = fetchedQuestions
                    }
                } catch {
                    print("Error fetching questions for existing quiz: \(error)")
                }
            }
        }
}
