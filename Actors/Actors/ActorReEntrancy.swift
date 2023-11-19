//
//  ViewController.swift
//  Actors
//
//  Created by Andy Ibanez on 6/26/21.
//

import UIKit

struct VideogameMaker: Sendable {
    var name: String
    var games: [Videogame]
}

enum ImageDownloadError: Error {
    case badImage
}

// "https://www.andyibanez.com/fairesepages.github.io/tutorials/async-await/part3/\(imageNumber).png

actor ImageDownloader {
    private enum ImageStatus {
        case downloading(_ task: Task<UIImage, Error>)
        case downloaded(_ image: UIImage)
    }
    
    private var cache: [URL: ImageStatus] = [:]
    
    func image(from url: URL) async throws -> UIImage {
        if let imageStatus = cache[url] {
            switch imageStatus {
            case .downloading(let task):
                return try await task.value
            case .downloaded(let image):
                return image
            }
        }
        
        let task = Task {
            try await downloadImage(url: url)
        }
        
        cache[url] = .downloading(task)
        
        do {
            let image = try await task.value
            cache[url] = .downloaded(image)
            return image
        } catch {
            // If an error occurs, we will evict the URL from the cache
            // and rethrow the original error.
            cache.removeValue(forKey: url)
            throw error
        }
    }
    
    private func downloadImage(url: URL) async throws -> UIImage {
        let imageRequest = URLRequest(url: url)
        let (data, imageResponse) = try await URLSession.shared.data(for: imageRequest)
        guard let image = UIImage(data: data), (imageResponse as? HTTPURLResponse)?.statusCode == 200 else {
            throw ImageDownloadError.badImage
        }
        return image
    }
}

class ActorReEntrancy: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // IMPORTANT NOTE:
        // Due to FB9213145, we must dispatch this call through a detached task,
        // as of Xcode 13 Beta 1 all the way to beta 4.
        //
        // Remember async tasks and detached tasks have different use cases, and this call
        // here may not be valid for your particular context.
        //
        // Using Task.detached here is a workaround for a bug.
        Task.detached {
            await self.downloadImages()
        }
    }
    
    func downloadImages() async {
        let downloader = ImageDownloader()
        let imageURL = URL(string:  "https://www.andyibanez.com/fairesepages.github.io/tutorials/async-await/part3/3.png")!
        async let downloadedImage = downloader.image(from: imageURL)
        async let sameDownloadedImage = downloader.image(from: imageURL)
        var images = [UIImage?]()
        images += [try? await downloadedImage]
        images += [try? await sameDownloadedImage]
    }
}
