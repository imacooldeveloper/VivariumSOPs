//
//  MainTabBarView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/2/24.
//

import SwiftUI

struct MainTabBarView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    @StateObject private var navigationHandler = NavigationHandler()
    @State private var selectedTab = 0
    @AppStorage("account_Type") var userAccountType: String = ""
    @StateObject private var notificationManager = NotificationManager.shared
    @EnvironmentObject var sharedViewModel: PDFCategoryViewModel
        
    var body: some View {
        if userAccountType.lowercased() == "husbandry" {
            // Husbandry user view - existing code
            NavigationStack {
                TabView(selection: $selectedTab) {
                    HusbandryUserProfileView()
                        .tabItem {
                            Label("Home", systemImage: "person.circle.fill")
                        }
                        .tag(0)
                    
                    SopSearchView()
                        .navigationTitle("Search")
                        .tabItem {
                            Label("Search", systemImage: "doc.text.magnifyingglass")
                        }
                        .tag(1)
                    
                    SOPCategoryView()
                        .navigationTitle("Folder")
                        .tabItem {
                            Label("Folder", systemImage: "folder.fill")
                        }
                        .tag(2)
                }
                .onAppear {
                    Task {
                        await MainActor.run {
                            notificationManager.requestAuthorization()
                        }
                    }
                }
                
                // Your existing navigation destinations
                .navigationDestination(for: Categorys.self) { category in
                    SOPCategoryListView(catagoryType: category.categoryTitle)
                }
                .navigationDestination(for: SOPCategory.self) { category in
                    HusbandryPDFListView(SOPForStaffTittle: category.SOPForStaffTittle, nameOfCategory: category.nameOfCategory)
                }
                .navigationDestination(for: PDFCategory.self) { pdf in
                    PDFDetailsView(pdfDocument: pdf, vm: PDFViewModel(sopcategory: pdf.SOPForStaffTittle, category: pdf.nameOfCategory, sopName: pdf.pdfName, pdfName: pdf.pdfName))
                }
                .navigationDestination(for: QuizWithScore.self) { quiz in
                    HusbandryQuestionView(quizId: quiz.quiz.id, quizTitle: quiz.quiz.info.title) {
                        navigationHandler.selectedQuizWithScore = nil
                    }
                }
                .navigationDestination(for: Quiz.self) { quiz in
                    HusbandryQuestionView(quizId: quiz.id, quizTitle: quiz.info.title) {
                        navigationHandler.selectedQuizWithScore = nil
                    }
                }
                .navigationDestination(for: User.self) { user in
                    HusbandryUserProfileView(userSelected: user)
                }
                .navigationDestination(for: HusbandryPDFListView.self) { view in
                    view
                }
                .navigationBarItems(trailing: signOutButton)
            }
        } else {
            // Admin and other users - Move Home tab to the end for admin users
            TabView(selection: $selectedTab) {
                // Original admin tabs - Now Home is not the first tab
                NavigationStack(path: $navigationHandler.path) {
                    PDFCategoryListView()
                        .environmentObject(sharedViewModel)
                        .navigationTitle("Upload PDFs")
                        .navigationDestination(for: User.self) { user in
                            UserProfileView(userSelected: user)
                        }
                }
                .tabItem {
                    Label("Upload", systemImage: "arrow.up.doc.fill")
                }
                .tag(0)
                
                NavigationStack(path: $navigationHandler.path) {
                    QuizListView(viewModel: QuizListViewModel())
                        .navigationTitle("Quizzes")
                        .navigationDestination(for: User.self) { user in
                            UserProfileView(userSelected: user)
                        }
                }
                .tabItem {
                    Label("Quizzes", systemImage: "list.bullet.clipboard.fill")
                }
                .tag(1)
                
                NavigationStack(path: $navigationHandler.path) {
                    Home()
                        .navigationTitle("User Management")
                        .navigationDestination(for: User.self) { user in
                            UserProfileView(userSelected: user)
                        }
                }
                .tabItem {
                    Label("Users", systemImage: "person.3.fill")
                }
                .tag(2)
                
                NavigationStack(path: $navigationHandler.path) {
                    ExportAllUsersView()
                        .navigationTitle("Export Quiz Data")
                }
                .tabItem {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .tag(3)
                
                // Only show the Home tab for admins - Now at the end
                if userAccountType.lowercased() == "admin" {
                    NavigationStack(path: $navigationHandler.path) {
                        HusbandryUserProfileView()
                            .navigationTitle("My Quizzes")
                            // Include ALL necessary navigation destinations here
                            .navigationDestination(for: User.self) { user in
                                UserProfileView(userSelected: user)
                            }
                            .navigationDestination(for: Quiz.self) { quiz in
                                HusbandryQuestionView(quizId: quiz.id, quizTitle: quiz.info.title) {
                                    navigationHandler.selectedQuizWithScore = nil
                                }
                            }
                            .navigationDestination(for: QuizWithScore.self) { quiz in
                                HusbandryQuestionView(quizId: quiz.quiz.id, quizTitle: quiz.quiz.info.title) {
                                    navigationHandler.selectedQuizWithScore = nil
                                }
                            }
                            .navigationDestination(for: Categorys.self) { category in
                                SOPCategoryListView(catagoryType: category.categoryTitle)
                            }
                            .navigationDestination(for: SOPCategory.self) { category in
                                HusbandryPDFListView(SOPForStaffTittle: category.SOPForStaffTittle, nameOfCategory: category.nameOfCategory)
                            }
                            .navigationDestination(for: PDFCategory.self) { pdf in
                                PDFDetailsView(pdfDocument: pdf, vm: PDFViewModel(sopcategory: pdf.SOPForStaffTittle, category: pdf.nameOfCategory, sopName: pdf.pdfName, pdfName: pdf.pdfName))
                            }
                            .navigationDestination(for: HusbandryPDFListView.self) { view in
                                view
                            }
                    }
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(4)
                }
            }
            .onChange(of: selectedTab) { _ in
                navigationHandler.path.removeLast(navigationHandler.path.count)
            }
            .onAppear {
                Task {
                    await MainActor.run {
                        notificationManager.requestAuthorization()
                    }
                }
            }
        }
    }
   
    private var signOutButton: some View {
        Button(action: {
            loginViewModel.logOutUser()
        }) {
            Text("Sign Out")
        }
    }
}

class NavigationHandler: ObservableObject {
    @Published var path = NavigationPath()
    @Published var selectedQuizWithScore: QuizWithScore?
}
