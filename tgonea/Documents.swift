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
            LinearGradient(colors: [Color(.systemGroupedBackground), Color(.secondarySystemGroupedBackground)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {

                    // Header
                    VStack(spacing: 6) {
                        Image(systemName: "doc.richtext.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.tint)
                            .symbolRenderingMode(.hierarchical)
                        Text("Documents")
                            .font(.title2.weight(.semibold))
                        Text("Browse circulars and G.O.s")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)

                    // Cards
                    LazyVStack(spacing: 14) {
                        ForEach(vm.documents) { doc in
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
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.tint.opacity(0.12))
                                            .frame(width: 56, height: 56)
                                        Image(systemName: "doc.text.fill")
                                            .font(.title3)
                                            .foregroundStyle(.tint)
                                    }

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(doc.title)
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                        Text("Tap to view PDF")
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(14)
                                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.black.opacity(0.06))
                                )
                                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
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
                    .background(Color(.systemBackground))
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
