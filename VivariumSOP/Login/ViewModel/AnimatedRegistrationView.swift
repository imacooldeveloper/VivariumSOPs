//
//  AnimatedRegistrationView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 1/22/25.
//

import SwiftUI
struct RegistrationItem: Identifiable {
    var id: String = UUID().uuidString
    var image: String
    var title: String
    var subtitle: String
    var type: RegistrationType
    var scale: CGFloat = 1
    var anchor: UnitPoint = .center
    var offset: CGFloat = 0
    var rotation: CGFloat = 0
    var zindex: CGFloat = 0
    var extraOffset: CGFloat = -350
    
    enum RegistrationType {
        case personalInfo, credentials, accountType, facilityInfo
    }
}

let registrationItems: [RegistrationItem] = [
    .init(
        image: "person.fill",
        title: "Personal Information",
        subtitle: "Let's get to know you",
        type: .personalInfo,
        scale: 1
    ),
    .init(
        image: "lock.fill",
        title: "Account Security",
        subtitle: "Create your credentials",
        type: .credentials,
        scale: 0.6,
        anchor: .topLeading,
        offset: -70,
        rotation: 30
    ),
    .init(
        image: "building.2.fill",
        title: "Facility Details",
        subtitle: "Tell us about your workplace",
        type: .facilityInfo,
        scale: 0.5,
        anchor: .bottomLeading,
        offset: -60,
        rotation: -35
    ),
    .init(
        image: "person.badge.key.fill",
        title: "Role Selection",
        subtitle: "Choose your account type",
        type: .accountType,
        scale: 0.4,
        anchor: .bottomLeading,
        offset: -50,
        rotation: 160,
        extraOffset: -120
    )
]

struct AnimatedRegistrationView: View {
    @StateObject private var viewModel = RegisterUserViewModel()
       @Binding var showLoginView: Bool
       @Environment(\.presentationMode) var presentationMode
       @State private var selectedItem: RegistrationItem = registrationItems.first!
       @State private var introItems: [RegistrationItem] = registrationItems
       @State private var activeIndex: Int = 0
       // Add keyboard state tracking
       @FocusState private var focusedField: Field?
       @State private var keyboardHeight: CGFloat = 0
       
       // Define fields that can be focused
       enum Field {
           case firstName, lastName, email, password, confirmPassword, facilityName
       }
    var body: some View {
        // Form Content
        ScrollView {
        VStack(spacing: 0) {
            HStack{
                if activeIndex > 0 {
                    Button {
                        updateItem(isForward: false)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.bold())
                            .foregroundStyle(.blue.gradient)
                    }
                    .padding(15)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
                Button {
                                   presentationMode.wrappedValue.dismiss()
                               } label: {
                                   Image(systemName: "xmark.circle.fill")
                                       .font(.title2)
                                       .foregroundColor(.gray)
                               }
                               .padding()
            }
            
            ZStack {
                ForEach(introItems) { item in
                    AnimatedIconView(item)
                }
            }
            .frame(height: 250)
            
            VStack(spacing: 15) {
                // Progress Indicators
                HStack(spacing: 4) {
                    ForEach(introItems) { item in
                        Capsule()
                            .fill((selectedItem.id == item.id ? Color.blue : .gray).gradient)
                            .frame(width: selectedItem.id == item.id ? 25 : 4, height: 4)
                    }
                }
                
                Text(selectedItem.title)
                    .font(.title2.bold())
                
                Text(selectedItem.subtitle)
                    .foregroundStyle(.gray)
                
               
                    VStack(spacing: 20) {
                        switch selectedItem.type {
                        case .personalInfo:
                            PersonalInfoView(viewModel: viewModel)
                        case .credentials:
                            CredentialsView(viewModel: viewModel)
                        case .accountType:
                            AccountTypeView(viewModel: viewModel)
                        case .facilityInfo:
                            FacilityInfoView(viewModel: viewModel)
                        }
                    }
                    .padding()
                }
                
                Button {
                    if selectedItem.id == introItems.last?.id {
                        register()
                    } else {
                        updateItem(isForward: true)
                    }
                } label: {
                    Text(selectedItem.id == introItems.last?.id ? "Register" : "Next")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(width: 250)
                        .padding(.vertical, 12)
                        .background(isStepValid() ? AnyShapeStyle(.blue.gradient) : AnyShapeStyle(.gray.opacity(0.5)), in: .capsule)

                }
                .disabled(!isStepValid() || viewModel.isLoading)
                .padding(.vertical)
               // .disabled(viewModel.isLoading)
            }
            .padding()
            
            Button {
                          showLoginView = true
                          presentationMode.wrappedValue.dismiss()
                      } label: {
                          Text("Already have an account? Sign In")
                              .foregroundColor(.blue)
                              .padding(.bottom, 20)
                      }
                  .presentationDetents([.large])
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
                    // Setup keyboard notifications
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                        keyboardHeight = keyboardFrame?.height ?? 0
                    }
                    
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                        keyboardHeight = 0
                    }
                }
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text("Error"),
                  message: Text(viewModel.errorMessage),
                  dismissButton: .default(Text("OK")))
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.4))
            }
        }
        //.presentationDetents([.large])
    }
    
    @ViewBuilder
    func AnimatedIconView(_ item: RegistrationItem) -> some View {
        let isSelected = selectedItem.id == item.id
        
        Image(systemName: item.image)
            .font(.system(size: 80))
            .foregroundStyle(.white.shadow(.drop(radius: 10)))
            .frame(width: 120, height: 120)
            .background(.blue.gradient, in: .rect(cornerRadius: 32))
            .background {
                RoundedRectangle(cornerRadius: 35)
//                    .fill(.background)
//                   
//                    .shadow(color: .primary.opacity(0.2), radius: 1)
//                    .padding(-3)
//                    .opacity(isSelected ? 1 : 0)
            }
            .rotationEffect(.init(degrees: -item.rotation))
            .scaleEffect(isSelected ? 1.1 : item.scale, anchor: item.anchor)
            .offset(x: item.offset)
            .rotationEffect(.init(degrees: item.rotation))
            .zIndex(isSelected ? 2 : item.zindex)
    }
    func isStepValid() -> Bool {
            switch selectedItem.type {
            case .personalInfo:
                return !viewModel.firstName.isEmpty &&
                       !viewModel.lastName.isEmpty &&
                       !viewModel.username.isEmpty
            case .credentials:
                let (isEmailValid, _) = viewModel.validateEmail(viewModel.email)
                let (isPasswordValid, _) = viewModel.validatePassword(viewModel.password)
                return isEmailValid && isPasswordValid &&
                       viewModel.password == viewModel.confirmPassword
            case .accountType:
                  return !viewModel.accountType.isEmpty  // Only check if account type is selected
            case .facilityInfo:
                return !viewModel.facilityName.isEmpty
            }
        }
    func updateItem(isForward: Bool) {
        guard isForward ? activeIndex != introItems.count - 1 : activeIndex != 0 else { return }
        
        let fromIndex = isForward ? activeIndex : activeIndex + 1
        let extraOffset = introItems[isForward ? activeIndex + 1 : activeIndex].extraOffset
        
        if isForward { activeIndex += 1 } else { activeIndex -= 1 }
        
        for index in introItems.indices {
            introItems[index].zindex = 0
        }
        
        withAnimation(.bouncy(duration: 1)) {
            introItems[fromIndex].scale = introItems[activeIndex].scale
            introItems[fromIndex].rotation = introItems[activeIndex].rotation
            introItems[fromIndex].anchor = introItems[activeIndex].anchor
            introItems[fromIndex].offset = introItems[activeIndex].offset
            introItems[activeIndex].offset = extraOffset
            introItems[fromIndex].zindex = 1
        }
        
        Task {
            try? await Task.sleep(for: .seconds(0.1))
            withAnimation(.bouncy(duration: 0.9)) {
                introItems[activeIndex].scale = 1
                introItems[activeIndex].rotation = .zero
                introItems[activeIndex].anchor = .center
                introItems[activeIndex].offset = .zero
                selectedItem = introItems[activeIndex]
            }
        }
    }
    
    func register() {
        if viewModel.validateForm() {
            viewModel.registerUser()
            if viewModel.logStatus {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

///

// Registration Item Model


//struct PersonalInfoView: View {
//    @ObservedObject var viewModel: RegisterUserViewModel
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            CustomTextField(text: $viewModel.firstName,
//                          placeholder: "First Name",
//                            label: "First Name", isSecure: false,
//                          icon: "person")
//            
//            CustomTextField(text: $viewModel.lastName,
//                          placeholder: "Last Name",
//                            label: "Last Name", isSecure: false,
//                          icon: "person")
//            
//            CustomTextField(text: $viewModel.username,
//                          placeholder: "Username",
//                            label: "Username", isSecure: false,
//                          icon: "person.circle")
//        }
//    }
//}
struct PersonalInfoView: View {
    @ObservedObject var viewModel: RegisterUserViewModel
       @FocusState var focusedField: AnimatedRegistrationView.Field?
       
       var body: some View {
           VStack(spacing: 20) {
               CustomTextField(text: $viewModel.firstName,
                             placeholder: "First Name",
                             label: "First Name",
                             isSecure: false,
                             icon: "person")
                   .focused($focusedField, equals: .firstName)
               
               CustomTextField(text: $viewModel.lastName,
                             placeholder: "Last Name",
                             label: "Last Name",
                             isSecure: false,
                             icon: "person")
                   .focused($focusedField, equals: .lastName)
            
            // Replace username TextField with a display-only view
            VStack(alignment: .leading, spacing: 4) {
                Text("Username")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack {
                    Image(systemName: "person.circle")
                        .foregroundColor(.gray)
                    Text(viewModel.username)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        .frame(maxWidth: 600) // Add max width for iPad
        .padding(.horizontal)
    }
}
struct CredentialsView: View {
    @ObservedObject var viewModel: RegisterUserViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            CustomTextField(text: $viewModel.email,
                          placeholder: "Email",
                          label: "Email", isSecure: false,
                          icon: "envelope",
                          validator: viewModel.validateEmail)
            
            CustomTextField(text: $viewModel.password,
                          placeholder: "Password",
                          label: "Password",
                          isSecure: true,
                          icon: "lock",
                          validator: viewModel.validatePassword)
            
            CustomTextField(text: $viewModel.confirmPassword,
                          placeholder: "Confirm Password",
                          label: "Confirm Password",
                          isSecure: true,
                          icon: "lock")
        }
    }
}

struct AccountTypeView: View {
    @ObservedObject var viewModel: RegisterUserViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            CustomDropdown(selection: $viewModel.accountType,
                         label: "Account Type",
                         options: ["Husbandry", "Supervisor", "Admin", "Vet Services"])
            
            if !viewModel.availableCategories.isEmpty {
                CategorySelectionView(selectedCategories: $viewModel.selectedCategoryIDs,
                                   availableCategories: viewModel.availableCategories)
            }
        }
    }
}

struct FacilityInfoView: View {
    @ObservedObject var viewModel: RegisterUserViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            CustomTextField(text: $viewModel.facilityName,
                          placeholder: "Facility Name",
                          label: "Facility Name", isSecure: false,
                          icon: "building.2")
        }
    }
}


struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let label: String
    let isSecure: Bool
    let icon: String
    var validator: ((String) -> (Bool, String?))? = nil
    
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
                        .textContentType(label.lowercased().contains("confirm") ? .newPassword : .password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                } else {
                    TextField(placeholder, text: $text)
                        .textContentType(label.lowercased().contains("email") ? .emailAddress : .none)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            if let validator = validator {
                let (isValid, message) = validator(text)
                if !isValid && !text.isEmpty {
                    Text(message ?? "Invalid input")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
    }
}
