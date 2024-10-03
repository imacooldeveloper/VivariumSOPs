//
//  HusbandrySopSearchView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/28/24.
//
import SwiftUI
import FirebaseAuth

import FirebaseStorage
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
@MainActor
final class SopSearchViewModel: ObservableObject {
    @Published var PDFList: [PDFCategory] = []
    @Published var filteredPDFList: [PDFCategory] = []
    
    @Published var isUserProgressFetched = false
    @Published var searchQuery: String = "" {
        didSet {
            filterPDFList()
        }
    }
    @Published var currentUserProgress: UserPDFProgress?
    @Published var completionStatus: [String: Bool] = [:]
    
    func fetchAllPDFs() async {
        do {
            PDFList = try await CategoryManager.shared.getAllCategoryPDF()
            filterPDFList()
        } catch {
            print("Failed to fetch PDFs: \(error)")
        }
    }
    
    private func filterPDFList() {
        if searchQuery.isEmpty {
            filteredPDFList = PDFList.sorted {$0.pdfName < $1.pdfName}
        } else {
            filteredPDFList = PDFList.filter { $0.pdfName.localizedCaseInsensitiveContains(searchQuery) }.sorted {$0.pdfName < $1.pdfName}
        }
    }

    func isPDFCompleted(pdfId: String) -> Bool {
        return completionStatus[pdfId] ?? false
    }
    
    func fetchUserProgress(userUID: String) async {
        let userDocRef = Firestore.firestore().collection("Users").document(userUID)

        do {
            let snapshot = try await userDocRef.getDocument()
            if let userPDFProgressData = snapshot.data()?["userPDFProgress"] as? [String: Any],
               let userID = userPDFProgressData["userID"] as? String,
               let completedPDFsArray = userPDFProgressData["completedPDFs"] as? [String] {
                let userPDFProgress = UserPDFProgress(userID: userID, completedPDFs: completedPDFsArray)
                self.currentUserProgress = userPDFProgress
                updateCompletionStatus()
            } else {
                print("Unable to decode userPDFProgress")
            }
        } catch {
            print("Error fetching user progress: \(error)")
        }
        isUserProgressFetched = true
    }
    
    private func updateCompletionStatus() {
        guard let progress = currentUserProgress else { return }
        for pdfId in progress.completedPDFs {
            completionStatus[pdfId] = true
        }
    }
}
import Foundation
struct SopSearchView: View {
    @StateObject private var viewModel = SopSearchViewModel()
    @State private var refreshTrigger = false // Add this line
    
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 200, maximum: 250), spacing: 20)
    ]
    
    var body: some View {
        VStack {
            // Search bar
            TextField("Search PDFs", text: $viewModel.searchQuery)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.filteredPDFList, id: \.id) { pdf in
                        PDFCardView(pdf: pdf, isCompleted: viewModel.isPDFCompleted(pdfId: pdf.id))
                    }
                }
                .padding()
            }
        }
        .onAppear {
            refreshData()
        }
        .onChange(of: refreshTrigger) { _ in
            refreshData()
        }
    }
    
    private func refreshData() {
           Task {
               await viewModel.fetchAllPDFs()
               if let currentUserUID = Auth.auth().currentUser?.uid {
                   await viewModel.fetchUserProgress(userUID: currentUserUID)
               }
           }
       }
       
       func triggerRefresh() {
           refreshTrigger.toggle()
       }
}
struct PDFCardView: View {
    var pdf: PDFCategory
    let isCompleted: Bool
    
    var body: some View {
        NavigationLink(value: pdf) {
            VStack(spacing: 12) {
                // PDF Icon or Custom Image
                Image(systemName: "doc.text.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
                    .padding(.top, 16)
                
                // PDF Name
                Text(pdf.pdfName)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(4)
                    .multilineTextAlignment(.center)
                    .frame(height: 100)
                    .padding(.horizontal, 12)
                
                Spacer(minLength: 0)
                
                // Category
                Text(pdf.nameOfCategory)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Completion Status
                HStack {
                    Spacer()
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.green)
                        Text("Completed")
                            .font(.headline)
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.red)
                        Text("Not Completed")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                    Spacer()
                }
              
                .padding(.vertical, 8)
               
                .background(isCompleted ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
            }
            
            .frame(height: 260)
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isCompleted ? Color.green : Color.red, lineWidth: 2)
            )
        }
    }
}
