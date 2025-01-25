//
//  CardGroupView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/25/24.
//

//
//  CardGroupView.swift
//  SOPProject
//
//  Created by Martin Gallardo on 7/26/24.
//

import SwiftUI

/// working
//struct Home: View {
//    @StateObject var quizVM = UserProfileViewModel()
//    @StateObject var userVM = UserViewModel()
//    @StateObject var sopCategoryModel = SOPCategoryViewModel()
//
//    @State private var searchText: String = ""
//    @FocusState private var isSearching: Bool
//    @State private var activeTab: Tab = .users
//    @Environment(\.colorScheme) private var scheme
//    @Namespace private var animation
//
//    var body: some View {
//
//            ScrollView(.vertical) {
//                LazyVStack(spacing: 15) {
//                    if activeTab == .users {
//                        ForEach(searchResults(quizVM.userss), id: \.id) { user in
//                            NavigationLink(value: user){
//                           // Define the destination view
//                                UserRow(user: user)
//                            }
//                        }
//                    }
////                    else if activeTab == .categories {
////                        ForEach(sopCategoryModel.categoryList, id: \.id) { category in
////                           // CategoryRow(category: category)
////                        }
////                    }
//                }
//                .padding(.horizontal, 15)
//                .safeAreaInset(edge: .top, spacing: 0) {
//                    ExpandableNavigationBar("Browse Data")
//                }
//                .animation(.snappy(duration: 0.3, extraBounce: 0), value: isSearching)
//            }
//            .background(.gray.opacity(0.15))
//            .contentMargins(.top, 190, for: .scrollIndicators)
//            .onAppear {
//                Task {
//                    do {
//                        try await quizVM.fecthAllUser()
//
//
//                        await quizVM.fetchCompletedQuizzesAndScoresForAllUsers()
//
//                      //  try await sopCategoryModel.fecthCagetoryList()
//
////                        try await userVM.fecthAllUser()
////                        try await sopCategoryModel.fecthCagetoryList()
//                    } catch {
//                        print("Error fetching data: \(error)")
//                    }
//                }
//            }
//            .navigationTitle("Home")
//            .navigationBarTitleDisplayMode(.inline)
//
//    }
//
//    @ViewBuilder
//    func UserRow(user: User) -> some View {
//        //        VStack {
//        //            Text(user.username)
//        //                .padding()
//        //                .background(Color.white)
//        //                .cornerRadius(10)
//        //                .shadow(radius: 3)
//        //
//        //            if user.quizScores?.isEmpty {
//        //                Text("No completed quizzes")
//        //                    .foregroundColor(.red)
//        //            } else {
//        //                ForEach(user.quizScores, id: \.quizID) { score in
//        //                    HStack {
//        //                        Text("Quiz ID: \(score.quizID)")
//        //                        Spacer()
//        //                        Text("\(score.scores[0])%")
//        //                            .foregroundColor(score.scores[0] >= 80 ? .green : .red)
//        //                    }
//        //                    .padding()
//        //                }
//        //            }
//        //        }
//
//        ManagementUserViewListView(user: user, allQuizzes: quizVM.completedQuizzes + quizVM.uncompletedQuizzes)
//
//
//    }
//
//    @ViewBuilder
//    func CategoryRow(category: Category) -> some View {
//        Text(category.categoryTitle)
//            .padding()
//            .background(Color.white)
//            .cornerRadius(10)
//            .shadow(radius: 3)
//    }
//
//    private func searchResults<T: Identifiable>(_ items: [T]) -> [T] {
//        if searchText.isEmpty {
//            return items
//        } else {
//            return items.filter { item in
//                if let user = item as? User {
//                    return user.username.localizedCaseInsensitiveContains(searchText)
//                }
//                return false
//            }
//        }
//    }
//
//    @ViewBuilder
//    func ExpandableNavigationBar(_ title: String = "Messages") -> some View {
//        GeometryReader { proxy in
//            let minY = proxy.frame(in: .scrollView).minY
//            let scrollviewHeight = proxy.size.height
//            let scaleProgress = minY > 0 ? 1 + (minY / scrollviewHeight * 0.5) : 1
//            let progress = isSearching ? 1 : max(min(-minY / 70, 1), 0)
//
//            VStack(spacing: 10) {
//                Text(title)
//                    .font(.largeTitle.bold())
//                    .scaleEffect(scaleProgress, anchor: .topLeading)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.bottom, 10)
//
//                HStack(spacing: 12) {
//                    Image(systemName: "magnifyingglass")
//                        .font(.title3)
//
//                    TextField("Search Conversations", text: $searchText)
//                        .focused($isSearching)
//
//                    if isSearching {
//                        Button(action: {
//                            isSearching = false
//                        }) {
//                            Image(systemName: "xmark")
//                                .font(.title3)
//                        }
//                        .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
//                    }
//                }
//                .foregroundColor(.primary)
//                .padding(.vertical, 10)
//                .padding(.horizontal, 15 - (progress * 15))
//                .frame(height: 45)
//                .background {
//                    RoundedRectangle(cornerRadius: 25 - (progress * 25))
//                        .fill(Color.white)
//                        .shadow(color: .gray.opacity(0.25), radius: 5, x: 0, y: 5)
//                        .padding(.top, -progress * 190)
//                        .padding(.bottom, -progress * 65)
//                        .padding(.horizontal, -progress * 15)
//                }
//
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 12) {
//                        ForEach(Tab.allCases, id: \.rawValue) { tab in
//                            Button(action: {
//                                withAnimation(.snappy) {
//                                    activeTab = tab
//                                }
//                            }) {
//                                Text(tab.rawValue)
//                                    .font(.callout)
//                                    .foregroundColor(activeTab == tab ? .white : .primary)
//                                    .padding(.vertical, 8)
//                                    .padding(.horizontal, 15)
//                                    .background {
//                                        Capsule()
//                                            .fill(activeTab == tab ? Color.blue : Color.gray.opacity(0.3))
//                                            .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
//                                    }
//                            }
//                            .buttonStyle(.plain)
//                        }
//                    }
//                }
//                .frame(height: 50)
//            }
//            .padding(.top, 25)
//            .padding(.horizontal, 15)
//            .offset(y: minY < 0 || isSearching ? -minY : 0)
//            .offset(y: -progress * 65)
//        }
//        .frame(height: 190)
//        .padding(.bottom, 10)
//        .padding(.bottom, isSearching ? -65 : 0)
//    }
//}
//
//struct CustomScrollTargetBehaviour: ScrollTargetBehavior {
//    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
//        if target.rect.minY < 70 {
//            target.rect.origin.y = target.rect.minY < 35 ? 0 : 70
//        }
//    }
//}
//
//enum Tab: String, CaseIterable {
//    case users = "Users"
//    //case categories = "Categories"
//}
/// Make a user model here
/// i need to pull down the user

///Working

//struct Home: View {
//    @StateObject var viewModel = ManagementUserViewModel()
//    @State private var searchText: String = ""
//    @FocusState private var isSearching: Bool
//    @State private var activeTab: Tab = .users
//    @Namespace private var animation
//
//    var body: some View {
//        ScrollView(.vertical) {
//            LazyVStack(spacing: 15) {
//                if activeTab == .users {
//                    ForEach(searchResults(viewModel.users), id: \.id) { user in
//                        NavigationLink(value: user) {
//                            UserRow(user: user)
//                        }
//                    }
//                }
//            }
//            .padding(.horizontal, 15)
//            .safeAreaInset(edge: .top, spacing: 0) {
//                ExpandableNavigationBar("Browse Data")
//            }
//            .animation(.snappy(duration: 0.3, extraBounce: 0), value: isSearching)
//        }
//        .background(.gray.opacity(0.15))
//        .contentMargins(.top, 190, for: .scrollIndicators)
//        .task {
//            await viewModel.fetchAllUsersAndQuizzes()
//        }
//        .navigationTitle("Home")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//
//    @ViewBuilder
//    func UserRow(user: User) -> some View {
//        ManagementUserViewListView(user: user, allQuizzes: viewModel.quizzes)
//    }
//
//    private func searchResults<T: Identifiable>(_ items: [T]) -> [T] {
//        if searchText.isEmpty {
//            return items
//        } else {
//            return items.filter { item in
//                if let user = item as? User {
//                    return user.username.localizedCaseInsensitiveContains(searchText)
//                }
//                return false
//            }
//        }
//    }
//
//    @ViewBuilder
//    func ExpandableNavigationBar(_ title: String = "Messages") -> some View {
//        GeometryReader { proxy in
//            let minY = proxy.frame(in: .scrollView).minY
//            let scrollviewHeight = proxy.size.height
//            let scaleProgress = minY > 0 ? 1 + (minY / scrollviewHeight * 0.5) : 1
//            let progress = isSearching ? 1 : max(min(-minY / 70, 1), 0)
//
//            VStack(spacing: 10) {
//                Text(title)
//                    .font(.largeTitle.bold())
//                    .scaleEffect(scaleProgress, anchor: .topLeading)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.bottom, 10)
//
//                HStack(spacing: 12) {
//                    Image(systemName: "magnifyingglass")
//                        .font(.title3)
//
//                    TextField("Search Conversations", text: $searchText)
//                        .focused($isSearching)
//
//                    if isSearching {
//                        Button(action: {
//                            isSearching = false
//                        }) {
//                            Image(systemName: "xmark")
//                                .font(.title3)
//                        }
//                        .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
//                    }
//                }
//                .foregroundColor(.primary)
//                .padding(.vertical, 10)
//                .padding(.horizontal, 15 - (progress * 15))
//                .frame(height: 45)
//                .background {
//                    RoundedRectangle(cornerRadius: 25 - (progress * 25))
//                        .fill(Color.white)
//                        .shadow(color: .gray.opacity(0.25), radius: 5, x: 0, y: 5)
//                        .padding(.top, -progress * 190)
//                        .padding(.bottom, -progress * 65)
//                        .padding(.horizontal, -progress * 15)
//                }
//
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 12) {
//                        ForEach(Tab.allCases, id: \.rawValue) { tab in
//                            Button(action: {
//                                withAnimation(.snappy) {
//                                    activeTab = tab
//                                }
//                            }) {
//                                Text(tab.rawValue)
//                                    .font(.callout)
//                                    .foregroundColor(activeTab == tab ? .white : .primary)
//                                    .padding(.vertical, 8)
//                                    .padding(.horizontal, 15)
//                                    .background {
//                                        Capsule()
//                                            .fill(activeTab == tab ? Color.blue : Color.gray.opacity(0.3))
//                                            .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
//                                    }
//                            }
//                            .buttonStyle(.plain)
//                        }
//                    }
//                }
//                .frame(height: 50)
//            }
//            .padding(.top, 25)
//            .padding(.horizontal, 15)
//            .offset(y: minY < 0 || isSearching ? -minY : 0)
//            .offset(y: -progress * 65)
//        }
//        .frame(height: 190)
//        .padding(.bottom, 10)
//        .padding(.bottom, isSearching ? -65 : 0)
//    }
//}


struct Home: View {
    @StateObject var viewModel = ManagementUserViewModel()
    @State private var searchText: String = ""
    @State private var selectedFloor: String = "All Floors"
    @FocusState private var isSearching: Bool
    @State private var activeTab: Tab = .users
    @Namespace private var animation

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 15) {
                if activeTab == .users {
                    ForEach(searchResults(viewModel.users), id: \.userUID) { user in
                        NavigationLink(value: user) {
                            UserRow(user: user)
                        }
                    }
                }
            }
            .padding(.horizontal, 15)
            .safeAreaInset(edge: .top, spacing: 0) {
                ExpandableNavigationBar("Browse Data")
            }
            .animation(.snappy(duration: 0.3, extraBounce: 0), value: isSearching)
        }
        .background(.gray.opacity(0.15))
        .contentMargins(.top, 190, for: .scrollIndicators)
        .task {
            await viewModel.fetchAllUsersAndQuizzes()
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    func UserRow(user: User) -> some View {
        ManagementUserViewListView(user: user, allQuizzes: viewModel.quizzes)
    }

//    private func searchResults<T: Identifiable>(_ items: [T]) -> [T] {
//        let filteredItems: [T] = {
//            if let users = items as? [User] {
//                // First filter by organization
//                let orgUsers = users.filter { user in
//                    user.organizationId == viewModel.organizationId
//                }
//                
//                // Then filter by floor if needed
//                if selectedFloor == "All Floors" {
//                    return orgUsers as! [T]
//                } else {
//                    return orgUsers.filter { user in
//                        user.floor == selectedFloor
//                    } as! [T]
//                }
//            }
//            return items
//        }()
//        
//        // Then apply search text filter
//        if searchText.isEmpty {
//            return filteredItems
//        } else {
//            return filteredItems.filter { item in
//                if let user = item as? User {
//                    return user.username.localizedCaseInsensitiveContains(searchText)
//                }
//                return false
//            }
//        }
//    }
    private func searchResults<T: Identifiable>(_ items: [T]) -> [T] {
        let filteredItems: [T] = {
            if let users = items as? [User] {
                // First filter by organization
                let orgUsers = users.filter { user in
                    user.organizationId == viewModel.organizationId
                }
                
                // Then filter by floor if needed
                if selectedFloor == "All Floors" {
                    return orgUsers as! [T]
                } else {
                    return orgUsers.filter { user in
                        // Check both old floor field and new assignedFloors array
                        return user.floor == selectedFloor ||
                               (user.assignedFloors?.contains(selectedFloor) ?? false)
                    } as! [T]
                }
            }
            return items
        }()
        
        if searchText.isEmpty {
            return filteredItems
        } else {
            return filteredItems.filter { item in
                if let user = item as? User {
                    return user.username.localizedCaseInsensitiveContains(searchText)
                }
                return false
            }
        }
    }
    
    @ViewBuilder
    func ExpandableNavigationBar(_ title: String = "Messages") -> some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .scrollView).minY
            let scrollviewHeight = proxy.size.height
            let scaleProgress = minY > 0 ? 1 + (minY / scrollviewHeight * 0.5) : 1
            let progress = isSearching ? 1 : max(min(-minY / 70, 1), 0)

            VStack(spacing: 10) {
                Text(title)
                    .font(.largeTitle.bold())
                    .scaleEffect(scaleProgress, anchor: .topLeading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)

                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.title3)

                    TextField("Search Users", text: $searchText)
                        .focused($isSearching)

                    if isSearching {
                        Button(action: {
                            isSearching = false
                        }) {
                            Image(systemName: "xmark")
                                .font(.title3)
                        }
                        .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
                    }
                }
                .foregroundColor(.primary)
                .padding(.vertical, 10)
                .padding(.horizontal, 15 - (progress * 15))
                .frame(height: 45)
                .background {
                    RoundedRectangle(cornerRadius: 25 - (progress * 25))
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.25), radius: 5, x: 0, y: 5)
                        .padding(.top, -progress * 190)
                        .padding(.bottom, -progress * 65)
                        .padding(.horizontal, -progress * 15)
                }

                Picker("Select Floor", selection: $selectedFloor) {
                    Text("All Floors").tag("All Floors")
                    Text("1st").tag("1st")
                    Text("2nd").tag("2nd")
                    Text("3rd").tag("3rd")
                    Text("3rd Annex Sattelites").tag("3rd Annex Sattelites")
                    Text("4th SPF").tag("4th SPF")
                    Text("4th Core").tag("4th Core")
                    Text("5th").tag("5th")
                    // Add more floors as needed
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Tab.allCases, id: \.rawValue) { tab in
                            Button(action: {
                                withAnimation(.snappy) {
                                    activeTab = tab
                                }
                            }) {
//                                Text(tab.rawValue)
//                                    .font(.callout)
//                                    .foregroundColor(activeTab == tab ? .white : .primary)
//                                    .padding(.vertical, 8)
//                                    .padding(.horizontal, 15)
//                                    .padding()
//                                    .background {
//                                        Capsule()
//                                            .fill(activeTab == tab ? Color.blue : Color.gray.opacity(0.3))
//                                            .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
//                                    }
                                  
                            }
                            //.buttonStyle(.plain)
                        }
                    }
                }
                .frame(height: 50)
            }
            .padding(.top, 25)
            .padding(.horizontal, 15)
            .offset(y: minY < 0 || isSearching ? -minY : 0)
            .offset(y: -progress * 65)
        }
        .frame(height: 190)
        .padding(.bottom, 10)
        .padding(.bottom, isSearching ? -65 : 0)
    }
}

enum Tab: String, CaseIterable {
    case users = "Users"
    //case floors = "Floors" // Added floor tab
}

