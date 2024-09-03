//
//  PDFDocument.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/2/24.
//

import Foundation
struct PDFDocument: Identifiable, Hashable {
    var id = UUID() // Unique identifier for each PDF document
    var name: String? // Name of the PDF
    var category: String? // Category of the PDF (e.g., "Technical", "Education", "Entertainment", etc.)
    var pdfName: String?
    var downloadURL: URL? // URL to download the PDF from Firebase Storage (optional)
    
    // Conform to Equatable
       static func == (lhs: PDFDocument, rhs: PDFDocument) -> Bool {
           return lhs.id == rhs.id
       }
}
