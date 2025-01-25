//
//  HuabndrySOPLIstView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/28/24.
//

import SwiftUI
import WebKit
import PDFKit
import FirebaseAuth
struct HusbandryPDFListView: View,Hashable {
    @StateObject var vm = HusbandrySOPListViewModel()
     var SOPForStaffTittle: String
     var nameOfCategory: String
     @State private var showQuizView = false
     @Environment(\.dismiss) var dismiss
     @State private var isRotationEnabled: Bool = true
     @State private var showsIndicator: Bool = true
     @Environment(\.horizontalSizeClass) var sizeClass

     let colorScheme: [Color] = [.blue, .green, .orange, .purple, .pink]
    static func == (lhs: HusbandryPDFListView, rhs: HusbandryPDFListView) -> Bool {
            lhs.SOPForStaffTittle == rhs.SOPForStaffTittle &&
            lhs.nameOfCategory == rhs.nameOfCategory
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(SOPForStaffTittle)
            hasher.combine(nameOfCategory)
        }
        
     var body: some View {
         VStack {
             GeometryReader { geometry in
                 let size = geometry.size
                 let cardWidth = size.width - (sizeClass == .regular ? 20 : 40)

                 ScrollView(.horizontal) {
                     HStack(spacing: 0) {
                         ForEach(vm.pdfList.indices, id: \.self) { index in
                             let pdf = vm.pdfList[index]
                             CardView(pdf: pdf, isCompleted: vm.isPDFCompleted(pdfId: pdf.id), color: colorScheme[index % colorScheme.count])
                                 .padding(.horizontal, 65)
                                 .frame(width: size.width)
                                 .visualEffect { content, geometryProxy in
                                     content
                                         .scaleEffect(scale(geometryProxy, scale: 0.1), anchor: .trailing)
                                         .rotationEffect(rotation(geometryProxy, rotation: isRotationEnabled ? 5 : 0))
                                         .offset(x: minX(geometryProxy))
                                         .offset(x: excessMinX(geometryProxy, offset: isRotationEnabled ? 6 : 10))
                                 }
                                 .zIndex(Double(vm.pdfList.count - index))
                         }
                     }
                     .padding(.vertical, 15)
                 }
                 .scrollTargetBehavior(.paging)
                 .scrollIndicators(showsIndicator ? .visible : .hidden)
                 .scrollIndicatorsFlash(trigger: showsIndicator)
             }
             .frame(height: sizeClass == .regular ? 710 : 550)
             .animation(.snappy, value: isRotationEnabled)

             Button("Take Quiz") {
                 if vm.areAllPDFsCompleted() {
                     showQuizView = true
                 }
             }
             .buttonStyle(.borderedProminent)
             .tint(.blue)
             .disabled(!vm.areAllPDFsCompleted())
             .opacity(vm.areAllPDFsCompleted() ? 1 : 0.5)
             .padding(.bottom, sizeClass == .regular ? 0 : 16)
         }
         .navigationTitle("PDF List")
         .onAppear {
               
                    Task {
                       
                        await vm.fetchPDFList(title: SOPForStaffTittle, nameOfPdf: nameOfCategory)
                      
                        if let currentUserUID = Auth.auth().currentUser?.uid {
                         
                            await vm.fetchUserProgress(userUID: currentUserUID)
                        }
                        await vm.fetchQuizFor(category: SOPForStaffTittle)
                      
                    }
                }
               
         .sheet(isPresented: $showQuizView) {
             if let quiz = vm.quiz {
                 HusbandryQuestionView(quizId: quiz.id, quizTitle: quiz.info.title) {
                     dismiss()
                 }
             } else {
                 Text("No quiz available")
             }
         }
     }

     @ViewBuilder
     func CardView(pdf: PDFCategory, isCompleted: Bool, color: Color) -> some View {
         VStack {
             Spacer()
             HStack {
                 Spacer()
                 Text(pdf.pdfName)
                     .font(.title2)
                     .fontWeight(.bold)
                     .foregroundColor(.white)
                     .padding(.bottom, 20)
                     .multilineTextAlignment(.center)
                     .padding(.horizontal, 8)
                 Spacer()
             }
             if isCompleted {
                 Image(systemName: "checkmark.circle.fill")
                     .resizable()
                     .frame(width: 30, height: 30)
                     .foregroundColor(.white)
                     .padding(.top, -30)
             }
             Spacer()
             NavigationLink(value: pdf) {
                 Text("Open PDF")
                     .foregroundColor(color)
                     .padding()
                     .frame(maxWidth: 200)
                     .background(Color.white)
                     .cornerRadius(8)
             }
             .padding()
         }
         .frame(width: sizeClass == .regular ? 480 : 300)
         .background(
             RoundedRectangle(cornerRadius: 15)
                 .fill(color)
                 .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
         )
     }
//    func randomColor() -> Color {
//        let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange, .teal]
//        return colors.randomElement() ?? .gray
//    }

    /// Stacked Cards Animation
    func minX(_ proxy: GeometryProxy) -> CGFloat {
        let minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX
        return minX < 0 ? 0 : -minX
    }

    func progress(_ proxy: GeometryProxy, limit: CGFloat = 2) -> CGFloat {
        let maxX = proxy.frame(in: .scrollView(axis: .horizontal)).maxX
        let width = proxy.bounds(of: .scrollView(axis: .horizontal))?.width ?? 0
        let progress = (maxX / width) - 1.0
        return min(progress, limit)
    }

    func scale(_ proxy: GeometryProxy, scale: CGFloat = 0.1) -> CGFloat {
        let progress = progress(proxy)
        return 1 - (progress * scale)
    }

    func excessMinX(_ proxy: GeometryProxy, offset: CGFloat = 10) -> CGFloat {
        let progress = progress(proxy)
        return progress * offset
    }

    func rotation(_ proxy: GeometryProxy, rotation: CGFloat = 5) -> Angle {
        let progress = progress(proxy)
        return .init(degrees: progress * rotation)
    }
}

extension Array where Element == PDFCategory {
    func zIndex(_ item: PDFCategory) -> CGFloat {
        if let index = firstIndex(where: { $0.id == item.id }) {
            return CGFloat(count) - CGFloat(index)
        }
        return .zero
    }
}
func randomColor() -> Color {
       let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange, .teal]
       return colors.randomElement() ?? .gray
   }
struct PDFItemView: View {
    let pdf: PDFCategory
    let isCompleted: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title)
                }
            }
            .padding([.top, .trailing])
            
            Text(pdf.pdfName)
                .bold()
                .font(.title2)
                .padding([.leading, .bottom], 10)
            
            Text("")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding([.leading, .bottom], 10)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .foregroundColor(.blue.opacity(0.2))
        )
        .padding(.horizontal)
    }
}
