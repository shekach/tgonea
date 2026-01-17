
import FirebaseFirestore
import SwiftUI

classPdfViewModel: ObservableObject {
  @Published var documents: [PdfDocument] = []

  private let db = Firesstore.firestore()

  func fetchDocuments() {
    db.collection("documents").getDocuments { snapshot, error in
                                             if let error = error {
                                               print("Firestore error:" , error)
                                               return
                                             }
                                             guard let docs = snapshot?.documents else {return}

                                             self.documents = docs.map { doc in
                                                                        let data = doc.data()
                                                                        return PdfDocument(
                                                                          id:doc.documentID,
                                                                          title:data["title"] as? String ?? "",
                                                                          pdfUrl: data["pdfUrl"] as? String ?? ""
                                                                        )
                                                                                            
                                               
                                             }
      
    }
  }
}
