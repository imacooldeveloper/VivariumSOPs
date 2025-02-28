//
//  PasswordTextField.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/2/24.
//

import SwiftUI
struct PasswordTextField: View {
    @Binding var userFieldType: String
    var topTextFieldType: String
   
      
        var body: some View {
            
            SecureField("", text: $userFieldType)
                .textContentType(.password)
                .padding(.horizontal,20)
                .padding(.top, 20)
                .frame(height: 100)
                .background{
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(lineWidth: 0.3)
                }
                .overlay(alignment: .topLeading, content: {
                    Text(topTextFieldType)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.top,10)
                        .padding(.horizontal,12)
                        //.padding(.bottom,90)
                })
                .overlay(alignment: .trailing){
                    if userFieldType.count >= 5 {
                        
                        HStack(spacing:5){
                            Rectangle()
                                .frame(width: 20, height: 4)
                                .foregroundColor(.green)
                               // .padding(.horizontal,10)
                            Rectangle()
                                .frame(width: 20, height: 4)
                                .foregroundColor(userFieldType.count >= 8 ? .green : .green.opacity(0.4))
                               // .padding(.horizontal,10)
                            Rectangle()
                                .frame(width: 20, height: 4)
                                .foregroundColor(userFieldType.count >= 15 ? .green : .green.opacity(0.4))
                                //.padding(.horizontal,10)
                            
                            Text("Strong")
                                .font(.caption)
                                .foregroundColor(.green.opacity(userFieldType.count >= 15 ? 1 : 0.4))
                               
                           
                            
                        }
//                        .animation(.easeInOut, value: userFieldType.count > 5)
                        .padding(.horizontal,10)
                       
                        
//                        Image(systemName: image)
//                            .padding(.horizontal,10)
//                            .foregroundColor(.green.opacity(0.4))
                           // .opacity(userFieldType.isEmpty ?  0 : 1)
                    }
                   
//                    HStack{
//                        Image(systemName: image)
//                            .padding(.horizontal,10)
//                            .foregroundColor(.green.opacity(0.4))
//                            .opacity(userFieldType.isEmpty ?  0 : 1)
//                    }
                }
              //  .padding(.horizontal,10)
            
    }
}
struct LoginTextField: View {
    
  
    @Binding var userFieldType : String
   // @State var userFieldType: String = ""
    var topTextFieldType: String
    var image: String
    var body: some View {
        TextField("", text: $userFieldType)
            .textContentType(.emailAddress)
            .font(.callout)
            .bold()
            .padding(.horizontal,20)
            .padding(.top, 20)
            .frame(height: 100)
            .background{
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(lineWidth: 0.3)
            }
            .overlay(alignment: .topLeading, content: {
                Text(topTextFieldType)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.top,10)
                    .padding(.horizontal,12)
                    //.padding(.bottom,90)
            })
            .overlay(alignment: .trailing){
                Image(systemName: image)
                    .padding(.horizontal,10)
                    .foregroundColor(.green.opacity(0.4))
                    .opacity(userFieldType.isEmpty ?  0 : 1)
//                if userFieldType.contains("@.com"){
//
//                }
             
            }
            //.padding(.horizontal,10)
    }
}


//struct CustomTextField: View {
//    @Binding var text: String
//    let placeholder: String
//    let label: String
//    let isSecure: Bool
//    let icon: String?
//    var validator: ((String) -> (Bool, String?))?
//    
//    @State private var isValid: Bool = true
//    @State private var errorMessage: String?
//    @State private var isSecureTextVisible: Bool = false
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text(label)
//                .font(.caption)
//                .foregroundColor(.gray)
//            
//            HStack {
//                if isSecure && !isSecureTextVisible {
//                    SecureField(placeholder, text: $text)
//                } else {
//                    TextField(placeholder, text: $text)
//                }
//                
//                if let icon = icon {
//                    Image(systemName: icon)
//                        .foregroundColor(.gray)
//                }
//                
//                if isSecure {
//                    Button(action: {
//                        isSecureTextVisible.toggle()
//                    }) {
//                        Image(systemName: isSecureTextVisible ? "eye.slash" : "eye")
//                            .foregroundColor(.gray)
//                    }
//                }
//            }
//            .padding()
//            .background(
//                RoundedRectangle(cornerRadius: 12, style: .continuous)
//                    .stroke(isValid ? Color.gray.opacity(0.3) : Color.red, lineWidth: 1)
//            )
//            
//            if !isValid, let errorMessage = errorMessage {
//                Text(errorMessage)
//                    .font(.caption)
//                    .foregroundColor(.red)
//            }
//            
//            if isSecure {
//                PasswordStrengthIndicator(password: text)
//            }
//        }
//        .onChange(of: text) { oldValue, newValue in
//            validateInput(newValue)
//        }
//    }
//    
//    private func validateInput(_ input: String) {
//        if let validator = validator {
//            let (valid, message) = validator(input)
//            isValid = valid
//            errorMessage = message
//        } else {
//            isValid = true
//            errorMessage = nil
//        }
//    }
//}

struct PasswordStrengthIndicator: View {
    let password: String
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Rectangle()
                    .frame(height: 4)
                    .foregroundColor(color(for: index))
            }
            
            Text(strengthText)
                .font(.caption)
                .foregroundColor(color(for: 2))
        }
        .animation(.easeInOut, value: password.count)
    }
    
    private var strength: Int {
        switch password.count {
        case 0...7: return 0
        case 8...11: return 1
        default: return 2
        }
    }
    
    private var strengthText: String {
        switch strength {
        case 0: return "Weak"
        case 1: return "Medium"
        default: return "Strong"
        }
    }
    
    private func color(for index: Int) -> Color {
        index <= strength ? .green : .gray.opacity(0.3)
    }
}


struct CustomDropdown: View {
    @Binding var selection: String
    let label: String
    let options: [String]
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(selection.isEmpty ? "Select an option" : selection)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            selection = option
                            withAnimation {
                                isExpanded = false
                            }
                        }) {
                            Text(option)
                                .foregroundColor(selection == option ? .blue : .primary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.vertical)
                .transition(.opacity)
            }
        }
    }
}

// Usage example:

