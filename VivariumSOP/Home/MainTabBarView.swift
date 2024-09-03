//
//  MainTabBarView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/2/24.
//

import SwiftUI

struct MainTabBarView: View {
    var body: some View {
        NavigationStack{
            
          //  PDFUploadView()
            PDFCategoryListView()
               .navigationTitle("Upload PDFs")
        }
    }
}

#Preview {
    MainTabBarView()
}
class NavigationHandler: ObservableObject {
    @Published var path = NavigationPath()
    @Published var selectedQuizWithScore: QuizWithScore?
}
