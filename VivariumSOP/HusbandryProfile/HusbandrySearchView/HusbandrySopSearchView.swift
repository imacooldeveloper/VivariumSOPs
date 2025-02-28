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
    @AppStorage("organizationId") private var organizationId: String = ""
    func fetchAllPDFs() async {
            do {
                // Get all PDFs and filter by organization
                let allPDFs = try await CategoryManager.shared.getAllCategoryPDF()
                PDFList = allPDFs.filter { $0.organizationId == organizationId }
                
                filterPDFList()
            } catch {
                print("Failed to fetch PDFs: \(error)")
            }
        }
        
        private func filterPDFList() {
            if searchQuery.isEmpty {
                filteredPDFList = PDFList.sorted { $0.pdfName < $1.pdfName }
            } else {
                filteredPDFList = PDFList.filter {
                    $0.pdfName.localizedCaseInsensitiveContains(searchQuery) ||
                    $0.nameOfCategory.localizedCaseInsensitiveContains(searchQuery) ||
                    $0.SOPForStaffTittle.localizedCaseInsensitiveContains(searchQuery)
                }.sorted { $0.pdfName < $1.pdfName }
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
//struct SopSearchView: View {
//    @StateObject private var viewModel = SopSearchViewModel()
//    @State private var refreshTrigger = false // Add this line
//    
//    let columns: [GridItem] = [
//        GridItem(.adaptive(minimum: 200, maximum: 250), spacing: 20)
//    ]
//    
//    var body: some View {
//        VStack {
//            // Search bar
//            TextField("Search PDFs", text: $viewModel.searchQuery)
//                .padding()
//                .background(Color(.systemGray6))
//                .cornerRadius(10)
//                .padding(.horizontal)
//
//            ScrollView {
//                LazyVGrid(columns: columns, spacing: 20) {
//                    ForEach(viewModel.filteredPDFList, id: \.id) { pdf in
//                        PDFCardView(pdf: pdf, isCompleted: viewModel.isPDFCompleted(pdfId: pdf.id))
//                    }
//                }
//                .padding()
//            }
//        }
//        .onAppear {
//            refreshData()
//        }
//        .onChange(of: refreshTrigger) { _ in
//            refreshData()
//        }
//    }
//    
//    private func refreshData() {
//           Task {
//               await viewModel.fetchAllPDFs()
//               if let currentUserUID = Auth.auth().currentUser?.uid {
//                   await viewModel.fetchUserProgress(userUID: currentUserUID)
//               }
//           }
//       }
//       
//       func triggerRefresh() {
//           refreshTrigger.toggle()
//       }
//}
//struct PDFCardView: View {
//    var pdf: PDFCategory
//    let isCompleted: Bool
//    
//    var body: some View {
//        NavigationLink(value: pdf) {
//            VStack(spacing: 12) {
//                // PDF Icon or Custom Image
//                Image(systemName: "doc.text.fill")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 50, height: 50)
//                    .foregroundColor(.blue)
//                    .padding(.top, 16)
//                
//                // PDF Name
//                Text(pdf.pdfName)
//                    .font(.headline)
//                    .foregroundColor(.primary)
//                    .lineLimit(4)
//                    .multilineTextAlignment(.center)
//                    .frame(height: 100)
//                    .padding(.horizontal, 12)
//                
//                Spacer(minLength: 0)
//                
//                // Category
//                Text(pdf.nameOfCategory)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                
//                // Completion Status
//                HStack {
//                    Spacer()
//                    if isCompleted {
//                        Image(systemName: "checkmark.circle.fill")
//                            .font(.system(size: 24))
//                            .foregroundColor(.green)
//                        Text("Completed")
//                            .font(.headline)
//                            .foregroundColor(.green)
//                    } else {
//                        Image(systemName: "xmark.circle.fill")
//                            .font(.system(size: 24))
//                            .foregroundColor(.red)
//                        Text("Not Completed")
//                            .font(.headline)
//                            .foregroundColor(.red)
//                    }
//                    Spacer()
//                }
//              
//                .padding(.vertical, 8)
//               
//                .background(isCompleted ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
//            }
//            
//            .frame(height: 260)
//            .background(Color(.systemBackground))
//            .cornerRadius(15)
//            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
//            .overlay(
//                RoundedRectangle(cornerRadius: 15)
//                    .stroke(isCompleted ? Color.green : Color.red, lineWidth: 2)
//            )
//        }
//    }
//}
//

//struct SopSearchView: View {
//    @StateObject private var viewModel = SopSearchViewModel()
//    @State private var refreshTrigger = false
//    @Environment(\.horizontalSizeClass) var sizeClass
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            // Search bar with improved styling
//            HStack {
//                Image(systemName: "magnifyingglass")
//                    .foregroundColor(.gray)
//                TextField("Search PDFs", text: $viewModel.searchQuery)
//            }
//            .padding(12)
//            .background(
//                RoundedRectangle(cornerRadius: 12)
//                    .fill(Color(.systemGray6))
//            )
//            .padding(.horizontal)
//            .padding(.vertical, 8)
//            
//            // Dynamic layout based on device
//            if sizeClass == .regular {
//                // iPad: Keep grid layout
//                gridLayout
//            } else {
//                // iPhone: Use list layout
//                listLayout
//            }
//        }
//        .navigationTitle("PDF Library")
//        .onAppear {
//            refreshData()
//        }
//        .onChange(of: refreshTrigger) { _ in
//            refreshData()
//        }
//    }
//    
//    private var gridLayout: some View {
//        ScrollView {
//            LazyVGrid(columns: [
//                GridItem(.adaptive(minimum: 250, maximum: 300), spacing: 20)
//            ], spacing: 20) {
//                ForEach(viewModel.filteredPDFList, id: \.id) { pdf in
//                    PDFCardView(pdf: pdf, isCompleted: viewModel.isPDFCompleted(pdfId: pdf.id))
//                }
//            }
//            .padding()
//        }
//    }
//    
//    private var listLayout: some View {
//        ScrollView {
//            LazyVStack(spacing: 12) {
//                ForEach(viewModel.filteredPDFList, id: \.id) { pdf in
//                    CompactPDFCardView(pdf: pdf, isCompleted: viewModel.isPDFCompleted(pdfId: pdf.id))
//                }
//            }
//            .padding(.horizontal)
//        }
//    }
//    
//    private func refreshData() {
//        Task {
//            await viewModel.fetchAllPDFs()
//            if let currentUserUID = Auth.auth().currentUser?.uid {
//                await viewModel.fetchUserProgress(userUID: currentUserUID)
//            }
//        }
//    }
//}

// New compact card view for iPhone
struct CompactPDFCardView: View {
    var pdf: PDFCategory
    let isCompleted: Bool
    
    var body: some View {
        NavigationLink(value: pdf) {
            HStack(spacing: 16) {
                // PDF Icon
                Image(systemName: "doc.text.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 40)
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(pdf.pdfName)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(pdf.nameOfCategory)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status indicator
                VStack {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isCompleted ? .green : .gray)
                        .font(.title3)
                }
                .padding(.trailing, 4)
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isCompleted ? Color.green.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}


//struct SopSearchView: View {
//    @StateObject private var viewModel = SopSearchViewModel()
//    @State private var refreshTrigger = false
//    
//    // Grid layout that adapts to screen size
//    let columns = [
//        GridItem(.adaptive(minimum: 160, maximum: 180), spacing: 16)
//    ]
//    
//    var groupedPDFs: [String: [PDFCategory]] {
//        Dictionary(grouping: viewModel.filteredPDFList) { $0.nameOfCategory }
//    }
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            // Search bar
//            HStack {
//                Image(systemName: "magnifyingglass")
//                    .foregroundColor(.gray)
//                TextField("Search PDFs", text: $viewModel.searchQuery)
//            }
//            .padding(12)
//            .background(
//                RoundedRectangle(cornerRadius: 12)
//                    .fill(Color(.systemGray6))
//            )
//            .padding(.horizontal)
//            .padding(.vertical, 8)
//            
//            ScrollView {
//                ForEach(groupedPDFs.keys.sorted(), id: \.self) { category in
//                    Section(header: sectionHeader(category)) {
//                        LazyVGrid(columns: columns, spacing: 16) {
//                            ForEach(groupedPDFs[category] ?? [], id: \.id) { pdf in
//                                PDFCardView(pdf: pdf, isCompleted: viewModel.isPDFCompleted(pdfId: pdf.id))
//                                    .frame(height: 260)
//                            }
//                        }
//                        .padding(.horizontal)
//                    }
//                }
//            }
//        }
//        .navigationTitle("PDF Library")
//        .onAppear {
//            refreshData()
//        }
//        .onChange(of: refreshTrigger) { _ in
//            refreshData()
//        }
//    }
//    
//    private func sectionHeader(_ title: String) -> some View {
//        HStack {
//            Text(title)
//                .font(.title2)
//                .fontWeight(.bold)
//                .foregroundColor(.primary)
//            Spacer()
//        }
//        .padding(.horizontal)
//        .padding(.top, 20)
//        .padding(.bottom, 8)
//    }
//    
//    private func refreshData() {
//        Task {
//            await viewModel.fetchAllPDFs()
//            if let currentUserUID = Auth.auth().currentUser?.uid {
//                await viewModel.fetchUserProgress(userUID: currentUserUID)
//            }
//        }
//    }
//}


struct SopSearchView: View {
    @StateObject private var viewModel = SopSearchViewModel()
    @State private var refreshTrigger = false
    @State private var expandedSections: Set<String> = []
    @State private var animatingSection: String? = nil
    
//    let columns = [
//        GridItem(.adaptive(minimum: 160, maximum: 180), spacing: 16)
//    ]
    let columns = [
           GridItem(.flexible(minimum: 140, maximum: .infinity), spacing: 16),
           GridItem(.flexible(minimum: 140, maximum: .infinity), spacing: 16)
       ]
    var groupedPDFs: [String: [PDFCategory]] {
        Dictionary(grouping: viewModel.filteredPDFList) { $0.nameOfCategory }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search PDFs", text: $viewModel.searchQuery)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            ScrollView {
                         ForEach(groupedPDFs.keys.sorted(), id: \.self) { category in
                             SectionCard(
                                 category: category,
                                 isExpanded: isExpanded(category),
                                 itemCount: groupedPDFs[category]?.count ?? 0,
                                 onTap: { toggleSection(category) }
                             ) {
                                 if isExpanded(category) {
                                     LazyVGrid(columns: columns, spacing: 16) {
                                         ForEach(groupedPDFs[category] ?? [], id: \.id) { pdf in
                                             PDFCardView(pdf: pdf, isCompleted: viewModel.isPDFCompleted(pdfId: pdf.id))
                                                 .frame(height: 260)
                                         }
                                     }
                                     .padding(.horizontal)
                                     .padding(.vertical, 12)
                                 }
                             }
                             .padding(.horizontal)
                             .padding(.vertical, 6)
                         }
                     }
                 }
        .navigationTitle("PDF Library")
        .onAppear {
            refreshData()
        }
        .onChange(of: refreshTrigger) { _ in
            refreshData()
        }
    }
    
    private func isExpanded(_ category: String) -> Bool {
        expandedSections.contains(category)
    }
    
    private func toggleSection(_ category: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if isExpanded(category) {
                expandedSections.remove(category)
            } else {
                expandedSections.insert(category)
            }
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
}



struct SectionCard: View {
    let category: String
    let isExpanded: Bool
    let itemCount: Int
    let onTap: () -> Void
    let content: () -> AnyView
    
    init(
        category: String,
        isExpanded: Bool,
        itemCount: Int,
        onTap: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> some View
    ) {
        self.category = category
        self.isExpanded = isExpanded
        self.itemCount = itemCount
        self.onTap = onTap
        self.content = { AnyView(content()) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("\(itemCount) items")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.spring(response: 0.3), value: isExpanded)
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.8),
                            Color.blue.opacity(0.6)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            
            if isExpanded {
                content()
                    .padding(.top, 8)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
// Updated PDFCardView to be more compact while maintaining the same style
struct PDFCardView: View {
    var pdf: PDFCategory
    let isCompleted: Bool
    
    var body: some View {
        NavigationLink(value: pdf) {
            VStack(spacing: 8) {
                Image(systemName: "doc.text.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .foregroundColor(.blue)
                    .padding(.top, 12)
                
                Text(pdf.pdfName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                
                Spacer(minLength: 0)
                
                Text(pdf.SOPForStaffTittle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isCompleted ? .green : .red)
                    Text(isCompleted ? "Completed" : "Incomplete")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(isCompleted ? .green : .red)
                }
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(isCompleted ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
            }
            .frame(minWidth: 140, maxWidth: .infinity) // Add minWidth constraint
                       .background(Color(.systemBackground))
                       .cornerRadius(12)
                       .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                       .overlay(
                           RoundedRectangle(cornerRadius: 12)
                               .stroke(isCompleted ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
                       )
        }
    }
}
