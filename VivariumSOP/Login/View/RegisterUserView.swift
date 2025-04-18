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
    @Binding var showLoginView: Bool  // Add this line
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                CustomTextField(text: $viewModel.email, placeholder: "Enter your email", label: "Email", isSecure: false, icon: "envelope", validator: viewModel.validateEmail)
                
                CustomTextField(text: $viewModel.password, placeholder: "Enter your password", label: "Password", isSecure: true, icon: "lock", validator: viewModel.validatePassword)
                    .autocorrectionDisabled(true)
                
                CustomTextField(text: $viewModel.confirmPassword, placeholder: "Confirm your password", label: "Confirm Password", isSecure: true, icon: "lock")
                
                CustomTextField(text: $viewModel.firstName, placeholder: "Enter your first name", label: "First Name", isSecure: false, icon: "person")
                    .autocorrectionDisabled(true)
                CustomTextField(text: $viewModel.lastName, placeholder: "Enter your last name", label: "Last Name", isSecure: false, icon: "person")
                    .autocorrectionDisabled(true)
                CustomTextField(text: $viewModel.username, placeholder: "Enter your username", label: "Username", isSecure: false, icon: "person.circle")
                    .autocorrectionDisabled(true)
                CustomTextField(text: $viewModel.facilityName, placeholder: "Enter your facility name", label: "Facility Name", isSecure: false, icon: "building.2")
                    .autocorrectionDisabled(true)
                CustomDropdown(selection: $viewModel.accountType, label: "Account Type", options: [ "Husbandry", "Supervisor", "Admin", "Vet Services"])
                
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
                // Add this new button for existing users
                                Button(action: {
                                    showLoginView = true
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Text("Already have an account? Log in")
                                        .foregroundColor(.blue)
                                }
                            
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
//#Preview {
//    RegisterUserView()
//}
struct Categorys: Identifiable, Codable, Hashable {
    let id: String
    let categoryTitle: String
    
    init(id: String = UUID().uuidString, categoryTitle: String) {
        self.id = id
        self.categoryTitle = categoryTitle
    }
}
struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var showRegisterView = false
    @State private var showLoginView = true

    var body: some View {
        NavigationStack{
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.top, 50)

                Text("Welcome Back!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack(spacing: 15) {
                    CustomTextFields(text: $viewModel.email,
                                    placeholder: "Enter your email",
                                    label: "Email",
                                    isSecure: false,
                                    icon: "envelope")

                    CustomTextFields(text: $viewModel.password,
                                    placeholder: "Enter your password",
                                    label: "Password",
                                    isSecure: true,
                                    icon: "lock")
                }
                .padding(.horizontal)

                Button(action: {
                    viewModel.loginUser()
                }) {
                    Text("Log In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(viewModel.isLoading)

                Button("Forgot Password?") {
                    viewModel.forgotPassword()
                }
                .foregroundColor(.blue)

                Spacer()

                HStack {
                                   Text("Don't have an account?")
                                   Button("Register") {
                                       showRegisterView = true
                                   }
                                   .foregroundColor(.blue)
                               }
                               .padding(.bottom)
                           }
                           .padding()
                           .background(Color(.systemBackground))
                           .overlay {
                               if viewModel.isLoading {
                                   ProgressView()
                                       .scaleEffect(2)
                                       .frame(maxWidth: .infinity, maxHeight: .infinity)
                                       .background(Color.black.opacity(0.4))
                               }
                           }
                           .alert(isPresented: $viewModel.showError) {
                               Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
                           }
                       }
                       .sheet(isPresented: $showRegisterView) {
                           RegisterUserView(showLoginView: $showLoginView)
                       }
                       .onChange(of: viewModel.logStatus) { newValue in
                           if newValue {
                               showLoginView = false
                           }
                       }
    }
}

struct CustomTextFields: View {
    @Binding var text: String
    let placeholder: String
    let label: String
    let isSecure: Bool
    let icon: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .autocapitalization(.none)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}
