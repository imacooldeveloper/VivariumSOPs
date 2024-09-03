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
    
    // MARK: View Properties
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    // user Defaults
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    @AppStorage("account_Type") var userAccountType: String = ""
    @AppStorage("log_status") var logStatus: Bool = false
    
    func loginUser() {
        isLoading = true
        Task {
            do {
                try await Auth.auth().signIn(withEmail: email, password: password)
                print("User signed in")
                try await fetchUser()
            } catch {
                await setError(error)
            }
        }
    }
   
    private func fetchUser() async throws {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        let user = try await Firestore.firestore().collection("Users").document(userUID).getDocument(as: User.self)
      
        self.userUID = userUID
        userNameStored = user.username
        userAccountType = user.accountType
        logStatus = true
        isLoading = false
    }
    
    // MARK: Logging User Out
    func logOutUser() {
        do {
            try Auth.auth().signOut()
            userUID = ""
            userNameStored = ""
            userAccountType = ""
            logStatus = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
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
