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
    @StateObject private var notificationManager = NotificationManager.shared  // Add this line
        
    var body: some View {
        
        if userAccountType.lowercased() != "husbandry"  {
            
            TabView(selection: $selectedTab) {
                NavigationStack(path: $navigationHandler.path) {
                    PDFCategoryListView()
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
                
               // NavigationStack {
//                    BuildingManagementView()
//                        .navigationTitle("Buildings")
//                        .navigationDestination(for: Building.self) { building in
//                           BuildingDetailView( building: building)
//                        }
//                }
//                .tabItem {
//                    Label("Buildings", systemImage: "building.2")  // Changed icon and label
//                }
//                .tag(4)
                
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
           
        } else {
            NavigationStack {
                TabView(selection: $selectedTab) {
                    
                    HusbandryUserProfileView()
                        .tabItem {
                            Label("Home", systemImage: "person.circle.fill")
                        }
                        .tag(0)
                    
//
//                    
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
