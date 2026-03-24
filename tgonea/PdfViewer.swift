import SwiftUI
import PDFKit

struct PdfViewer: View {

    let url: URL

    var body: some View {
        ZStack {
            AppScreenBackground()

            PDFKitView(url: url)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
                .shadow(color: AppTheme.shadow, radius: 18, y: 12)
                .padding()
        }
    }
}

struct PDFKitView: UIViewRepresentable {

    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.document = PDFDocument(url: url)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}
