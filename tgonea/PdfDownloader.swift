
import Foundation

class PdfDownloader {

    static func downloadPdf(from urlString: String,
                            completion: @escaping (URL?) -> Void) {

        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        let task = URLSession.shared.downloadTask(with: url) { tempUrl, _, error in

            if let error = error {
                print("❌ Download error:", error)
                completion(nil)
                return
            }

            guard let tempUrl = tempUrl else {
                completion(nil)
                return
            }

            let fileManager = FileManager.default
            let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationUrl = documentsDir.appendingPathComponent(url.lastPathComponent)

            try? fileManager.removeItem(at: destinationUrl)

            do {
                try fileManager.copyItem(at: tempUrl, to: destinationUrl)
                completion(destinationUrl)
            } catch {
                print("❌ File save error:", error)
                completion(nil)
            }
        }

        task.resume()
    }
}
