//
//  TempSop.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 1/23/25.
//

import SwiftUI

// TempSOPManager.swift
import Firebase
import FirebaseStorage
import FirebaseFirestore
import Foundation

class TempSOPManager {
    static let shared = TempSOPManager()
     let storage = Storage.storage()
     let db = Firestore.firestore()
    
    @MainActor
    func fetchTempSOPs() async throws -> [TempSOP] {
        let snapshot = try await db.collection("TempSOPs").getDocuments()
        return try snapshot.documents.compactMap { document in
            try document.data(as: TempSOP.self)
        }
    }
    
    @MainActor
    func uploadSelectedTempSOP(_ tempSOP: TempSOP, to category: PDFCategory) async throws -> String {
        // Download the temp SOP from storage
        let storageRef = storage.reference(forURL: tempSOP.fileURL)
        let data = try await storageRef.data(maxSize: 50 * 1024 * 1024) // 50MB max
        
        // Upload to the user's actual category using existing PDFStorageManager
        return try await PDFStorageManager.shared.uploadPDF(data: data, category: category)
    }
}

// TempSOP.swift
//struct TempSOP: Identifiable, Codable {
//    let id: String
//    let name: String
//    let category: String
//    let subcategory: String
//    let fileURL: String
//    let previewURL: String? // Optional thumbnail URL
//    let description: String
//    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case name
//        case category
//        case subcategory
//        case fileURL
//        case previewURL
//        case description
//    }
//}

// TempSOPViewModel.swift
@MainActor
class TempSOPViewModel: ObservableObject {
    @Published private(set) var tempSOPs: [TempSOP] = []
    @Published private(set) var categories: Set<String> = []
    @Published private(set) var isLoading = false
    @Published var selectedCategory: String?
    
    func fetchTempSOPs() async {
        isLoading = true
        do {
            tempSOPs = try await TempSOPManager.shared.fetchTempSOPs()
            categories = Set(tempSOPs.map { $0.category })
            isLoading = false
        } catch {
            print("Error fetching temp SOPs: \(error)")
            isLoading = false
        }
    }
    
    func getSOPsByCategory(_ category: String) -> [TempSOP] {
        tempSOPs.filter { $0.category == category }
    }
    
    func uploadTempSOP(_ tempSOP: TempSOP, to category: PDFCategory) async throws -> String {
        try await TempSOPManager.shared.uploadSelectedTempSOP(tempSOP, to: category)
    }
}

// TempSOPListView.swift
//struct TempSOPListView: View {
//    @StateObject private var viewModel = TempSOPViewModel()
//    @Environment(\.presentationMode) var presentationMode
//    @State private var showingUploadSheet = false
//    @State private var selectedSOP: TempSOP?
//    @State private var showAlert = false
//    @State private var alertMessage = ""
//    @AppStorage("organizationId") private var organizationId: String = ""
//    
//    var body: some View {
//        NavigationView {
//            Group {
//                if viewModel.isLoading {
//                    ProgressView("Loading SOPs...")
//                } else {
//                    List {
//                        ForEach(Array(viewModel.categories), id: \.self) { category in
//                            Section(header: Text(category)) {
//                                ForEach(viewModel.getSOPsByCategory(category)) { sop in
//                                    TempSOPRowView(sop: sop)
//                                        .onTapGesture {
//                                            selectedSOP = sop
//                                            showingUploadSheet = true
//                                        }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Template SOPs")
//            .navigationBarItems(trailing: Button("Done") {
//                presentationMode.wrappedValue.dismiss()
//            })
//            .sheet(isPresented: $showingUploadSheet) {
//                if let sop = selectedSOP {
//                    TempSOPUploadView(sop: sop, viewModel: viewModel)
//                }
//            }
//            .alert("Error", isPresented: $showAlert) {
//                Button("OK", role: .cancel) { }
//            } message: {
//                Text(alertMessage)
//            }
//            .onAppear {
//                Task {
//                    await viewModel.fetchTempSOPs()
//                }
//            }
//        }
//    }
//}
//
//// TempSOPRowView.swift
//struct TempSOPRowView: View {
//    let sop: TempSOP
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(sop.name)
//                .font(.headline)
//            Text(sop.description)
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//            Text("Category: \(sop.subcategory)")
//                .font(.caption)
//                .foregroundColor(.blue)
//        }
//        .padding(.vertical, 8)
//    }
//}

// TempSOPUploadView.swift
struct TempSOPUploadView: View {
    let sop: TempSOP
    @ObservedObject var viewModel: TempSOPViewModel
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("organizationId") private var organizationId: String = ""
    
    @State private var selectedFolder = ""
    @State private var sopTitle = ""
    @State private var isUploading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Template SOP Details")) {
                    Text(sop.name)
                        .font(.headline)
                    Text(sop.description)
                        .font(.subheadline)
                }
                
                Section(header: Text("Upload Details")) {
                    TextField("SOP Title", text: $sopTitle)
                    TextField("Folder Name", text: $selectedFolder)
                }
                
                Section {
                    Button(action: uploadSOP) {
                        if isUploading {
                            ProgressView()
                        } else {
                            Text("Upload SOP")
                        }
                    }
                    .disabled(isUploading || sopTitle.isEmpty || selectedFolder.isEmpty)
                }
            }
            .navigationTitle("Upload Template SOP")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(isSuccess ? "Success" : "Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if isSuccess {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
        }
    }
    
    private func uploadSOP() {
        isUploading = true
        
        let category = PDFCategory(
            id: UUID().uuidString,
            nameOfCategory: selectedFolder,
            SOPForStaffTittle: sopTitle,
            pdfName: sop.name,
            organizationId: organizationId
        )
        
        Task {
            do {
                let _ = try await viewModel.uploadTempSOP(sop, to: category)
                await MainActor.run {
                    isUploading = false
                    isSuccess = true
                    alertMessage = "SOP uploaded successfully"
                    showAlert = true
                }
            } catch {
                await MainActor.run {
                    isUploading = false
                    isSuccess = false
                    alertMessage = "Error uploading SOP: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}


///
///
///
///

struct TempSOPListView: View {
    @StateObject private var viewModel = TempSOPViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showingUploadSheet = false
    @State private var selectedSOPs: Set<String> = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var searchText = ""
    @Binding var selectedTemplates: [TempSOP]
    
    //@State private var selectedSOPs: Set<String> = []
    @AppStorage("organizationId") private var organizationId: String = ""
    
    var body: some View {
           NavigationView {
               MainContentView(
                   viewModel: viewModel,
                   searchText: $searchText,
                   selectedSOPs: $selectedSOPs, showingUploadSheet: $showingUploadSheet
               )
               .navigationTitle("Template SOPs")
               .navigationBarItems(
                   leading: Button("Cancel") {
                       presentationMode.wrappedValue.dismiss()
                   },
                   trailing: Button("Done") {
                       selectedTemplates = viewModel.tempSOPs.filter { selectedSOPs.contains($0.id) }
                       presentationMode.wrappedValue.dismiss()
                   }
               )
               .onAppear {
                   Task {
                       await viewModel.fetchTempSOPs()
                   }
               }
           }
       }
}

// MARK: - Supporting Views
struct MainContentView: View {
    @ObservedObject var viewModel: TempSOPViewModel
    @Binding var searchText: String
    @Binding var selectedSOPs: Set<String>
    @Binding var showingUploadSheet: Bool
    
    var filteredCategories: [String] {
        if searchText.isEmpty {
            return Array(viewModel.categories).sorted()
        }
        return Array(viewModel.categories).filter { category in
            category.localizedCaseInsensitiveContains(searchText) ||
            viewModel.getSOPsByCategory(category).contains { sop in
                sop.name.localizedCaseInsensitiveContains(searchText) ||
                sop.description.localizedCaseInsensitiveContains(searchText)
            }
        }.sorted()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $searchText)
                .padding(.horizontal)
                .padding(.top, 8)
            
            if viewModel.isLoading {
                LoadingView()
            } else if filteredCategories.isEmpty {
                EmptyStateView()
            } else {
                TempCategoryListView(
                    viewModel: viewModel,
                    filteredCategories: filteredCategories,
                    searchText: searchText,
                    selectedSOPs: $selectedSOPs
                )
                
                if !selectedSOPs.isEmpty {
                    BottomActionBar(selectedCount: selectedSOPs.count) {
                        showingUploadSheet = true
                    }
                }
            }
        }
    }
}

struct TempCategoryListView: View {
    let viewModel: TempSOPViewModel
    let filteredCategories: [String]
    let searchText: String
    @Binding var selectedSOPs: Set<String>
    
    var body: some View {
        List {
            ForEach(filteredCategories, id: \.self) { category in
                CategorySection(
                    category: category,
                    viewModel: viewModel,
                    searchText: searchText,
                    selectedSOPs: $selectedSOPs
                )
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct CategorySection: View {
    let category: String
    let viewModel: TempSOPViewModel
    let searchText: String
    @Binding var selectedSOPs: Set<String>
    
    var body: some View {
        Section(header: CategoryHeaderView(category: category)) {
            ForEach(filteredSOPs) { sop in
                TempSOPRowView(sop: sop, isSelected: selectedSOPs.contains(sop.id))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggleSelection(sop)
                    }
            }
        }
    }
    
    private var filteredSOPs: [TempSOP] {
        viewModel.getSOPsByCategory(category)
            .filter {
                searchText.isEmpty ||
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
    }
    
    private func toggleSelection(_ sop: TempSOP) {
        if selectedSOPs.contains(sop.id) {
            selectedSOPs.remove(sop.id)
        } else {
            selectedSOPs.insert(sop.id)
        }
    }
}

struct LoadingView: View {
    var body: some View {
        ProgressView("Loading SOPs...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CancelButton: View {
    let presentationMode: Binding<PresentationMode>
    
    var body: some View {
        Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ClearButton: View {
    @Binding var selectedSOPs: Set<String>
    
    var body: some View {
        Group {
            if !selectedSOPs.isEmpty {
                Button("Clear") {
                    selectedSOPs.removeAll()
                }
            }
        }
    }
}

// Keep your existing SearchBar, CategoryHeaderView, TempSOPRowView,
// BottomActionBar, and EmptyStateView implementations

// Supporting Views
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search SOPs", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct CategoryHeaderView: View {
    let category: String
    
    var body: some View {
        HStack {
            Text(category)
                .font(.headline)
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct TempSOPRowView: View {
    let sop: TempSOP
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(sop.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(sop.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                Text(sop.subcategory)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
    }
}

struct BottomActionBar: View {
    let selectedCount: Int
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                Text("\(selectedCount) selected")
                    .font(.headline)
                Spacer()
                Button(action: action) {
                    Text("Upload Selected")
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No SOPs Found")
                .font(.headline)
            Text("Try adjusting your search or check back later")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


///


// Then create a new MultiTempSOPUploadView:
struct MultiTempSOPUploadView: View {
    let sops: [TempSOP]
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = PDFCategoryViewModel()
    @State private var selectedCategory: PDFCategory?
    @State private var showingCategoryPicker = false
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var isUploading = false
    @State private var uploadProgress: Double = 0
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Selected SOPs")) {
                        ForEach(sops) { sop in
                            VStack(alignment: .leading) {
                                Text(sop.name)
                                    .font(.headline)
                                Text(sop.subcategory)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Section(header: Text("Upload Destination")) {
                        Button(action: {
                            showingCategoryPicker = true
                        }) {
                            HStack {
                                Text("Select Category")
                                Spacer()
                                if let category = selectedCategory {
                                    Text("\(category.nameOfCategory) - \(category.SOPForStaffTittle)")
                                        .foregroundColor(.secondary)
                                }
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                if isUploading {
                    ProgressView("Uploading SOPs...", value: uploadProgress, total: 1.0)
                        .padding()
                }
                
                Button(action: uploadSOPs) {
                    Text("Upload SOPs")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedCategory != nil ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(selectedCategory == nil || isUploading)
                .padding()
            }
            .navigationTitle("Upload Template SOPs")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showingCategoryPicker) {
                            // Updated to use the renamed view
                            TempPDFCategoryPickerView(selectedCategory: $selectedCategory)
                        }
            .alert("Upload Status", isPresented: $showAlert) {
                Button("OK", role: .cancel) {
                    if !alertMessage.contains("Error") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func uploadSOPs() {
        guard let category = selectedCategory else { return }
        
        isUploading = true
        uploadProgress = 0
        
        Task {
            do {
                var successCount = 0
                for (index, sop) in sops.enumerated() {
                    do {
                        // Download the temp SOP
                        let storageRef = Storage.storage().reference(forURL: sop.fileURL)
                        let data = try await storageRef.data(maxSize: 50 * 1024 * 1024)
                        
                        // Create new PDFCategory for upload
                        let newCategory = PDFCategory(
                            id: UUID().uuidString,
                            nameOfCategory: category.nameOfCategory,
                            SOPForStaffTittle: category.SOPForStaffTittle,
                            pdfName: sop.name,
                            pdfURL: nil,
                            organizationId: category.organizationId
                        )
                        
                        // Upload to new location
                        _ = try await PDFStorageManager.shared.uploadPDF(data: data, category: newCategory)
                        successCount += 1
                        
                        await MainActor.run {
                            uploadProgress = Double(index + 1) / Double(sops.count)
                        }
                    } catch {
                        print("Error uploading \(sop.name): \(error.localizedDescription)")
                    }
                }
                
                await MainActor.run {
                    isUploading = false
                    alertMessage = "\(successCount) of \(sops.count) SOPs uploaded successfully"
                    showAlert = true
                }
            } catch {
                await MainActor.run {
                    isUploading = false
                    alertMessage = "Error: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}
    ///
import SwiftUI

struct TempPDFCategoryPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = PDFCategoryViewModel()
    @Binding var selectedCategory: PDFCategory?
    
    var body: some View {
        NavigationView {
            TempCategoryPickerContent(
                viewModel: viewModel,
                selectedCategory: $selectedCategory,
                presentationMode: presentationMode // Pass the wrapped value
            )
            .navigationTitle("Select Category")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .onAppear {
            Task {
                await viewModel.fetchCategories()
            }
        }
    }
}

// MARK: - Supporting Views
private struct TempCategoryPickerContent: View {
    @ObservedObject var viewModel: PDFCategoryViewModel
    @Binding var selectedCategory: PDFCategory?
    let presentationMode: Binding<PresentationMode>
    
    var body: some View {
        List {
            ForEach(viewModel.uniqueCategories, id: \.self) { category in
                TempCategoryPickerSection(
                    category: category,
                    viewModel: viewModel,
                    selectedCategory: $selectedCategory,
                    presentationMode: presentationMode
                )
            }
        }
    }
}


private struct TempCategoryPickerSection: View {
    let category: String
    let viewModel: PDFCategoryViewModel
    @Binding var selectedCategory: PDFCategory?
    let presentationMode: Binding<PresentationMode> // Change to Binding
    
    var body: some View {
        Section(header: Text(category)) {
            ForEach(filteredCategories) { pdfCategory in
                TempCategoryPickerRow(
                    pdfCategory: pdfCategory,
                    isSelected: selectedCategory?.id == pdfCategory.id,
                    action: {
                        selectedCategory = pdfCategory
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
    
    private var filteredCategories: [PDFCategory] {
        viewModel.pdfCategories.filter { $0.nameOfCategory == category }
    }
}

private struct TempCategoryPickerRow: View {
    let pdfCategory: PDFCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(pdfCategory.nameOfCategory)
                        .font(.headline)
                    Text(pdfCategory.SOPForStaffTittle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
        .foregroundColor(.primary)
    }
}

