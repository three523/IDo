//
//  URLCache.swift
//  IDo
//
//  Created by 김도현 on 2023/10/24.
//

import Foundation
import UIKit

class FBURLCache {
    static let shared = FBURLCache()
    private let urlCache: URLCache
    private let urlSesstion: URLSession = URLSession.shared
    private let imageCache = NSCache<NSString, UIImage>()
    
    private init() {
        let cacheSizeMemory = 100 * 1024 * 1024
        let cacheSizeDisk = 100 * 1024 * 1024
        let cache = URLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: "UserProfileImage")
        URLCache.shared = cache
        self.urlCache = URLCache.shared
    }
    
    func downloadURL(url: URL, completion: @escaping (Result<UIImage,Error>) -> Void) {
        let request = URLRequest(url: url)
        if let image = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(.success(image))
            return
        }
        if let cachedResponse = urlCache.cachedResponse(for: request) {
            let data = cachedResponse.data
            if let image = UIImage(data: data) {
                self.saveCache(data: data, stringUrl: url.absoluteString)
                completion(.success(image))
            } else {
                print("image Data를 읽을수 없습니다.")
            }
        } else {
            urlSesstion.dataTask(with: request) { data, response, error in
                if let error {
                    completion(.failure(error))
                }
                guard let data,
                    let response else { return }
                let cachedData = CachedURLResponse(response: response, data: data)
                URLCache.shared.storeCachedResponse(cachedData, for: request)
                self.saveCache(data: data, stringUrl: url.absoluteString)
                if let image = UIImage(data: data) {
                    completion(.success(image))
                } else {
                    print("이미지 data를 읽을수 없습니다.")
                }
            }.resume()
        }
    }
    
    private func saveCache(data: Data, stringUrl: String) {
        DispatchQueue.global().async {
            if let image = UIImage(data: data) {
                self.imageCache.setObject(image, forKey: stringUrl as NSString)
            }
        }
    }
}
