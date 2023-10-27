//
//  ProfileImageCache.swift
//  IDo
//
//  Created by 김도현 on 2023/10/26.
//

import Foundation

struct ProfileImageCache {

    private let cacheDirectory: URL
    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()

    init() {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("Profile")
        if !FileManager.default.fileExists(atPath: cacheDirectory.path) {
            try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }

    func storeFile(myUserInfo: MyUserInfo) {
        let fileURL = cacheDirectory.appendingPathComponent(myUserInfo.id)
        do {
            let data = try jsonEncoder.encode(myUserInfo)
            try? data.write(to: fileURL)
        } catch let e {
            print(e.localizedDescription)
        }
    }

    func getFile(uid: String) -> MyUserInfo? {
        let fileURL = cacheDirectory.appendingPathComponent(uid)
        do {
            let profileData = try Data(contentsOf: fileURL)
            return try jsonDecoder.decode(MyUserInfo.self, from: profileData)
        } catch let e {
            print(e.localizedDescription)
        }
        return nil
    }

    func removeFile(uid: String) {
        let fileURL = cacheDirectory.appendingPathComponent(uid)
        try? FileManager.default.removeItem(at: fileURL)
    }
}
