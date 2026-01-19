import SwiftUI

final class ImageCache {
    static let shared = ImageCache()
    private init() {}

    private let cache = NSCache<NSURL, UIImage>()

    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    func insert(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
}

struct CachedAsyncImage: View {
    let url: URL?
    let contentMode: ContentMode
    let cornerRadius: CGFloat

    @State private var uiImage: UIImage?
    @State private var isLoading = false
    @State private var didFail = false

    init(url: URL?, contentMode: ContentMode = .fit, cornerRadius: CGFloat = 12) {
        self.url = url
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        Group {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if didFail {
                Color.gray
                    .overlay(Text("Failed to load"))
            } else {
                ProgressView()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .task {
            await loadIfNeeded()
        }
    }

    @MainActor
    private func loadIfNeeded() async {
        guard !isLoading else { return }
        guard let url else { didFail = true; return }

        if let cached = ImageCache.shared.image(for: url) {
            self.uiImage = cached
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                ImageCache.shared.insert(image, for: url)
                self.uiImage = image
            } else {
                didFail = true
            }
        } catch {
            didFail = true
        }
    }
}
