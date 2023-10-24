//
//  URLCache.swift
//  IDo
//
//  Created by 김도현 on 2023/10/24.
//

import Foundation

class FBURLCache {
    static let shared = FBURLCache()
    private let urlCache: URLCache
    private let urlSesstion: URLSession = URLSession.shared
    
    private init() {
        let cacheSizeMemory = 100 * 1024 * 1024
        let cacheSizeDisk = 100 * 1024 * 1024
        let cache = URLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: "UserProfileImage")
        URLCache.shared = cache
        self.urlCache = URLCache.shared
    }
    
    func downloadURL(url: URL, completion: @escaping (Result<Data,Error>) -> Void) {
        let request = URLRequest(url: url)
        if let cachedResponse = urlCache.cachedResponse(for: request) {
            let data = cachedResponse.data
            completion(.success(data))
        } else {
            urlSesstion.dataTask(with: request) { data, response, error in
                if let error {
                    completion(.failure(error))
                }
                guard let data,
                    let response else { return }
                let cachedData = CachedURLResponse(response: response, data: data)
                URLCache.shared.storeCachedResponse(cachedData, for: request)
                completion(.success(data))
            }.resume()
        }
    }
}
