//
//  OrganizationSelectionView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 1/20/25.
//

import SwiftUI

struct OrganizationSelectionView: View {
    @StateObject var viewModel: LoginViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
            VStack(spacing: 20) {
                // Header
              
                
                VStack(spacing: 10) {
                    Image(systemName: "building.2.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                    
                    Text("Select Your Organization")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top)
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                } else {
                    // Organization List
                    //                    ScrollView {
                    //                        LazyVStack(spacing: 15) {
                    //                            ForEach(viewModel.organizations) { org in
                    //                                OrganizationCard(
                    //                                    organization: org,
                    //                                    isSelected: viewModel.selectedOrganizationId == org.id
                    //                                ) {
                    //                                    viewModel.selectedOrganizationId = org.id
                    //                                    viewModel.completeLogin()
                    //                                }
                    //                            }
                    //                        }
                    //                        .padding(.horizontal)
                    //                    }
                    
                    
                    List(viewModel.organizations) { org in
                                            OrganizationCard(
                                                organization: org,
                                                isSelected: viewModel.selectedOrganizationId == org.id
                                            ) {
                                                Task {
                                                    await viewModel.selectOrganization(orgId: org.id)
                                                }
                                            }
                                        }
                                 
                                .navigationTitle("Select Organization")
                                .interactiveDismissDisabled() // Prevent dismissal until selection
                }
                
                Spacer()
            }
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
       
        .task {
            print("Fetching organizations...")
                        await viewModel.fetchOrganizations()
                        print("Organizations fetched: \(viewModel.organizations.count)")
        }
        .onChange(of: viewModel.organizations) { newValue in
                   print("Organizations updated: \(newValue.count)")
               }
    }
}

struct OrganizationCard: View {
    let organization: Organization
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(organization.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Users: \(organization.settings.allowedAccountTypes.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.2), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
