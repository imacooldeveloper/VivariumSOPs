//
//  CustomAlertView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/3/24.
//

import SwiftUI
struct CustomAlertView: View {
    let title: String
    let message: String
    let isSuccess: Bool
    let dismissAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: isSuccess ? "checkmark.circle" : "exclamationmark.triangle")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(isSuccess ? .green : .red)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
            
            Button(action: dismissAction) {
                Text("OK")
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}
