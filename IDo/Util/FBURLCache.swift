//
//  URLCache.swift
//  IDo
//
//  Created by 김도현 on 2023/10/24.
//

import UIKit
import FirebaseStorage

class FBURLCache {
    static let shared = FBURLCache()
    private let urlCache: URLCache
    private let imageCache = NSCache<NSString, UIImage>()
    private var downloadTasks: [String: URLSessionDataTask] = [:]
    
    private init() {
        let cacheSizeMemory = 100 * 1024 * 1024
        let cacheSizeDisk = 100 * 1024 * 1024
        let cache = URLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: "UserProfileImage")
        URLCache.shared = cache
        self.urlCache = URLCache.shared
    }
    
    func cancelDownloadURL(storagePath: String) {
        downloadTasks[storagePath]?.cancel()
        downloadTasks[storagePath] = nil
    }
    
    //TODO: 코드를 메서드를 어떻게 줄일지 생각해보기
    func downloadURL(storagePath: String, completion: @escaping (Result<UIImage,Error>) -> Void) {
        var cacheImage = UIImage()
        //TODO: 이미지를 바뀌었을떄 metadata로 확인하여 이미지를 확인하는데 그전에 확인하는 방법 생각해보기
        if let image = imageCache.object(forKey: storagePath as NSString) {
            completion(.success(image))
            cacheImage = image
//            return
        }
        let storage = Storage.storage().reference(withPath: storagePath)
        storage.getMetadata { metadata, error in
            if let error {
                completion(.failure(error))
                return
            }
            if let localDataHash = cacheImage.pngData()?.md5Hash,
               let storageDataHash = metadata?.md5Hash,
               localDataHash == storageDataHash {
//                completion(.success(cacheImage))
                return
            }
                        
            storage.downloadURL { url, error in
                if let error {
                    completion(.failure(error))
                    return
                }
                guard let url else { return }
                let request = URLRequest(url: url)
                if let cachedResponse = self.urlCache.cachedResponse(for: request) {
                    let localDataHash = cachedResponse.data.md5Hash
                    if let storageDataHash = metadata?.md5Hash,
                       localDataHash == storageDataHash {
                        if let image = UIImage(data: cachedResponse.data) {
                            completion(.success(image))
                            self.imageCache.setObject(image, forKey: storagePath as NSString)
                            return
                        } else {
                            print("image Data를 읽을수 없습니다.")
                            return
                        }
                    } else {
                        self.downloadImageData(request: request, storagePath: storagePath) { result in
                            switch result {
                            case .success(let data):
                                if let image = UIImage(data: data) {
                                    completion(.success(image))
                                    return
                                }
                                print("image Data를 읽을수 없습니다.")
                            case .failure(let error):
                                completion(.failure(error))
                                return
                            }
                        }
                    }
                } else {
                    self.downloadImageData(request: request, storagePath: storagePath) { result in
                        switch result {
                        case .success(let data):
                            if let image = UIImage(data: data) {
                                completion(.success(image))
                                return
                            }
                            print("image Data를 읽을수 없습니다.")
                        case .failure(let error):
                            completion(.failure(error))
                            return
                        }
                    }
                }
            }
        }
    }
    
    struct ImageIndex {
        var index: String
        var image: UIImage
    }
    
    func downloadURL(storagePath: String, completion: @escaping (Result<ImageIndex,Error>) -> Void) {
        
//        if let image = imageCache.object(forKey: storagePath as NSString) {
//            completion(.success(image))
//            return
//        }
        let storage = Storage.storage().reference(withPath: storagePath)
        storage.getMetadata { metadata, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let indexMetaData = metadata?.customMetadata?["index"] else {
                print("메타데이터가 없습니다")
                return
            }
            storage.downloadURL { url, error in
                if let error {
                    completion(.failure(error))
                    return
                }
                guard let url else { return }
                let request = URLRequest(url: url)
                
                
                self.downloadImageData(request: request, storagePath: storagePath) { result in
                    switch result {
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            let imageIndex = ImageIndex(index: indexMetaData, image: image)
                            completion(.success(imageIndex))
                            return
                        }
                        print("image Data를 읽을수 없습니다.")
                    case .failure(let error):
                        completion(.failure(error))
                        return
                    }
                    
                }
            }
        }
    }
    
    private func downloadImageData(request: URLRequest, storagePath: String, completion: @escaping (Result<Data,Error>) -> Void) {
        let urlTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            defer {
                self?.downloadTasks.removeValue(forKey: storagePath)
            }
            
            if let error {
                completion(.failure(error))
                return
            }
            guard let data,
                let response else { return }
            let cachedData = CachedURLResponse(response: response, data: data)
            URLCache.shared.storeCachedResponse(cachedData, for: request)
            completion(.success(data))
            if let image = UIImage(data: data) {
                self?.imageCache.setObject(image, forKey: storagePath as NSString)
            }
        }
        downloadTasks[storagePath] = urlTask
        urlTask.resume()
    }
}
