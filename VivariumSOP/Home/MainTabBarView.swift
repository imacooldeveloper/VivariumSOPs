//
//  MainTabBarView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/2/24.
//

import SwiftUI


struct MainTabBarView: View {
   
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
        }
    }
}

class NavigationHandler: ObservableObject {
    @Published var path = NavigationPath()
    @Published var selectedQuizWithScore: QuizWithScore?
}
