//
//  QuizGenerationService.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 1/29/25.
//




import Foundation
import PDFKit
import OpenAISwift

import Foundation
import PDFKit

class QuizGenerationService {
    private let apiKey = "your-api-key-here"
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    // MARK: - Types
    struct GeneratedQuestion: Identifiable, Equatable {
        let id: UUID
        let questionText: String
        let options: [String]
        let correctAnswer: String
        var isSelected: Bool
        var confidence: Double
        
        init(
            id: UUID = UUID(),
            questionText: String,
            options: [String],
            correctAnswer: String,
            isSelected: Bool = true,
            confidence: Double
        ) {
            self.id = id
            self.questionText = questionText
            self.options = options
            self.correctAnswer = correctAnswer
            self.isSelected = isSelected
            self.confidence = confidence
        }
    }
    
    enum QuizGenerationError: LocalizedError {
        case pdfExtractionFailed
        case apiError(String)
        case parsingError(String)
        case emptyContent
        case downloadError
        case invalidQuestionFormat
        
        var errorDescription: String? {
            switch self {
            case .pdfExtractionFailed:
                return "Failed to extract text from PDF"
            case .apiError(let message):
                return "API Error: \(message)"
            case .parsingError(let message):
                return "Parsing Error: \(message)"
            case .emptyContent:
                return "No content found to generate questions"
            case .downloadError:
                return "Failed to download PDF"
            case .invalidQuestionFormat:
                return "Generated questions are not in the correct format"
            }
        }
    }
    
    func generateQuestionsFromPDF(_ document: PDFDocument) async throws -> [GeneratedQuestion] {
        guard let downloadURL = document.downloadURL else {
            throw QuizGenerationError.downloadError
        }
        
        let pdfText = try await extractTextFromURL(downloadURL)
        guard !pdfText.isEmpty else {
            throw QuizGenerationError.emptyContent
        }
        
        let chunks = splitIntoChunks(text: pdfText)
        var allQuestions: [GeneratedQuestion] = []
        
        for chunk in chunks {
            let questions = try await generateQuestionsForChunk(chunk)
            allQuestions.append(contentsOf: questions)
        }
        
        return Array(allQuestions
            .sorted { $0.confidence > $1.confidence }
            .prefix(20))
    }
    
    private func extractTextFromURL(_ url: URL) async throws -> String {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let pdfDoc = PDFKit.PDFDocument(data: data) else {
            throw QuizGenerationError.pdfExtractionFailed
        }
        
        return (0..<pdfDoc.pageCount)
            .compactMap { pdfDoc.page(at: $0)?.string }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func splitIntoChunks(text: String) -> [String] {
        var chunks: [String] = []
        var currentChunk = ""
        
        let sentences = text.components(separatedBy: ". ")
        
        for sentence in sentences {
            if (currentChunk + sentence).count > 4000 {
                chunks.append(currentChunk.trimmingCharacters(in: .whitespacesAndNewlines))
                currentChunk = sentence
            } else {
                currentChunk += sentence + ". "
            }
        }
        
        if !currentChunk.isEmpty {
            chunks.append(currentChunk.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        
        return chunks
    }
    
    private func generateQuestionsForChunk(_ chunk: String) async throws -> [GeneratedQuestion] {
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let systemPrompt = """
        You are a quiz generation assistant. Generate multiple-choice questions based on the provided content.
        Focus on key concepts and important details. Each question should have exactly 4 options and one clear correct answer.
        Respond in JSON format with exactly 10 questions.
        """
        
        let userPrompt = """
        Generate 10 multiple choice questions from this content. Return them in this JSON format:
        {
            "questions": [
                {
                    "question": "Question text here?",
                    "options": ["Option A", "Option B", "Option C", "Option D"],
                    "correctAnswer": "Correct option text",
                    "confidence": 0.95
                }
            ]
        }

        Content to generate questions from:
        \(chunk)
        """
        
        let messages: [[String: Any]] = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": userPrompt]
        ]
        
        let requestBody: [String: Any] = [
            "model": "gpt-4",
            "messages": messages,
            "temperature": 0.3,
            "max_tokens": 2000
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String,
              let jsonData = content.data(using: .utf8) else {
            throw QuizGenerationError.parsingError("Failed to parse response")
        }
        
        return try parseQuestions(from: jsonData)
    }
    
    private func parseQuestions(from jsonData: Data) throws -> [GeneratedQuestion] {
        struct APIResponse: Codable {
            let questions: [APIQuestion]
        }
        
        struct APIQuestion: Codable {
            let question: String
            let options: [String]
            let correctAnswer: String
            let confidence: Double
        }
        
        let apiResponse = try JSONDecoder().decode(APIResponse.self, from: jsonData)
        
        return apiResponse.questions.map { apiQ in
            GeneratedQuestion(
                questionText: apiQ.question,
                options: apiQ.options,
                correctAnswer: apiQ.correctAnswer,
                isSelected: true,
                confidence: apiQ.confidence
            )
        }
    }
}
