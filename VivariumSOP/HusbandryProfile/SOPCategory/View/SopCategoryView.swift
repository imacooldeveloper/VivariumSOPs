//
//  SopCategoryView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/28/24.
//

import SwiftUI


struct SOPCategoryView: View {
    @EnvironmentObject var service: SOPService
    @StateObject var vm = SOPCategoryViewModel()
    
    let columns = [
           GridItem(.flexible(), spacing: 20),
           GridItem(.flexible(), spacing: 20)
       ]
    var body: some View {
       
            ScrollView{
                LazyVGrid(columns: columns, spacing: 20){
                   
                    
                        ForEach(vm.categoryList, id:\.self){ category in
                            NavigationLink(value: category) {
                                CategoryListView(imageName: "person", categoryName: category.categoryTitle)
                                
        //                        CategoryRowView(category: category)
                            }
                            .buttonStyle(.plain)
                          
                        }
                      
                    
                    .padding()
                }
            }
            .navigationTitle("Categorys")
            .onAppear{
                Task{
                    do {
                     //try await vm.postFakePDF()
                     try await vm.fecthCagetoryList()
                     //   await fetchQuizzesAndScheduleNotifications()
                    } catch {
                        print("err")
                    }
                      
                }
               
            }
    }
    
//    @MainActor
//    func fetchQuizzesAndScheduleNotifications() async {
//        do {
//            let quizzes = try await QuizManager.shared.getAllQuiz()
//            let notificationsManager = NotificationsManager()
//
//            for quiz in quizzes {
//                notificationsManager.scheduleNotification(forQuiz: quiz, daysBefore: 15, title: quiz.quizCategory, body: quiz.info.title)
//            }
//        } catch {
//            print("Error fetching quizzes: \(error.localizedDescription)")
//        }
//    }
}
struct SopCategoryListView: View {
    var imageName: String
    var categoryName: String
    var sopPages: String
    
    var body: some View {
        HStack(spacing: 16) {
            CategoryIcon(name: imageName)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(categoryName)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                
                Text("\(sopPages) SOPs")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct CategoryIcon: View {
    var name: String
    
    var body: some View {
        Image(systemName: iconName(for: name))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .padding(10)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(10)
    }
    
    func iconName(for category: String) -> String {
        switch category.lowercased() {
        case "mouse": return "pawprint.fill"
        case "medical": return "cross.case.fill"
        case "safety": return "shield.fill"
        case "training": return "book.fill"
        default: return "folder.fill"
        }
    }
}
struct CategoryListView: View {
    @State var imageName: String
    @State var categoryName: String
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .foregroundColor(.cyan)
                    )
                Spacer()
                Image(systemName: "ellipsis")
                    .foregroundColor(.black)
                    .font(.title)
                    .padding(.top, -30)
            }
            .padding([.leading, .trailing, .top])
            
            Text(categoryName)
                .bold()
                .font(.title2)
                .padding([.leading, .bottom], 10)
            
            Text("")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding([.leading, .bottom], 10)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .foregroundColor(.blue.opacity(0.2))
        )
        .padding()
    }
}
struct SOPCategoryListView: View {
    @EnvironmentObject var service: SOPService
    @ObservedObject var vm = SOPCategoryListViewModel()
    
    var catagoryType: String
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(vm.SOPCategoryList) { sopCategory in
                                   NavigationLink(value: sopCategory) {
                                       SopCategoryListView(
                                           imageName: "mouse", // You might want to use a different icon based on the category
                                           categoryName: sopCategory.SOPForStaffTittle,
                                           sopPages: sopCategory.sopPages ?? "0"
                                       )
                                   }
                                   .buttonStyle(PlainButtonStyle())
                               }
                           }
                           .padding(.vertical)
                       }
                       .background(Color(.systemGroupedBackground))
                       .onAppear {
                           Task {
                               print(catagoryType)
                               try await vm.fecthSOPCategoryList(category: catagoryType)
                           }
                       }
                       .navigationTitle("Categories")
                   }
               }


final class SOPCategoryListViewModel: ObservableObject {
    @Published var SOPCategoryList: [SOPCategory] = []
    
    var sopService: SOPService?
    @MainActor
    func fecthSOPCategoryList(category: String) async throws {
        do {
         
            SOPCategoryList = try await CategoryManager.shared.getCategoryList(title: category)
           // sopService?.nameOFCategory = category
            
        } catch {
            print("error")
        }
    }
}
