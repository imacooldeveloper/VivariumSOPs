//
//  LogInViewModel.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/2/24.
//


import SwiftUI
import PhotosUI
import Firebase
import FirebaseAuth
import FirebaseFirestore


@MainActor
class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var selectedOrganizationId: String?
    // MARK: View Properties
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var showOrganizationSelection: Bool = false
    // user Defaults
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    @AppStorage("account_Type") var userAccountType: String = ""
    @AppStorage("log_status") var logStatus: Bool = false
    
    @Published var organizations: [Organization] = []
   
    @AppStorage("organizationId") var organizationId: String = ""
    @MainActor
    func fetchOrganizations() async {
        if logStatus{
            do {
                organizations = try await OrganizationManager.shared.getAllOrganizations()
                if organizations.isEmpty {
                    await uploadSampleOrganizations()
                    organizations = try await OrganizationManager.shared.getAllOrganizations()
                }
            } catch {
                await setError(error)
            }
        } 
       
    }
    
    
//    func loginUser() {
//        isLoading = true
//        Task {
//            do {
//                try await Auth.auth().signIn(withEmail: email, password: password)
//                print("User signed in")
//                try await fetchUser()
//                showOrganizationSelection = true
//            } catch {
//                await setError(error)
//            }
//        }
//    }
//    
//    func loginUser() {
//        isLoading = true
//        Task {
//            do {
//                try await Auth.auth().signIn(withEmail: email, password: password)
//                print("User signed in")
//                try await fetchUser()
//                await fetchOrganizations()
//                showOrganizationSelection = true
//            } catch {
//                await setError(error)
//            }
//        }
//    }
    
//    func loginUser() async throws {
//        isLoading = true
//        defer { isLoading = false }
//        
//        do {
//            // Perform Firebase authentication
//            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
//            let userId = authResult.user.uid
//            
//            // Fetch user data to get organization ID
//            let user = try await UserManager.shared.fetchUser(by: userId)
//            
//            await MainActor.run {
//                self.organizationId = user.organizationId ?? ""
//                UserDefaults.standard.set(self.organizationId, forKey: "organizationId")
//                print("Organization ID set to: \(self.organizationId)")
//            }
//        } catch {
//            await MainActor.run {
//                self.errorMessage = error.localizedDescription
//            }
//            throw error
//        }
//    }
//        // Helper method to clear organization ID on logout
//        func clearOrganizationId() {
//            organizationId = ""
//            UserDefaults.standard.removeObject(forKey: "organizationId")
//            print("Organization ID cleared")
//        }
    func loginUser() async throws {
            isLoading = true
            defer { isLoading = false }
            
            do {
                // Perform Firebase authentication
                let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
                let userId = authResult.user.uid
                
                // Fetch user data to get organization ID
                let user = try await UserManager.shared.fetchUser(by: userId)
                
                await MainActor.run {
                    self.organizationId = user.organizationId ?? ""
                        self.userAccountType = user.accountType  // Add this line
                        UserDefaults.standard.set(self.organizationId, forKey: "organizationId")
                        UserDefaults.standard.set(user.accountType, forKey: "account_Type")  // Add this line
                        self.logStatus = true
                        UserDefaults.standard.set(true, forKey: "log_status")
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    // Ensure log status is false on error
                    self.logStatus = false
                    UserDefaults.standard.set(false, forKey: "log_status")
                }
                throw error
            }
        }
    
//    func completeLogin() {
//           // Complete the login process after organization selection
//           guard let orgId = selectedOrganizationId else { return }
//           UserDefaults.standard.set(orgId, forKey: "selected_organization_id")
//           logStatus = true
//       }
    
    
    @MainActor
    func completeLogin() {
        guard let orgId = selectedOrganizationId else { return }
        
        Task {
            do {
                let organization = try await OrganizationManager.shared.getOrganization(id: orgId)
                
                guard let userUID = Auth.auth().currentUser?.uid else { return }
                try await Firestore.firestore().collection("Users").document(userUID).updateData([
                    "organizationId": orgId
                ])
                
                organizationId = orgId
                
                logStatus = true
                isLoading = false
                showOrganizationSelection = false
            } catch {
                await setError(error)
            }
        }
    }
//    private func fetchUser() async throws {
//        guard let userUID = Auth.auth().currentUser?.uid else { return }
//        let user = try await Firestore.firestore().collection("Users").document(userUID).getDocument(as: User.self)
//      
//        self.userUID = userUID
//        userNameStored = user.username
//        userAccountType = user.accountType
//        logStatus = true
//        isLoading = false
//    }
//    
    
//    private func fetchUser() async throws {
//        guard let userUID = Auth.auth().currentUser?.uid else { return }
//        let user = try await Firestore.firestore().collection("Users").document(userUID).getDocument(as: User.self)
//      
//        self.userUID = userUID
//        userNameStored = user.username
//        userAccountType = user.accountType
//        
//        if let orgId = user.organizationId {
//            selectedOrganizationId = orgId
//            organizationID = orgId
//            logStatus = true
//        } else {
//            showOrganizationSelection = true
//        }
//        
//        isLoading = false
//    }
    private func fetchUser() async throws {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        let user = try await Firestore.firestore().collection("Users").document(userUID).getDocument(as: User.self)
      
        // Debug print to check user data
      

        self.userUID = userUID
        userNameStored = user.username
        userAccountType = user.accountType
        
        // First, fetch organizations regardless of user's org status
        await fetchOrganizations()
        
        // Explicitly check for organizationId presence
        if let orgId = user.organizationId, !orgId.isEmpty {
        
            selectedOrganizationId = orgId
            organizationId = orgId
            logStatus = true
        } else {
          
            // Ensure organizations are loaded before showing selection
            if !organizations.isEmpty {
                showOrganizationSelection = true
                logStatus = false // Keep logged out until org is selected
            } else {
             
                // Handle the case where no organizations are available
                errorMessage = "No organizations available. Please contact support."
                showError = true
            }
        }
        
        isLoading = false
    }

    // Add explicit organization selection handling
    func selectOrganization(orgId: String) async {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        do {
            // Update user document with selected organization
            try await Firestore.firestore().collection("Users").document(userUID).updateData([
                "organizationId": orgId
            ])
            
            // Update local state
            selectedOrganizationId = orgId
            organizationId = orgId
            showOrganizationSelection = false
            logStatus = true
        } catch {
            await setError(error)
        }
    }
    // MARK: Logging User Out
//    func logOutUser() {
//        do {
//            try Auth.auth().signOut()
//            userUID = ""
//            userNameStored = ""
//            userAccountType = ""
//            logStatus = false
//        } catch {
//            print("Error signing out: \(error.localizedDescription)")
//        }
//    }
//    
    func forgotPassword() {
        Task {
            do {
                try await Auth.auth().sendPasswordReset(withEmail: email)
                print("Password reset email sent")
            } catch {
                await setError(error)
            }
        }
    }
    
    
    
    ///
    func logOutUser() {
        print("Starting logout process...")
        do {
            // Print current state before logout
            print("Current state before logout:")
            print("- logStatus: \(logStatus)")
            print("- organizationId: \(organizationId)")
            print("- userUID: \(userUID)")
            print("- userAccountType: \(userAccountType)")
            
            // Perform signout
            try Auth.auth().signOut()
            print("Firebase signOut successful")
            
            // Clear all user data
            logStatus = false
            organizationId = ""
            userUID = ""
            userNameStored = ""
            userAccountType = ""
            selectedOrganizationId = nil
            
            // Clear UserDefaults with verification
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "log_status")
            defaults.removeObject(forKey: "organizationId")
            defaults.removeObject(forKey: "user_UID")
            defaults.removeObject(forKey: "user_name")
            defaults.removeObject(forKey: "account_Type")
            defaults.synchronize()
            
            // Verify clearance
            print("State after logout:")
            print("- logStatus: \(logStatus)")
            print("- organizationId: \(organizationId)")
            print("- userUID: \(userUID)")
            print("- userAccountType: \(userAccountType)")
            
            print("User logged out successfully")
        } catch {
            print("Error during logout: \(error.localizedDescription)")
            print("Error details: \(error)")
        }
    }
    // MARK: Deleting User Entire Account
    func deleteAccount() {
        isLoading = true
        Task {
            do {
                guard let user = Auth.auth().currentUser else { return }
                try await Firestore.firestore().collection("Users").document(user.uid).delete()
                try await user.delete()
                logStatus = false
                isLoading = false
            } catch {
                await setError(error)
            }
        }
    }
    
    private func setError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
        isLoading = false
    }
}
