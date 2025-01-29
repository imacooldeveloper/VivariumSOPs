//
//  UserProfileView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/25/24.
//

//
//  UserProfileView.swift
//  SOPProject
//
//  Created by Martin Gallardo on 1/22/24.
//

import SwiftUI


struct UserProfileView: View {
    @EnvironmentObject var navigationHandler: NavigationHandler
    @ObservedObject var viewModel = UserProfileViewModel()
    @State private var batteryLevel: Double = 60
    var userSelected: User?
    let columns = [
        GridItem(.flexible(minimum: 100, maximum: .infinity))
    ]
   
    var body: some View {
        UserProfileContentView(viewModel: viewModel)
                 .onAppear {
                     Task {
                         if let selectedUser = userSelected {
                             viewModel.loadUser(selectedUser)
                         } else {
                             await viewModel.fetchCurrentUser()
                         }
                         await viewModel.fetchUserQuizzes()
                     }
                 }
       }
   

    private func gaugeColorForScore(_ score: CGFloat) -> Color {
        switch score {
        case 75...100:
            return .green
        case 50..<75:
            return .yellow
        default:
            return .red
        }
    }
}


//
//struct UserProfileContentView: View {
//    var user: User?
//    @ObservedObject var viewModel: UserProfileViewModel
//    @State private var selectedDates: [String: Date] = [:]
//    @State private var quizToRetake: Quiz?
//   // @State private var isRefreshing = false
//    
//    @State private var refreshID = UUID()
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                // Profile Header
//                VStack(spacing: 10) {
//                    Image(systemName: "person.circle.fill")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 100, height: 100)
//                        .foregroundColor(.blue)
//                    
//                    Text(viewModel.user?.username ?? "")
//                        .font(.title)
//                        .fontWeight(.bold)
//                }
//                .padding()
//                
//                // Completed Quizzes
//                VStack(alignment: .leading, spacing: 10) {
//                    Text("Completed Quizzes")
//                        .font(.headline)
//                        .padding(.horizontal)
//                    
//                    if viewModel.quizzesWithScores.filter({ $0.score >= 80 }).isEmpty {
//                        Text("No completed quizzes yet.")
//                            .foregroundColor(.secondary)
//                            .padding(.horizontal)
//                    } else {
//                        ForEach(viewModel.quizzesWithScores.filter { $0.score >= 80 }, id: \.quiz.id) { quizWithScore in
//                            CompletedQuizCard(
//                                quizWithScore: quizWithScore,
//                                onRetakeQuiz: {
//                                    quizToRetake = quizWithScore.quiz
//                                }
//                            )
//                        }
//                    }
//                }
//                
//                // Uncompleted Quizzes
//                VStack(alignment: .leading, spacing: 10) {
//                    Text("Uncompleted Quizzes")
//                        .font(.headline)
//                        .padding(.horizontal)
//                    
//                    if viewModel.uncompletedQuizzes.isEmpty {
//                        Text("No uncompleted quizzes.")
//                            .foregroundColor(.secondary)
//                            .padding(.horizontal)
//                    } else {
//                        Text("Total Uncompleted: \(viewModel.uncompletedQuizzes.count)")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                            .padding(.horizontal)
//                        
//                        ForEach(viewModel.uncompletedQuizzes, id: \.id) { quiz in
//                            UncompletedQuizCard(quiz: quiz, user: viewModel.user, viewModel: viewModel, selectedDate: Binding(
//                                get: { self.selectedDates[quiz.id] ?? Date() },
//                                set: { self.selectedDates[quiz.id] = $0 }
//                            ),
//                                                onDateUpdated: {
//                                                    refreshData()  // Add this line
//                                                })
//                        }
//                    }
//                }
//            }
//            .padding()
//            .id(refreshID)
//        }
//        .navigationTitle("User Profile")
////        .refreshable {
////                    await refreshData()
////                }
////        .onAppear {
////                    if let user = user {
////                        Task {
////                            await viewModel.fetchCompletedQuizzesAndScoresofUser(user: user)
////                        }
////                    }
////                }
//                                                
//                                .onAppear {
//                                           refreshData()
//                                       }
//        
//    }
////    func refreshData() async {
////            isRefreshing = true
////            if let user = user {
////                await viewModel.fetchCompletedQuizzesAndScoresofUser(user: user)
////            } else {
////                await viewModel.fetchCompletedQuizzesAndScores()
////            }
////            isRefreshing = false
////        }
//                                                
//                                                
//    private func refreshData() {
//           Task {
//               if let user = viewModel.user {
//                   await viewModel.fetchCompletedQuizzesAndScoresofUser(user: user)
//                   await MainActor.run {
//                       refreshID = UUID()  // This will force the view to redraw
//                   }
//               }
//           }
//       }
//}

struct UserProfileContentView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @State private var selectedDates: [String: Date] = [:]
    @State private var quizToRetake: Quiz?
    @State private var isRefreshing = false
    @State var showingEditSheet = false
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                // Profile Header
                VStack(spacing: 10) {
                    HStack {
                        Spacer()
                        Button(action: {
                            showingEditSheet = true
                        }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    Text(viewModel.user?.username ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Role and floor info
                    if let user = viewModel.user {
                        Text(user.accountType)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Show all assigned floors
                        if let assignedFloors = user.assignedFloors, !assignedFloors.isEmpty {
                            Text("Assigned Floors: \(assignedFloors.joined(separator: ", "))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else if let floor = user.floor {
                            Text("Floor: \(floor)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Add Accreditations Section
                        if let accreditations = user.accreditations, !accreditations.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Accreditations")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(accreditations, id: \.name) { accreditation in
                                            VStack(alignment: .leading) {
                                                Text(accreditation.name)
                                                    .font(.subheadline)
                                                    .bold()
                                            }
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.blue.opacity(0.1))
                                            )
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                .padding()
                
                // Completed Quizzes
                VStack(alignment: .leading, spacing: 10) {
                    Text("Completed Quizzes")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if viewModel.quizzesWithScores.filter({ $0.score >= 80 }).isEmpty {
                        Text("No completed quizzes yet.")
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    } else {
                        ForEach(viewModel.quizzesWithScores.filter { $0.score >= 80 }, id: \.quiz.id) { quizWithScore in
                            CompletedQuizCard(
                                quizWithScore: quizWithScore,
                                onRetakeQuiz: {
                                    quizToRetake = quizWithScore.quiz
                                }
                            )
                        }
                    }
                }
                
                // Uncompleted Quizzes
                VStack(alignment: .leading, spacing: 10) {
                    Text("Incompleted Quizzes")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if viewModel.uncompletedQuizzes.isEmpty {
                        Text("No Incompleted quizzes.")
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    } else {
                        Text("Total Incompleted: \(viewModel.uncompletedQuizzes.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.uncompletedQuizzes, id: \.id) { quiz in
                            UncompletedQuizCard(
                                quiz: quiz,
                                user: viewModel.user,
                                viewModel: viewModel,
                                selectedDate: Binding(
                                    get: { self.selectedDates[quiz.id] ?? Date() },
                                    set: { self.selectedDates[quiz.id] = $0 }
                                ),
                                onDateUpdated: {
                                    refreshData()
                                }
                            )
                        }
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack{
                UserProfileEditView(viewModel: viewModel)
            }
        }
        .navigationTitle("User Profile")
        .refreshable {
            await refreshData()
        }
        .onAppear {
            refreshData()
        }
    }

    private func refreshData() {
        Task {
            isRefreshing = true
            if let user = viewModel.user {
                await viewModel.fetchCompletedQuizzesAndScoresofUser(user: user)
            }
            isRefreshing = false
        }
    }
}


struct UserProfileEditView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: UserProfileViewModel
    @EnvironmentObject private var buildingManager: BuildingManagerViewModel
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var selectedFloors: Set<String> = []
    @State private var showingAccreditationSheet = false
    @State private var showingSaveAlert = false
    @State private var availableFloors: [String] = []
    
    var body: some View {
       
 
                Form {
                    PersonalInfoSection(firstName: $firstName, lastName: $lastName)
                    
                    UserFloorAssignmentSection(
                        selectedFloors: $selectedFloors,
                        availableFloors: availableFloors
                    )
                    
                    AccreditationsSection(
                        viewModel: viewModel,
                        showingAccreditationSheet: $showingAccreditationSheet
                    )
                }
           
            .navigationTitle("Edit Profile")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    Task { await saveChanges() }
                }
            )
            .sheet(isPresented: $showingAccreditationSheet) {
                AddAccreditationView(viewModel: viewModel)
            }
            .alert("Profile Updated", isPresented: $showingSaveAlert) {
                Button("OK") { dismiss() }
            }
            .onAppear {
                loadUserData()
                Task {
                    await loadAvailableFloors()
                }
            }
        
    }
    
    private func loadUserData() {
        if let user = viewModel.user {
            firstName = user.firstName
            lastName = user.lastName
            if let floor = user.floor {
                selectedFloors.insert(floor)
            }
            if let assignedFloors = user.assignedFloors {
                selectedFloors = Set(assignedFloors)
            }
        }
    }
    
    private func loadAvailableFloors() async {
        if let user = viewModel.user {
            let floors = await buildingManager.fetchFloors(for: user.organizationId ?? "")
            await MainActor.run {
                self.availableFloors = floors.map { $0.mainFloor }
            }
        }
    }
    
    private func saveChanges() async {
        guard var updatedUser = viewModel.user else { return }
        
        updatedUser.firstName = firstName
        updatedUser.lastName = lastName
        updatedUser.assignedFloors = Array(selectedFloors)
        
        do {
            try await buildingManager.updateUser(updatedUser)
            await MainActor.run {
                viewModel.user = updatedUser
                showingSaveAlert = true
            }
        } catch {
            print("Error updating user: \(error)")
        }
    }
}

struct PersonalInfoSection: View {
    @Binding var firstName: String
    @Binding var lastName: String
    
    var body: some View {
        Section(header: Text("Personal Information")) {
            TextField("First Name", text: $firstName)
            TextField("Last Name", text: $lastName)
        }
    }
}



//struct FloorAssignmentSection: View {
//    @Binding var selectedFloors: Set<String>
//    
//    private let availableFloors = [
//        "1st", "2nd", "3rd", "3rd Annex Satellites",
//        "4th SPF", "4th Core", "5th"
//    ]
//    
//    var body: some View {
//        Section(header: Text("Floor Assignments")) {
//            ForEach(availableFloors, id: \.self) { floor in
//                FloorRow(floor: floor, selectedFloors: $selectedFloors)
//            }
//        }
//    }
//}

// MARK: - User Profile Components
struct UserFloorAssignmentSection: View {
    @Binding var selectedFloors: Set<String>
    let availableFloors: [String]
    
    var body: some View {
        Section(header: Text("Floor Assignments")) {
            ForEach(availableFloors, id: \.self) { floor in
                UserFloorRow(floor: floor, selectedFloors: $selectedFloors)
            }
        }
    }
}

struct UserFloorRow: View {
    let floor: String
    @Binding var selectedFloors: Set<String>
    
    var body: some View {
        HStack {
            Text(floor)
            Spacer()
            if selectedFloors.contains(floor) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if selectedFloors.contains(floor) {
                selectedFloors.remove(floor)
            } else {
                selectedFloors.insert(floor)
            }
        }
    }
}
struct AccreditationsSection: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @Binding var showingAccreditationSheet: Bool
    @State private var showingDeleteAlert = false
    @State private var accreditationToDelete: Accreditation?
    
    var body: some View {
        Section(header: Text("Accreditations")) {
            if let accreditations = viewModel.user?.accreditations {
                ForEach(accreditations, id: \.name) { accreditation in
                    AccreditationRow(accreditation: accreditation)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                accreditationToDelete = accreditation
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            
            Button(action: {
                showingAccreditationSheet = true
            }) {
                Label("Add Accreditation", systemImage: "plus.circle.fill")
            }
        }
        .alert("Delete Accreditation", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let accreditation = accreditationToDelete {
                    deleteAccreditation(accreditation)
                }
            }
        } message: {
            Text("Are you sure you want to delete this accreditation? This action cannot be undone.")
        }
    }
    
    private func deleteAccreditation(_ accreditation: Accreditation) {
        Task {
            if let userID = viewModel.user?.userUID,
               var user = viewModel.user { // Safely unwrap user
                do {
                    // Remove from Firebase
                    try await UserManager.shared.removeAccreditation(
                        userID: userID,
                        accreditationName: accreditation.name
                    )
                    
                    // Update local user object
                    user.accreditations?.removeAll { $0.name == accreditation.name }
                    
                    await MainActor.run {
                        viewModel.user = user
                    }
                } catch {
                    print("Error deleting accreditation: \(error)")
                }
            }
        }
    }
}

// Update AccreditationRow to show more details
struct AccreditationRow: View {
    let accreditation: Accreditation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(accreditation.name)
                .font(.headline)
            Text("Issuing Authority: \(accreditation.issuingAuthority)")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("Received: \(accreditation.dateReceived.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption)
                .foregroundColor(.secondary)
            if let expDate = accreditation.expirationDate {
                Text("Expires: \(expDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}
// Add Accreditation View
struct AddAccreditationView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: UserProfileViewModel
    @State private var name = ""
    @State private var dateReceived = Date()
    @State private var expirationDate = Date()
    @State private var hasExpiration = false
    @State private var issuingAuthority = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Accreditation Name", text: $name)
                TextField("Issuing Authority", text: $issuingAuthority)
                
                DatePicker("Date Received",
                          selection: $dateReceived,
                          displayedComponents: .date)
                
                Toggle("Has Expiration Date", isOn: $hasExpiration)
                
                if hasExpiration {
                    DatePicker("Expiration Date",
                              selection: $expirationDate,
                              displayedComponents: .date)
                }
            }
            .navigationTitle("Add Accreditation")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    Task {
                        await saveAccreditation()
                    }
                }
                .disabled(name.isEmpty || issuingAuthority.isEmpty)
            )
        }
    }
    
    private func saveAccreditation() async {
        let newAccreditation = Accreditation(
            name: name,
            dateReceived: dateReceived,
            expirationDate: hasExpiration ? expirationDate : nil,
            issuingAuthority: issuingAuthority
        )
        
        do {
            try await UserManager.shared.updateUserAccreditations(
                userID: viewModel.user?.userUID ?? "",
                accreditation: newAccreditation
            )
            // Refresh user data in view model
            if let userUID = viewModel.user?.userUID {
                let updatedUser = try await UserManager.shared.fetchUser(by: userUID)
                await MainActor.run {
                    viewModel.user = updatedUser
                }
            }
            dismiss()
        } catch {
            print("Error adding accreditation: \(error)")
        }
    }
}


struct CompletedQuizCard: View {
    let quizWithScore: QuizWithScore
    let onRetakeQuiz: () -> Void
    
    var body: some View {
        HStack {
            CircularProgressView(progress: quizWithScore.score / 100)
                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading) {
                Text(quizWithScore.quiz.info.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Button("Retake Quiz") {
                    onRetakeQuiz()
                }
                .foregroundColor(.blue)
                .padding(.top, 4)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
}


//struct UncompletedQuizCard: View {
//    let quiz: Quiz
//       let user: User?
//       @ObservedObject var viewModel: UserProfileViewModel
//       @Binding var selectedDate: Date
//       @State private var showingDatePicker = false
//    var onDateUpdated: () -> Void  // Add this line
//       var body: some View {
//           VStack(alignment: .leading, spacing: 10) {
//               HStack {
//                   Image(systemName: "flag.fill")
//                       .foregroundColor(.red)
//                   
//                   Text(quiz.info.title)
//                       .font(.headline)
//                   
//                   Spacer()
//                   
//                   Text(quizStatus)
//                       .font(.subheadline)
//                       .foregroundColor(.secondary)
//               }
//               
//               Text("Due Date: \(formattedDueDate)")
//                   .font(.subheadline)
//                   .foregroundColor(.secondary)
//               
//               Button(action: {
//                             showingDatePicker = true
//                         }) {
//                             Text("Change Due Date")
//                                 .foregroundColor(.white)
//                                 .padding(.horizontal, 20)
//                                 .padding(.vertical, 10)
//                                 .background(Color.blue)
//                                 .cornerRadius(8)
//                         }
//           }
//           .padding()
//           .background(Color.green.opacity(0.1))
//           .cornerRadius(10)
//           .sheet(isPresented: $showingDatePicker) {
//                      DatePickerView(selectedDate: $selectedDate, showingDatePicker: $showingDatePicker, onSave: {
//                          updateDueDate()
//                          onDateUpdated()  // Call this after updating the date
//                      })
//                  }
//       }
//    
//    var quizStatus: String {
//        if let quizScore = user?.quizScores?.first(where: { $0.quizID == quiz.id }),
//           let highestScore = quizScore.scores.max(), highestScore > 0 {
//            return "\(Int(highestScore))%"
//        } else {
//            return "Not Started"
//        }
//    }
//    
//    var formattedDueDate: String {
//        print("User: \(user?.username ?? "No user")")
//        print("Quiz Scores: \(user?.quizScores?.count ?? 0)")
//        if let quizScore = user?.quizScores?.first(where: { $0.quizID == quiz.id }) {
//            print("Found quiz score for \(quiz.id)")
//            print("Due Dates: \(quizScore.dueDates ?? [:])")
//            if let dueDates = quizScore.dueDates,
//               let dueDate = dueDates[quiz.id],
//               let unwrappedDueDate = dueDate {
//                let formatter = DateFormatter()
//                formatter.dateStyle = .medium
//                return formatter.string(from: unwrappedDueDate)
//            } else {
//                print("No due date found for \(quiz.id)")
//                return "Not set"
//            }
//        } else {
//            print("No quiz score found for \(quiz.id)")
//            return "Not set"
//        }
//    }
//    
//    func updateDueDate() {
//           Task {
//               await viewModel.setDueDateForFailedQuiz(user: user!, quizID: quiz.id, newDueDate: selectedDate)
//               await viewModel.updateUserQuizDueDate(for: user, quizID: quiz.id, newDate: selectedDate)
//           }
//       }
//}

struct UncompletedQuizCard: View {
    let quiz: Quiz
    let user: User?
    @ObservedObject var viewModel: UserProfileViewModel
    @Binding var selectedDate: Date
    @State private var showingDatePicker = false
    var onDateUpdated: () -> Void
   
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "flag.fill")
                    .foregroundColor(.red)
                
                Text(quiz.info.title)
                    .font(.headline)
                
                Spacer()
                
                Text(quizStatus)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text("Due Date: \(formattedDueDate)")
                           .font(.subheadline)
                           .foregroundColor(.secondary)
                       
                       Button(action: {
                           showingDatePicker = true
                       }) {
                           Text("Change Due Date")
                               .foregroundColor(.white)
                               .padding(.horizontal, 20)
                               .padding(.vertical, 10)
                               .background(Color.blue)
                               .cornerRadius(8)
                       }
                   }
                   .padding()
                   .background(Color.green.opacity(0.1))
                   .cornerRadius(10)
                   .sheet(isPresented: $showingDatePicker) {
                       DatePickerView(selectedDate: $selectedDate, showingDatePicker: $showingDatePicker, onSave: {
                           updateDueDate()
                       })
                   }
        }
    

    private var quizStatus: String {
        if let quizScore = user?.quizScores?.first(where: { $0.quizID == quiz.id }),
           let highestScore = quizScore.scores.max(), highestScore > 0 {
            return "\(Int(highestScore))%"
        } else {
            return "Not Started"
        }
    }
//
//private var formattedDueDates: String {
//        if let quizScore = viewModel.user?.quizScores?.first(where: { $0.quizID == quiz.id }),
//           let dueDates = quizScore.dueDate,
//           let dueDate = dueDates[quiz.id],
//           let unwrappedDueDate = dueDate {
//            let formatter = DateFormatter()
//            formatter.dateStyle = .medium
//            return formatter.string(from: unwrappedDueDate)
//        } else {
//            return "Not set"
//        }
//    }
    private var formattedDueDate: String {
        if let quizScore = viewModel.user?.quizScores?.first(where: { $0.quizID == quiz.id }),
           let dueDates = quizScore.dueDates,
           let dueDate = dueDates[quiz.id],
           let unwrappedDueDate = dueDate {  // Unwrap the inner optional
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: unwrappedDueDate)
        } else {
            return "Not set"
        }
    }
    private func updateDueDate() {
        Task {
            let newRenewalDate = Calendar.current.date(byAdding: .month, value: 3, to: selectedDate) ?? selectedDate
            await viewModel.setDueDateForFailedQuiz(user: viewModel.user!, quizID: quiz.id, newDueDate: selectedDate, newRenewalDate: newRenewalDate)
            await viewModel.updateUserQuizDueDate(for: viewModel.user, quizID: quiz.id, newDate: selectedDate)
            onDateUpdated()
        }
    }
}

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 8.0)
                .opacity(0.3)
                .foregroundColor(Color.blue)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 8.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.blue)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
            
            Text(String(format: "%.0f%%", min(self.progress, 1.0)*100.0))
                .font(.headline)
                .bold()
        }
    }
}
extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }
}


struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Binding var showingDatePicker: Bool
    var onSave: () -> Void

    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select Due Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                
                Button("Save") {
                    onSave()
                    showingDatePicker = false
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .navigationTitle("Change Due Date")
            .navigationBarItems(trailing: Button("Cancel") {
                showingDatePicker = false
            })
        }
    }
}
