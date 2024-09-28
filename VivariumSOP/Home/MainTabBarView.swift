//
//  MainTabBarView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/2/24.
//

import SwiftUI


//struct MainTabBarView: View {
//    @StateObject private var loginViewModel = LoginViewModel()
//    var body: some View {
//        TabView {
//            NavigationStack {
//                PDFCategoryListView()
//                    .navigationTitle("Upload PDFs")
//            }
//            .tabItem {
//                Label("Upload", systemImage: "arrow.up.doc.fill")
//            }
//            
//            NavigationStack {
//                QuizListView(viewModel: QuizListViewModel())
//                    .navigationTitle("Quizzes")
//            }
//           
//            .tabItem {
//                Label("Home", systemImage: "list.bullet.clipboard.fill")
//            }
//            
//            NavigationStack {
//                Home()
//                    .navigationTitle("Quizzes")
//            }
//           
//            .tabItem {
//                Label("Quizzes", systemImage: "list.bullet.clipboard.fill")
//            }
//            
//          //  .navigationBarItems(trailing: signOutButton)
//        }
//        .navigationDestination(for: User.self) { user in
//            
//            UserProfileView(userSelected: user)
//        }
//    }
//    
//    
//    private var signOutButton: some View {
//           Button(action: {
//               loginViewModel.logOutUser()
//           }) {
//               Text("Sign Out")
//           }
//       }
//}


///working before the number tab
//struct MainTabBarView: View {
//    @StateObject private var loginViewModel = LoginViewModel()
//    @StateObject private var navigationHandler = NavigationHandler()
//
//    var body: some View {
//        TabView {
//            NavigationStack(path: $navigationHandler.path) {
//                PDFCategoryListView()
//                    .navigationTitle("Upload PDFs")
////                    .toolbar {
////                        ToolbarItem(placement: .navigationBarTrailing) {
////                            signOutButton
////                        }
////                    }
//                    .navigationDestination(for: User.self) { user in
//                        UserProfileView(userSelected: user)
//                    }
//            }
//            .tabItem {
//                Label("Upload", systemImage: "arrow.up.doc.fill")
//            }
//            
//            NavigationStack(path: $navigationHandler.path) {
//                QuizListView(viewModel: QuizListViewModel())
//                    .navigationTitle("Quizzes")
////                    .toolbar {
////                        ToolbarItem(placement: .navigationBarTrailing) {
////                            signOutButton
////                        }
////                    }
//                    .navigationDestination(for: User.self) { user in
//                        UserProfileView(userSelected: user)
//                    }
//            }
//            .tabItem {
//                Label("Quizzes", systemImage: "list.bullet.clipboard.fill")
//            }
//            
//            NavigationStack(path: $navigationHandler.path) {
//                Home()
//                    .navigationTitle("User Management")
////                    .toolbar {
////                        ToolbarItem(placement: .navigationBarTrailing) {
////                            signOutButton
////                        }
////                    }
//                    .navigationDestination(for: User.self) { user in
//                        UserProfileView(userSelected: user)
//                    }
//            }
//            .tabItem {
//                Label("Users", systemImage: "person.3.fill")
//            }
//        }
//    }
//    
//    private var signOutButton: some View {
//        Button(action: {
//            loginViewModel.logOutUser()
//        }) {
//            Text("Sign Out")
//        }
//    }
//}

struct MainTabBarView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    @StateObject private var navigationHandler = NavigationHandler()
    @State private var selectedTab = 0

    var body: some View {
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
        }
        .onChange(of: selectedTab) { _ in
            navigationHandler.path.removeLast(navigationHandler.path.count)
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
