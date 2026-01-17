//
//  Documents.swift
//  tgonea
//
//  Created by Soma Shekar on 09/01/26.
//

import SwiftUI
import PDFKit

struct Documents: View {

    @StateObject private var vm = PdfViewModel()
    @State private var selectedPdfUrl: URL?

    var body: some View {

        List(vm.documents) { doc in
            Button {
                PdfDownloader.downloadPdf(from: doc.pdfUrl) { localUrl in
                    DispatchQueue.main.async {
                        self.selectedPdfUrl = localUrl
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "doc.fill")
                    Text(doc.title)
                }
            }
        }
        .navigationTitle("Documents")
        .onAppear {
            vm.fetchDocuments()
        }
        .sheet(item: $selectedPdfUrl) { url in
            PdfViewer(url: url)
        }
    }
}


#Preview {
    Documents()
}
