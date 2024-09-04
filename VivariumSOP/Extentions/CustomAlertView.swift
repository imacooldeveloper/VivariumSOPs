//
//  CustomAlertView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/3/24.
//

import SwiftUI
//struct CustomAlertView: View {
//    let title: String
//    let message: String
//    let isSuccess: Bool
//    let dismissAction: () -> Void
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Image(systemName: isSuccess ? "checkmark.circle" : "exclamationmark.triangle")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 50, height: 50)
//                .foregroundColor(isSuccess ? .green : .red)
//            
//            Text(title)
//                .font(.headline)
//            
//            Text(message)
//                .font(.body)
//                .multilineTextAlignment(.center)
//            
//            Button(action: dismissAction) {
//                Text("OK")
//                    .padding(.horizontal, 30)
//                    .padding(.vertical, 10)
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(20)
//        .shadow(radius: 10)
//    }
//}
//struct CustomAlertView: View {
//    let title: String
//    let message: String
//    let primaryButton: AlertButton
//    let secondaryButton: AlertButton?
//    let dismissButton: AlertButton
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            Text(title)
//                .font(.headline)
//            
//            Text(message)
//                .font(.body)
//                .multilineTextAlignment(.center)
//            
//            HStack(spacing: 20) {
//                if let secondaryButton = secondaryButton {
//                    Button(action: secondaryButton.action) {
//                        Text(secondaryButton.title)
//                            .frame(minWidth: 0, maxWidth: .infinity)
//                            .padding()
//                            .background(Color.gray)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    }
//                }
//                
//                Button(action: primaryButton.action) {
//                    Text(primaryButton.title)
//                        .frame(minWidth: 0, maxWidth: .infinity)
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//            }
//            
//            Button(action: dismissButton.action) {
//                Text(dismissButton.title)
//                    .foregroundColor(.blue)
//            }
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(20)
//        .shadow(radius: 10)
//        .padding(40)
//    }
//}


//struct CustomAlertView: View {
//    let title: String
//    let message: String
//    let primaryButton: AlertButton
//    let secondaryButton: AlertButton?
//    
//    init(title: String, message: String, isSuccess: Bool? = nil, dismissAction: @escaping () -> Void) {
//        self.title = title
//        self.message = message
//        self.primaryButton = AlertButton(title: "OK", action: dismissAction)
//        self.secondaryButton = nil
//        
//        if let isSuccess = isSuccess {
//            self.iconName = isSuccess ? "checkmark.circle" : "exclamationmark.triangle"
//            self.iconColor = isSuccess ? .green : .red
//        } else {
//            self.iconName = nil
//            self.iconColor = nil
//        }
//    }
//    
//    init(title: String, message: String, primaryButton: AlertButton, secondaryButton: AlertButton? = nil) {
//        self.title = title
//        self.message = message
//        self.primaryButton = primaryButton
//        self.secondaryButton = secondaryButton
//        self.iconName = nil
//        self.iconColor = nil
//    }
//    
//    private let iconName: String?
//    private let iconColor: Color?
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            if let iconName = iconName, let iconColor = iconColor {
//                Image(systemName: iconName)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 50, height: 50)
//                    .foregroundColor(iconColor)
//            }
//            
//            Text(title)
//                .font(.headline)
//            
//            Text(message)
//                .font(.body)
//                .multilineTextAlignment(.center)
//            
//            HStack(spacing: 20) {
//                if let secondaryButton = secondaryButton {
//                    Button(action: secondaryButton.action) {
//                        Text(secondaryButton.title)
//                            .frame(minWidth: 0, maxWidth: .infinity)
//                            .padding()
//                            .background(Color.gray)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    }
//                }
//                
//                Button(action: primaryButton.action) {
//                    Text(primaryButton.title)
//                        .frame(minWidth: 0, maxWidth: .infinity)
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//            }
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(20)
//        .shadow(radius: 10)
//        .padding(40)
//    }
//}
struct CustomAlertView: View {
    let title: String
    let message: String
    let primaryButton: AlertButton
    let secondaryButton: AlertButton?
    let dismissButton: AlertButton?
    
    init(title: String, message: String, isSuccess: Bool? = nil, dismissAction: @escaping () -> Void) {
        self.title = title
        self.message = message
        self.primaryButton = AlertButton(title: "OK", action: dismissAction)
        self.secondaryButton = nil
        self.dismissButton = nil
        
        if let isSuccess = isSuccess {
            self.iconName = isSuccess ? "checkmark.circle" : "exclamationmark.triangle"
            self.iconColor = isSuccess ? .green : .red
        } else {
            self.iconName = nil
            self.iconColor = nil
        }
    }
    
    init(title: String, message: String, primaryButton: AlertButton, secondaryButton: AlertButton? = nil, dismissButton: AlertButton? = nil) {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
        self.dismissButton = dismissButton
        self.iconName = nil
        self.iconColor = nil
    }
    
    private let iconName: String?
    private let iconColor: Color?
    
    var body: some View {
        VStack(spacing: 20) {
            if let iconName = iconName, let iconColor = iconColor {
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(iconColor)
            }
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 20) {
                if let secondaryButton = secondaryButton {
                    Button(action: secondaryButton.action) {
                        Text(secondaryButton.title)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                
                Button(action: primaryButton.action) {
                    Text(primaryButton.title)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            
            if let dismissButton = dismissButton {
                Button(action: dismissButton.action) {
                    Text(dismissButton.title)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(40)
    }
}
struct AlertButton {
    let title: String
    let action: () -> Void
}

struct CreateQuizButton: View {
    let action: () -> Void
       let isDisabled: Bool
       
       var body: some View {
           Button(action: action) {
               HStack {
                   Image(systemName: "plus")
                   Text("Create Quiz")
                       .fontWeight(.semibold)
               }
               .padding(.horizontal, 20)
               .padding(.vertical, 12)
               .background(isDisabled ? Color.gray.opacity(0.5) : Color.blue)
               .foregroundColor(.white)
               .cornerRadius(25)
               .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
           }
           .disabled(isDisabled)
           .scaleEffect(isDisabled ? 0.95 : 1.0)
           .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: isDisabled)
       }
}
//struct CreateQuizButton: View {
//    let action: () -> Void
//    let isDisabled: Bool
//    
//    @State private var isHovered = false
//    
//    var body: some View {
//        Button(action: action) {
//            HStack {
//                Image(systemName: "plus")
//                Text("Create Quiz")
//                    .font(.headline)
//            }
//            .frame(minWidth: 200) // Set a minimum width
//            .padding(.horizontal, 20)
//            .padding(.vertical, 12)
//            .background(
//                isDisabled ? Color.gray.opacity(0.5) :
//                    (isHovered ? Color.blue.opacity(0.8) : Color.blue)
//            )
//            .foregroundColor(.white)
//            .cornerRadius(25)
//            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
//        }
//        .disabled(isDisabled)
//        .scaleEffect(isDisabled ? 0.95 : 1.0)
//        .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: isDisabled)
//        .onHover { hovering in
//            isHovered = hovering
//        }
//    }
//}
