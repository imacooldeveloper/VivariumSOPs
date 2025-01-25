//
//  QuizAcknowledgmentView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 1/21/25.
//

import SwiftUI
import FirebaseAuth
struct QuizAcknowledgmentView: View {
    let quiz: Quiz
    let onFinish: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var isAcknowledged = false
    @State private var showAlert = false
    @StateObject private var vm = HusbandryQuestionViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(quiz.info.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(quiz.acknowledgmentText ?? "Please review and acknowledge this content.")
                        .font(.body)
                        .padding(.vertical)
                }
                .padding()
            }
            
            Toggle("I have read and understood the above content", isOn: $isAcknowledged)
                .padding()
                .tint(.blue)
            
            Button(action: {
                if isAcknowledged {
                    submitAcknowledgment()
                } else {
                    showAlert = true
                }
            }) {
                Text("Submit Acknowledgment")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isAcknowledged ? Color.blue : Color.gray)
                    .cornerRadius(10)
            }
            .disabled(!isAcknowledged)
            .padding()
        }
        .alert("Acknowledgment Required", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please read and acknowledge the content before submitting.")
        }
    }
    
    private func submitAcknowledgment() {
        Task {
            let acknowledgmentStatus = UserQuizScore.AcknowledgmentStatus(
                acknowledged: true,
                acknowledgedDate: Date(),
                readingTime: nil,
                signature: Auth.auth().currentUser?.displayName ?? Auth.auth().currentUser?.email ?? "User"
            )
            
            let quizScore = UserQuizScore(
                quizID: quiz.id,
                scores: [100], // Acknowledgment is considered 100% complete
                completionDates: [Date()],
                acknowledgmentStatus: acknowledgmentStatus
            )
            
            // Update the user's quiz score
            if let userId = Auth.auth().currentUser?.uid {
                await vm.updateQuizScoreForUser(userId: userId, quizId: quiz.id, finalScore: 100)
            }
            
            dismiss()
            onFinish()
        }
    }
}
