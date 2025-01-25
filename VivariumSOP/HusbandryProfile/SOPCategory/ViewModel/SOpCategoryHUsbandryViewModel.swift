//
//  SOpCategoryHUsbandryViewModel.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/28/24.
//

import SwiftUI
//
//  SOPCategoryViewModel.swift
//  SOPProject
//
//  Created by Martin Gallardo on 1/16/24.
//

import Foundation

final class SOPCategoryViewModel: ObservableObject {
    
    
    @Published var categoryList: [Categorys] = []
    @AppStorage("organizationId") private var organizationId: String = ""
       
       var sopService: SOPService?
       
//       @MainActor
//       func fecthCagetoryList() async throws {
//           do {
//               categoryList = try await CategoryManager.shared.getAllCategory(for: organizationId)
//                   .sorted { $0.categoryTitle < $1.categoryTitle }
//               
//               // Optionally update sopService if needed
//               if let firstCategory = categoryList.first {
//                   sopService?.nameOFCategory = firstCategory.categoryTitle
//               }
//           } catch {
//               print("Error getting the category from firebase: \(error.localizedDescription)")
//               throw error
//           }
//       }
//    
    
    @MainActor
       func fecthCagetoryList() async throws {
           do {
               // Now using the stored organizationId
               categoryList = try await CategoryManager.shared.getAllCategory(for: organizationId)
                   .sorted { $0.categoryTitle < $1.categoryTitle }
               
               if let firstCategory = categoryList.first {
                   sopService?.nameOFCategory = firstCategory.categoryTitle
               }
           } catch {
               print("Error getting the category from firebase: \(error.localizedDescription)")
               throw error
           }
       }
    
    ///fakepdf working
//    var fakePDF: [PDFCategory] = [
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Cage Change", pdfName: "Cage Change"),
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Cage Change", pdfName: "Cage Change 102"),
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Cage Change", pdfName: "Cage Change 103"),
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Cage Change", pdfName: "Cage Change 104"),
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Cage Change", pdfName: "Cage Change 105"),
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Cage Change", pdfName: "Cage Change 106"),
////        PDFCategory(nameOfCategory: "Office", SOPForStaffTittle: "Import and Export", pdfName: "Internacional"),
////        PDFCategory(nameOfCategory: "Cage Wash", SOPForStaffTittle: "Auto Clave", pdfName: "Victor"),
//        
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "Transfering Cages with New Cage Cards"),
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "Transfer Card and CBC Transfer Request Form"),
////
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "THE MOUSE AND RAT GRIMACE SCALES"),
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "Surgery Card"),
////
////
////
////
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "Sentinel Cage Card and Sentinel Only Sticker"),
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "Rodent Sentinel Program"),
////
////
////
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "Rodent Cages With Surgery Cards"),
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "Processing a Transfer Request"),
////
////
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "Overcrowded and Non-Compliant"),
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "New Litters"),
////
////
////
////
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "New Litter Card and Mice Pup Apperance by Age Chart"),
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "Male vs Female Identification"),
////
////
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "IACUC Guidelines - Maximum Small Mouse Cage Populations"),
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "Identifying and Flagging Health Checks"),
////
////
////
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "Husbandry Procedures - Sentinel Cages"),
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "Husbandry - Blue DO NOT Cards on Cage Card Holder"),
////
////
////
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "Housing Newly Received Rodents"),
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "Handling Seizure Prone Mice/"),
////
////
////
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "HANDLING MICE - forceps and mannually"),
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "Floor Chores"),
////
////
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "Flooded Cages"),
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "Emergency Health Checks"),
////
////
////
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "DO NOT Cards and Special Handling Guide"),
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "Counts for Reports"),
////
////
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "Conducting a Transfer Request - Transporting Cages"),
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "CConducting a Transfer Request - From CBC to Satellite Facility"),
////
////
////        PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Husbandry Basic Care", pdfName: "Conducting A Transfer Request"),
//        
//      
////           PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "ABSL2", pdfName: "Operating a Class BSC"),
////           PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "ABSL2", pdfName: "Personal Protective Equipment"),
////           PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "ABSL2", pdfName: "ABSL2 Non-NHP Rooms"),
////           PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "ABSL2", pdfName: "ABSL2 Animal Room Maintenance Form"),
////           PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "ABSL2", pdfName: "Daily Monitoring of Animal Health ABSL2 Rooms"),
////           PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "ABSL2", pdfName: "Working in a Class Biological Safety Cabinet"),
////           PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "ABSL2", pdfName: "Maintaining Workspace - ABSL2 Rooms"),
////           PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "ABSL2", pdfName: "ABSL2 Mortalities"),
////           PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "ABSL2", pdfName: "Flooded Cages in ABSL2 Rooms"),
////           PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "ABSL2", pdfName: "Routine Duties")
//       
//        
//        
//        
////        PDFCategory(
////            nameOfCategory: "Husbandry",
////            SOPForStaffTittle: "Heightened Biosecurity",
////            pdfName: "H-H-08 Routine Duties- Heightened Biosecurity Risk Room"
////        ),
////
////        PDFCategory(
////            nameOfCategory: "Husbandry",
////            SOPForStaffTittle: "Heightened Biosecurity",
////            pdfName: "H-H-07 Flooded Cages"
////        ),
////
////        PDFCategory(
////            nameOfCategory: "Husbandry",
////            SOPForStaffTittle: "Heightened Biosecurity",
////            pdfName: "H-H-06 HBS Mortalities"
////        ),
////
////        PDFCategory(
////            nameOfCategory: "Husbandry",
////            SOPForStaffTittle: "Heightened Biosecurity",
////            pdfName: "H-H-05 Maintaining Workspace"
////        ),
////
////        PDFCategory(
////            nameOfCategory: "Husbandry",
////            SOPForStaffTittle: "Heightened Biosecurity",
////            pdfName: "H-H-04 HBS Husbandry 2023"
////        ),
////
////        PDFCategory(
////            nameOfCategory: "Husbandry",
////            SOPForStaffTittle: "Heightened Biosecurity",
////            pdfName: "H-H-03 HBS Daily Monitoring of Animal Health"
////        ),
////
////        PDFCategory(
////            nameOfCategory: "Husbandry",
////            SOPForStaffTittle: "Heightened Biosecurity",
////            pdfName: "H-H-01 Personal Protective Equipment - HBS Room"
////        ),
////
////        PDFCategory(
////            nameOfCategory: "Husbandry",
////            SOPForStaffTittle: "Heightened Biosecurity",
////            pdfName: "H-H-02 HBS Animal Room Maintenance Form"
////        )
//        
//        ///Barrier Rodents - Immunocore
////        PDFCategory(
////               nameOfCategory: "Husbandry",
////               SOPForStaffTittle: "Barrier Rodents - Immunocore",
////               pdfName: "D-H-01 Personal Protective Equipment - Immunocore-Barrier Rooms"
////           ),
////           PDFCategory(
////               nameOfCategory: "Husbandry",
////               SOPForStaffTittle: "Barrier Rodents - Immunocore",
////               pdfName: "D-H-02 Animal Room Maintenance Form - Rodents"
////           ),
////           PDFCategory(
////               nameOfCategory: "Husbandry",
////               SOPForStaffTittle: "Barrier Rodents - Immunocore",
////               pdfName: "D-H-03 Daily Monitoring of Animal Health (Rodent AM Checks)"
////           ),
////           PDFCategory(
////               nameOfCategory: "Husbandry",
////               SOPForStaffTittle: "Barrier Rodents - Immunocore",
////               pdfName: "D-H-04 Husbandry - Mice in Thoren Cages"
////           ),
////           PDFCategory(
////               nameOfCategory: "Husbandry",
////               SOPForStaffTittle: "Barrier Rodents - Immunocore",
////               pdfName: "D-H-05 Full Change Out for Mice and Rats in Thoren Cages"
////           ),
////           PDFCategory(
////               nameOfCategory: "Husbandry",
////               SOPForStaffTittle: "Barrier Rodents - Immunocore",
////               pdfName: "D-H-06 Spot Change for Mice and Rats in Thoren Cages"
////           ),
////           PDFCategory(
////               nameOfCategory: "Husbandry",
////               SOPForStaffTittle: "Barrier Rodents - Immunocore",
////               pdfName: "D-H-07 Maintaining Work Space - Immunocore Rooms"
////           ),
////           PDFCategory(
////               nameOfCategory: "Husbandry",
////               SOPForStaffTittle: "Barrier Rodents - Immunocore",
////               pdfName: "D-H-08 Immunocore Mortalities - Process and Record on Mortality Log"
////           ),
////           PDFCategory(
////               nameOfCategory: "Husbandry",
////               SOPForStaffTittle: "Barrier Rodents - Immunocore",
////               pdfName: "D-H-09 Routine Duties in Animal Rooms"
////           ),
////           PDFCategory(
////               nameOfCategory: "Husbandry",
////               SOPForStaffTittle: "Barrier Rodents - Immunocore",
////               pdfName: "D-H-10 Mice on Euthanasia Rack - Immunocore Hallway (PM Check)"
////           )
//   
//    /// Standard Husbandry
//        ///
//        PDFCategory(
//               nameOfCategory: "Husbandry",
//               SOPForStaffTittle: "Standard Husbandry",
//               pdfName: "C-H-03 Working in a Reverse Light Cycle Room.pdf"
//           ),
//           PDFCategory(
//               nameOfCategory: "Husbandry",
//               SOPForStaffTittle: "Standard Husbandry",
//               pdfName: "C-H-04 Daily Monitoring Of Animal Health.pdf"
//           ),
//           PDFCategory(
//               nameOfCategory: "Husbandry",
//               SOPForStaffTittle: "Standard Husbandry",
//               pdfName: "C-H-04Appendix - Rodent Water Bottle, Feed and Cage Handling.pdf"
//           ),
//           PDFCategory(
//               nameOfCategory: "Husbandry",
//               SOPForStaffTittle: "Standard Husbandry",
//               pdfName: "C-H-05 Providing Rats Environmental Enrichment.pdf"
//           ),
//           PDFCategory(
//               nameOfCategory: "Husbandry",
//               SOPForStaffTittle: "Standard Husbandry",
//               pdfName: "C-H-05Appendix - Rat Environmental Enrichment Policy.pdf"
//           ),
//           PDFCategory(
//               nameOfCategory: "Husbandry",
//               SOPForStaffTittle: "Standard Husbandry",
//               pdfName: "C-H-06 Husbandry of Mice and Rats in SPF rooms.pdf"
//           ),
//           PDFCategory(
//               nameOfCategory: "Husbandry",
//               SOPForStaffTittle: "Standard Husbandry",
//               pdfName: "C-H-07 Full Change Out.pdf"
//           ),
//           PDFCategory(
//               nameOfCategory: "Husbandry",
//               SOPForStaffTittle: "Standard Husbandry",
//               pdfName: "C-H-08 Spot Change SOP.pdf"
//           ),
//           PDFCategory(
//               nameOfCategory: "Husbandry",
//               SOPForStaffTittle: "Standard Husbandry",
//               pdfName: "C-H-08Appendix Spot Change.pdf"
//           ),
//           PDFCategory(
//               nameOfCategory: "Husbandry",
//               SOPForStaffTittle: "Standard Husbandry",
//               pdfName: "C-H-09 MAINTAINING WORK AREA.pdf"
//           ),
//           PDFCategory(
//               nameOfCategory: "Husbandry",
//               SOPForStaffTittle: "Standard Husbandry",
//               pdfName: "C-H-10 ABSL-1 Mortalities.pdf"
//           ),
//           PDFCategory(
//               nameOfCategory: "Husbandry",
//               SOPForStaffTittle: "Standard Husbandry",
//               pdfName: "C-H-10Appendix - Mortality Card and Mortality Log.pdf"
//           ),
//           PDFCategory(
//               nameOfCategory: "Husbandry",
//               SOPForStaffTittle: "Standard Husbandry",
//               pdfName: "C-H-11 Routine Duties in Animal Rooms final.pdf"
//           ),
//           PDFCategory(
//               nameOfCategory: "Husbandry",
//               SOPForStaffTittle: "Standard Husbandry",
//               pdfName: "C-H-02Appendix - Animal Room Maintenance Form - Rodents.pdf"
//           ),
//           PDFCategory(
//               nameOfCategory: "Husbandry",
//               SOPForStaffTittle: "Standard Husbandry",
//               pdfName: "C-H-02 Animal Room Maintenance Forms - Rodents.pdf"
//           ),
//           PDFCategory(
//               nameOfCategory: "Husbandry",
//               SOPForStaffTittle: "Standard Husbandry",
//               pdfName: "C-H-01 Personal Protective Equipment (PPE) - Standard Rodent Rooms.pdf"
//           )
//    ]
//    
//    @MainActor
//    func postFakePDF() async throws {
//        do {
//            
//            for pdf in fakePDF {
//                try await CategoryManager.shared.uploadCategoryPDF(room: pdf)
//            }
//           
//        } catch {
//            print("error uploading fake pdf")
//        }
//    }
    
    var fakePDF: [PDFCategory] = [
           PDFCategory(
               nameOfCategory: "Standard Husbandry",
               SOPForStaffTittle: "Standard Husbandry",
               pdfName: "C-H-03 Working in a Reverse Light Cycle Room.pdf",
               organizationId: UserDefaults.standard.string(forKey: "organizationId") ?? ""
           ),
           // Add more fake PDFs as needed...
       ]
    @MainActor
        func postFakePDF() async throws {
            for pdf in fakePDF {
                try await CategoryManager.shared.uploadCategoryPDF(room: pdf)
            }
        }
  
}







// You might also want to update the CategoryManager to handle errors more gracefully:
//extension CategoryManager {
//    func getAllCategory(for organizationId: String) async throws -> [Categorys] {
//        guard !organizationId.isEmpty else {
//            throw NSError(
//                domain: "CategoryManager",
//                code: 400,
//                userInfo: [NSLocalizedDescriptionKey: "Organization ID is required"]
//            )
//        }
//        
//        let snapshot = try await categoryCollection
//            .whereField("organizationId", isEqualTo: organizationId)
//            .getDocuments()
//        
//        return try snapshot.documents.compactMap { document in
//            try document.data(as: Categorys.self)
//        }
//    }
//}






























// create a category for firebase to pull


//   @Published var categoryList = [Category( categoryTitle: "Husbandry"),
//                        Category( categoryTitle: "Cage Wash"),
//                        Category( categoryTitle: "Vet Service"),
//                        Category( categoryTitle: "Office")]
//
//
//    var sopcategory = [
//    SOPCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Cage Change"),
//    SOPCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Clean Room"),
//    SOPCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Clean Hallways"),
//    SOPCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Collect Items"),
//    SOPCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Report Health Issue"),
//    SOPCategory(nameOfCategory: "Office", SOPForStaffTittle: "Import and Export"),
//
//    ]
//@MainActor
// Upload Category List to firestore
//    func uploadCategoryList() async throws {
//        do {
//            for category in categoryList {
//               try await CategoryManager.shared.uploadCategory(room: category)
//            }
//
//        } catch {
//
//        }
//    }
//@MainActor
 //Upload Category List to firestore
//    func uploadSOPCategoryList() async throws {
//        do {
//            for category in sopcategory {
//               try await CategoryManager.shared.uploadSOPCategory(room: category)
//            }
//
//        } catch {
//            print("Failed to upload the SOP List")
//        }
//    }
///*
 // create fake pdfs
 var fakePDF: [PDFCategory] = [
//     PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Cage Change", pdfName: "Cage Change"),
//     PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Cage Change", pdfName: "Cage Change 102"),
//     PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Cage Change", pdfName: "Cage Change 103"),
//     PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Cage Change", pdfName: "Cage Change 104"),
//     PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Cage Change", pdfName: "Cage Change 105"),
//     PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Cage Change", pdfName: "Cage Change 106"),
     /*PDFCategory(nameOfCategory: "Husbandry", SOPForStaffTittle: "Import and Export", pdfName: "Internacional")*/]
 
 @MainActor
 func postFakePDF() async throws {
     do {
         
         for pdf in fakePDF {
             try await CategoryManager.shared.uploadCategoryPDF(room: pdf)
         }
        
     } catch {
         print("error uploading fake pdf")
     }
 }
// */
