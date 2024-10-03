//
//  ScoreCardView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/28/24.
//

import SwiftUI
import FirebaseFirestore

//struct ScoreCardView: View {
//    let score: CGFloat
//    let passingGrade: CGFloat = 75.0
//    let onDismiss: () -> Void
//    let onRedo: () -> Void
//    @Environment(\.dismiss) private var dismiss
//    
//    var body: some View {
//        VStack {
//            VStack(spacing: 15) {
//                Text("Result of Your Exercise")
//                    .font(.title3)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.white)
//                
//                VStack(spacing: 15) {
//                    Text(score >= passingGrade ? "Congratulations! You\n have passed" : "You did not pass. Try again!")
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                        .multilineTextAlignment(.center)
//                    
//                    Text(String(format: "%.0f%%", score))
//                        .font(.title.bold())
//                        .padding(.bottom, 10)
//                    
//                    Image("Medal")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(height: 220)
//                }
//                .foregroundColor(.black)
//                .padding(.horizontal, 15)
//                .padding(.vertical, 20)
//                .hAlign(.center)
//                .background {
//                    RoundedRectangle(cornerRadius: 25, style: .continuous)
//                        .fill(.white)
//                }
//                
//                Text(String(format: "%.0f%%", passingGrade))
//                    .font(.largeTitle)
//                    .padding()
//                    .background(Color.gray.opacity(0.4))
//                    .cornerRadius(10)
//                
//                // ... (acknowledgment text)
//                
//                if score < passingGrade {
//                    Button(action: onRedo) {
//                        Text("Redo Quiz")
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.blue)
//                            .cornerRadius(10)
//                    }
//                    .padding()
//                }
//                
//                Button(action: {
//                    Firestore.firestore().collection("Quiz").document("Info").updateData([
//                        "peopleAttended": FieldValue.increment(1.0)
//                    ])
//                    onDismiss()
//                    dismiss()
//                }) {
//                    Text("Back to Home")
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(Color.green)
//                        .cornerRadius(10)
//                }
//            }
//            .vAlign(.center)
//        }
//        .padding(15)
//        .background {
//            Color("Background")
//                .ignoresSafeArea()
//        }
//    }
//}
//struct ScoreCardView: View {
//    let score: CGFloat
//    let onDismiss: () -> Void
//    let onRedo: () -> Void
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Your Score")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//            
//            Text("\(Int(score))%")
//                .font(.system(size: 70))
//                .fontWeight(.bold)
//                .foregroundColor(scoreColor)
//            
//            Text(scoreMessage)
//                .font(.title2)
//                .multilineTextAlignment(.center)
//            
//            Button("Dismiss") {
//                onDismiss()
//            }
//            .buttonStyle(.borderedProminent)
//            
//            Button("Redo Quiz") {
//                onRedo()
//            }
//            .buttonStyle(.bordered)
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(20)
//        .shadow(radius: 10)
//    }
//    
//    private var scoreColor: Color {
//        switch score {
//        case 80...100:
//            return .green
//        case 60..<80:
//            return .yellow
//        default:
//            return .red
//        }
//    }
//    
//    private var scoreMessage: String {
//        switch score {
//        case 80...100:
//            return "Excellent! Great job!"
//        case 60..<80:
//            return "Good effort! Room for improvement."
//        default:
//            return "Keep practicing. You'll get there!"
//        }
//    }
//}
struct ScoreCardView: View {
    let score: CGFloat
    let passingGrade: CGFloat = 75.0
    let onDismiss: () -> Void
    let onRedo: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            VStack(spacing: 15) {
                Text("Result of Your Exercise")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    Text(score >= passingGrade ? "Congratulations! You\n have passed" : "You did not pass. Try again!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Text(String(format: "%.0f%%", score))
                        .font(.title.bold())
                        .padding(.bottom, 10)
                    
                    Image("Medal")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 220)
                }
                .foregroundColor(.black)
                .padding(.horizontal, 15)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(.white)
                }
                
                Text(String(format: "%.0f%%", passingGrade))
                    .font(.largeTitle)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                
                // Acknowledgment text can be added here if needed
                
                if score < passingGrade {
                    Button(action: onRedo) {
                        Text("Redo Quiz")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                
                Button(action: {
                    Firestore.firestore().collection("Quiz").document("Info").updateData([
                        "peopleAttended": FieldValue.increment(1.0)
                    ])
                    onDismiss()
                    dismiss()
                }) {
                    Text("Back to Home")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
        .padding(15)
        .background {
            Color("Background")
                .ignoresSafeArea()
        }
    }
}
