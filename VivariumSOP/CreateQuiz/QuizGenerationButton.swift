//
//  QuizGenerationButton.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 1/29/25.
//
//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
import SwiftUI

import PDFKit

struct QuizGenerationButton: View {
    @Binding var questions: [Question]
    @State private var showingQuestionGenerator = false
    @State private var isGenerating = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    let pdf: PDFDocument
    private let quizService = QuizGenerationService() // No need for apiKey parameter now
    
    var body: some View {
        Button(action: {
            showingQuestionGenerator = true
        }) {
            HStack {
                Image(systemName: "wand.and.stars")
                Text("Generate Questions")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .sheet(isPresented: $showingQuestionGenerator) {
            QuizGenerationReviewView(
                viewModel: QuizGenerationReviewViewModel(
                    document: pdf,
                    onSave: { generatedQuestions in
                        let newQuestions = generatedQuestions.map { generated in
                            Question(
                                questionText: generated.questionText,
                                options: generated.options,
                                answer: generated.correctAnswer
                            )
                        }
                        questions.append(contentsOf: newQuestions)
                    }
                )
            )
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
}

struct QuizGenerationReviewView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: QuizGenerationReviewViewModel
    @State private var selectedQuestions: Set<UUID> = []
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Generating questions...")
                } else {
                    List {
                        ForEach(viewModel.generatedQuestions) { question in
                            QuestionReviewCell(
                                question: question,
                                isSelected: selectedQuestions.contains(question.id),
                                onSelect: {
                                    if selectedQuestions.contains(question.id) {
                                        selectedQuestions.remove(question.id)
                                    } else {
                                        selectedQuestions.insert(question.id)
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Review Generated Questions")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Add Selected") {
                    let selected = viewModel.generatedQuestions.filter { question in
                        selectedQuestions.contains(question.id)
                    }
                    viewModel.onSave(selected)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(selectedQuestions.isEmpty)
            )
            .alert(isPresented: $viewModel.showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onAppear {
            Task {
                await viewModel.generateQuestions()
            }
        }
    }
}

struct QuestionReviewCell: View {
    let question: QuizGenerationService.GeneratedQuestion
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(question.questionText)
                        .font(.headline)
                    Text("Confidence: \(Int(question.confidence * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onSelect()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(question.options, id: \.self) { option in
                    HStack {
                        Text(option)
                        if option == question.correctAnswer {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .padding(.leading)
        }
        .padding(.vertical, 4)
    }
}

@MainActor
class QuizGenerationReviewViewModel: ObservableObject {
    @Published var generatedQuestions: [QuizGenerationService.GeneratedQuestion] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let document: PDFDocument?
    private let quizService = QuizGenerationService() // No need for injection now
    let onSave: ([QuizGenerationService.GeneratedQuestion]) -> Void
    
    init(document: PDFDocument?, onSave: @escaping ([QuizGenerationService.GeneratedQuestion]) -> Void) {
        self.document = document
        self.onSave = onSave
    }
    
    func generateQuestions() async {
        guard let document = document else {
            showError = true
            errorMessage = "No document provided."
            return
        }

        isLoading = true
        showError = false

        do {
            generatedQuestions = try await quizService.generateQuestionsFromPDF(document)
            isLoading = false
        } catch {
            showError = true
            errorMessage = "Failed to generate questions: \(error.localizedDescription)"
            isLoading = false
        }
    }
}


///
///

//struct QuizGenerationButton: View {
//    @Binding var questions: [Question]
//    @State private var showingQuestionGenerator = false
//    @State private var isGenerating = false
//    @State private var showingError = false
//    @State private var errorMessage = ""
//    
//    let pdf: PDFDocument
//    private let quizService = QuizGenerationService(apiKey: "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")
//    
//    var body: some View {
//        Button(action: {
//            showingQuestionGenerator = true
//        }) {
//            HStack {
//                Image(systemName: "wand.and.stars")
//                Text("Generate Questions")
//            }
//            .frame(maxWidth: .infinity)
//            .padding()
//            .background(Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(10)
//        }
//        .sheet(isPresented: $showingQuestionGenerator) {
//            QuizGenerationReviewView(
//                viewModel: QuizGenerationReviewViewModel(
//                    document: pdf,
//                    quizService: quizService,
//                    onSave: { generatedQuestions in
//                        // Convert GeneratedQuestion to your Question model
//                        let newQuestions = generatedQuestions.map { generated in
//                            Question(
//                                questionText: generated.questionText,
//                                options: generated.options,
//                                answer: generated.correctAnswer
//                            )
//                        }
//                        questions.append(contentsOf: newQuestions)
//                    }
//                )
//            )
//        }
//        .alert("Error", isPresented: $showingError) {
//            Button("OK", role: .cancel) {}
//        } message: {
//            Text(errorMessage)
//        }
//    }
//}
//
//
//
//struct QuizGenerationReviewView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @ObservedObject var viewModel: QuizGenerationReviewViewModel
//    @State private var selectedQuestions: Set<UUID> = []
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                if viewModel.isLoading {
//                    ProgressView("Generating questions...")
//                } else {
//                    List {
//                        ForEach(viewModel.generatedQuestions) { question in
//                            QuestionReviewCell(
//                                question: question,
//                                isSelected: selectedQuestions.contains(question.id),
//                                onSelect: {
//                                    if selectedQuestions.contains(question.id) {
//                                        selectedQuestions.remove(question.id)
//                                    } else {
//                                        selectedQuestions.insert(question.id)
//                                    }
//                                }
//                            )
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Review Generated Questions")
//            .navigationBarItems(
//                leading: Button("Cancel") {
//                    presentationMode.wrappedValue.dismiss()
//                },
//                trailing: Button("Add Selected") {
//                    // Fixed filter logic
//                    let selected = viewModel.generatedQuestions.filter { question in
//                        selectedQuestions.contains(question.id)
//                    }
//                    viewModel.onSave(selected)
//                    presentationMode.wrappedValue.dismiss()
//                }
//                .disabled(selectedQuestions.isEmpty)
//            )
//            .alert(isPresented: $viewModel.showError) {
//                Alert(
//                    title: Text("Error"),
//                    message: Text(viewModel.errorMessage),
//                    dismissButton: .default(Text("OK"))
//                )
//            }
//        }
//        .onAppear {
//            viewModel.generateQuestions()
//        }
//    }
//}
//struct QuestionReviewCell: View {
//    let question: QuizGenerationService.GeneratedQuestion
//    let isSelected: Bool
//    let onSelect: () -> Void
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                VStack(alignment: .leading) {
//                    Text(question.questionText)
//                        .font(.headline)
//                    Text("Confidence: \(Int(question.confidence * 100))%")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                }
//                Spacer()
//                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
//                    .foregroundColor(isSelected ? .blue : .gray)
//            }
//            .contentShape(Rectangle())
//            .onTapGesture {
//                onSelect()
//            }
//            
//            VStack(alignment: .leading, spacing: 4) {
//                ForEach(question.options, id: \.self) { option in
//                    HStack {
//                        Text(option)
//                        if option == question.correctAnswer {
//                            Image(systemName: "checkmark")
//                                .foregroundColor(.green)
//                        }
//                    }
//                }
//            }
//            .padding(.leading)
//        }
//        .padding(.vertical, 4)
//    }
//}
//
//class QuizGenerationReviewViewModel: ObservableObject {
//    @Published var generatedQuestions: [QuizGenerationService.GeneratedQuestion] = []
//    @Published var isLoading = false
//    @Published var showError = false
//    @Published var errorMessage = ""
//    
//    private let document: PDFDocument?
//    private let quizService: QuizGenerationService
//    let onSave: ([QuizGenerationService.GeneratedQuestion]) -> Void
//    
//    init(document: PDFDocument?, quizService: QuizGenerationService, onSave: @escaping ([QuizGenerationService.GeneratedQuestion]) -> Void) {
//        self.document = document
//        self.quizService = quizService
//        self.onSave = onSave
//    }
//    
//    @MainActor
//    func generateQuestions() {
//        guard let document = document else {
//            showError = true
//            errorMessage = "No document provided."
//            return
//        }
//
//        isLoading = true
//        showError = false
//
//        Task {
//            do {
//                generatedQuestions = try await quizService.generateQuestionsFromPDF(document)
//            } catch {
//                showError = true
//                errorMessage = "Failed to generate questions: \(error.localizedDescription)"
//            }
//            isLoading = false
//        }
//    }
//
//}
