import FirebaseFirestore
import SwiftUI
import Combine

// View model responsible for fetching PDF documents from Firestore
class PdfViewModel: ObservableObject {
    @Published var documents: [PdfDocument] = []

    // Correct Firestore instance
    private let db = Firestore.firestore()

    func fetchDocuments() {
        db.collection("documents").getDocuments { snapshot, error in
            if let error = error {
                print("Firestore error:", error)
                return
            }

            guard let docs = snapshot?.documents else { return }

            let mapped: [PdfDocument] = docs.map { doc in
                let data = doc.data()
                return PdfDocument(
                    id: doc.documentID,
                    title: data["title"] as? String ?? "",
                    pdfUrl: data["pdfUrl"] as? String ?? ""
                )
            }

            // Publish on main thread
            DispatchQueue.main.async {
                self.documents = mapped
            }
        }
    }
}
