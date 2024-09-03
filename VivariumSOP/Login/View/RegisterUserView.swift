//
//  RegisterUserView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/2/24.
//

import SwiftUI

struct RegisterUserView: View {
    @StateObject private var viewModel = RegisterUserViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                CustomTextField(text: $viewModel.email, placeholder: "Enter your email", label: "Email", isSecure: false, icon: "envelope", validator: viewModel.validateEmail)
                
                CustomTextField(text: $viewModel.password, placeholder: "Enter your password", label: "Password", isSecure: true, icon: "lock", validator: viewModel.validatePassword)
                
                CustomTextField(text: $viewModel.confirmPassword, placeholder: "Confirm your password", label: "Confirm Password", isSecure: true, icon: "lock")
                
                CustomTextField(text: $viewModel.firstName, placeholder: "Enter your first name", label: "First Name", isSecure: false, icon: "person")
                
                CustomTextField(text: $viewModel.lastName, placeholder: "Enter your last name", label: "Last Name", isSecure: false, icon: "person")
                
                CustomTextField(text: $viewModel.username, placeholder: "Enter your username", label: "Username", isSecure: false, icon: "person.circle")
                
                CustomTextField(text: $viewModel.facilityName, placeholder: "Enter your facility name", label: "Facility Name", isSecure: false, icon: "building.2")
                
                CustomDropdown(selection: $viewModel.accountType, label: "Account Type", options: ["Student", "Teacher", "Administrator", "Parent", "Guest"])
                
                CategorySelectionView(selectedCategories: $viewModel.selectedCategoryIDs, availableCategories: viewModel.availableCategories)
                
                Button(action: {
                    viewModel.registerUser()
                    if viewModel.logStatus {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Register")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(viewModel.isLoading)
            }
            .padding()
        }
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.4))
            }
        }
        .onAppear {
          //  viewModel.fetchAvailableCategories()
        }
    }
}

struct CategorySelectionView: View {
    @Binding var selectedCategories: Set<String>
    let availableCategories: [Categorys]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Select Categories")
                .font(.headline)
            
            ForEach(availableCategories) { category in
                Button(action: {
                    if selectedCategories.contains(category.id) {
                        selectedCategories.remove(category.id)
                    } else {
                        selectedCategories.insert(category.id)
                    }
                }) {
                    HStack {
                        Image(systemName: selectedCategories.contains(category.id) ? "checkmark.square.fill" : "square")
                        Text(category.categoryTitle)
                    }
                }
                .foregroundColor(.primary)
            }
        }
    }
}
#Preview {
    RegisterUserView()
}
struct Categorys: Identifiable {
    let id: String
    let categoryTitle: String
    
    init(id: String = UUID().uuidString, categoryTitle: String) {
        self.id = id
        self.categoryTitle = categoryTitle
    }
}
