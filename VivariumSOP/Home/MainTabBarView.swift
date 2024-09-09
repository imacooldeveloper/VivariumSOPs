//
//  MainTabBarView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/2/24.
//

import SwiftUI


struct MainTabBarView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    var body: some View {
        TabView {
            NavigationStack {
                PDFCategoryListView()
                    .navigationTitle("Upload PDFs")
            }
            .tabItem {
                Label("Upload", systemImage: "arrow.up.doc.fill")
            }
            
            NavigationStack {
                QuizListView(viewModel: QuizListViewModel())
                    .navigationTitle("Quizzes")
            }
           
            .tabItem {
                Label("Quizzes", systemImage: "list.bullet.clipboard.fill")
            }
          //  .navigationBarItems(trailing: signOutButton)
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
