//
//  HusbandrySOPDetailView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/28/24.
//



import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import PDFKit
struct PDFDetailsView: View {
    let pdfDocument: PDFCategory
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: PDFViewModel
    @State private var isCompleted = false
    @State private var timer: Timer?
    @State private var timeRemaining: Int = 60 // 1 minute in seconds
    @State private var pdfKitDocument: PDFKit.PDFDocument?
    var body: some View {
        VStack {
            if let pdfURL = pdfDocument.pdfURL, let url = URL(string: pdfURL) {
                           if isCompleted {
                               Image(systemName: "checkmark.circle.fill")
                                   .resizable()
                                   .frame(width: 30, height: 30)
                                   .foregroundColor(.green)
                                   .transition(.scale)
                                   .animation(.easeInOut, value: isCompleted)
                           }
                           
                           PDFKitRepresentedView(document: pdfKitDocument)
                               .frame(maxWidth: .infinity, maxHeight: .infinity)
                       } else {
                           Text("PDF URL is not available.")
                       }

            

            if !isCompleted {
                HStack {
                    Text("Time remaining: \(formattedTime)")
                        .font(.headline)
                    Spacer()
                }
                .padding()
            }

            Button(action: markAsCompleted, label: {
                Text(isCompleted ? "Completed 👍🏻" : "Done")
            })
         //   .disabled(timeRemaining > 0 && !isCompleted)

            
            Spacer()
        }
        .padding()
        .navigationBarTitle("PDF Detail", displayMode: .inline)
        .onAppear {
            setupView()
            loadPDF()
        }
        .onDisappear {
            stopTimer()
        }
    }

    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    private func loadPDF() {
            if let pdfURL = pdfDocument.pdfURL, let url = URL(string: pdfURL) {
                pdfKitDocument = PDFKit.PDFDocument(url: url)
            }
        }
    func setupView() {
        Task {
            do {
                try await vm.fecthUser()
                // Directly use pdfDocument.id as it is already a String
                isCompleted = vm.isPDFCompleted(pdfId: pdfDocument.id)
                
                if !isCompleted {
                    startTimer()
                }
            } catch {
                print("Error fetching user data: \(error.localizedDescription)")
            }
        }
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func markAsCompleted() {
        // No need for optional binding, pdfDocument.id is a String
        let pdfId = pdfDocument.id

        Task {
            
            if var currentUser = vm.currentUser {
                   await vm.markPDFAsCompleted(pdfId: pdfId, for: &currentUser)
               }
            isCompleted = true
//            do {
//
//            } catch {
//                print("Error marking PDF as completed: \(error.localizedDescription)")
//            }
        }
        dismiss()
    }
}


