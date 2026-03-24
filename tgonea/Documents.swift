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
        ZStack {
            AppScreenBackground()

            ScrollView {
                VStack(spacing: 16) {
                    AppSectionHeader(
                        eyebrow: "Records",
                        title: "Circulars and G.O.s",
                        subtitle: "Browse official documents in a cleaner reading flow."
                    )
                    .padding(.top, 16)
                    .stagedAppear()

                    LazyVStack(spacing: 14) {
                        ForEach(Array(vm.documents.enumerated()), id: \.element.id) { index, doc in
                            Button {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                    PdfDownloader.downloadPdf(from: doc.pdfUrl) { localUrl in
                                        DispatchQueue.main.async {
                                            self.selectedPdfUrl = localUrl
                                        }
                                    }
                                }
                            } label: {
                                HStack(alignment: .center, spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(
                                                LinearGradient(
                                                    colors: [AppTheme.sky.opacity(0.94), AppTheme.mint.opacity(0.82)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 56, height: 56)
                                        Image(systemName: "doc.text.fill")
                                            .font(.title3)
                                            .foregroundStyle(.white)
                                    }

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(doc.title)
                                            .font(.headline)
                                            .foregroundStyle(AppTheme.ink)
                                        Text("Tap to view PDF")
                                            .font(.footnote)
                                            .foregroundStyle(AppTheme.softText)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(AppTheme.accent.opacity(0.7))
                                }
                                .padding(14)
                                .appCardStyle()
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .stagedAppear(Double(index) * 0.04 + 0.08)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
        }
        .font(.system(.body, design: .rounded))
        .navigationTitle("Documents")
        .onAppear {
            vm.fetchDocuments()
        }
        .sheet(isPresented: .constant(selectedPdfUrl != nil), onDismiss: {
            selectedPdfUrl = nil
        }) {
            if let url = selectedPdfUrl {
                PdfViewer(url: url)
                    .background(AppScreenBackground())
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "doc")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No document selected")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                }
                .padding()
            }
        }
    }
}


#Preview {
    Documents()
}
