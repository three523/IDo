//
//  CurrentUser.swift
//  IDo
//
//  Created by 김도현 on 2023/10/26.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

final class MyProfile {
    
    static let shared = MyProfile()
    private var firebaseManager: FBDatabaseManager<IDoUser>!
    private var fileCache: ProfileImageCache = ProfileImageCache()
    var myUserInfo: MyUserInfo?
    
    private init() {}
    
    func getUserProfile(uid: String) {
        if let currentUser = fileCache.getFile(uid: uid) {
            self.myUserInfo = currentUser
        }
        firebaseManager = FBDatabaseManager(refPath: ["Users",uid])
        firebaseManager.readData { result in
            switch result {
            case .success(let idoUser):
                if let currentUpdateAt = self.myUserInfo?.updateAt,
                   let serverUpdateAt = idoUser.updateAt {
                    if currentUpdateAt >= serverUpdateAt { return }
                }
                self.myUserInfo = idoUser.toMyUserInfo
                if let profilePath = idoUser.profileImage {
                    self.loadImage(defaultPath: profilePath, paths: ImageSize.allCases)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func loadImage(defaultPath: String, paths: [ImageSize]) {
        let defaultStorageRef = Storage.storage().reference().child(defaultPath)
        paths.forEach { path in
            let storageRef = defaultStorageRef.child(path.rawValue)
            storageRef.downloadURL { url, error in
                if let error {
                    print(error.localizedDescription)
                    return
                }
                guard let url else { return }
                FBURLCache.shared.downloadURL(url: url) { result in
                    switch result {
                    case .success(let image):
                        self.myUserInfo?.profileImage[path.rawValue] = image.pngData()
                        guard let myUserInfo = self.myUserInfo else { return }
                        self.fileCache.storeFile(myUserInfo: myUserInfo)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func saveMyUserInfo(myUserInfo: MyUserInfo) {
        self.myUserInfo = myUserInfo
        fileCache.storeFile(myUserInfo: myUserInfo)
    }
    
    func update(nickName: String? = nil, updateProfileImage: UIImage? = nil, description: String? = nil, myClubList: [Club]?, hobbyList: [String]? = nil, myNoticeBoardList: [NoticeBoard]? = nil, myCommentList: [Comment]? = nil) {
        if let nickName {
            self.myUserInfo?.nickName = nickName
        }
        if let updateProfileImage {
            let smallImage = updateProfileImage.resizeImage(targetSize: CGSize(width: 90, height: 90))
            let mediumImage = updateProfileImage.resizeImage(targetSize: CGSize(width: 480, height: 480))
            if let smallImageData = smallImage.pngData(),
               let mediumImageData = mediumImage.pngData() {
                myUserInfo?.profileImage[ImageSize.small.rawValue] = smallImageData
                myUserInfo?.profileImage[ImageSize.small.rawValue] = mediumImageData
                uploadProfileImage(imageData: smallImageData, imageSize: .small)
                uploadProfileImage(imageData: mediumImageData, imageSize: .medium)
            }
        }
        if let description {
            self.myUserInfo?.description = description
        }
        if let myClubList {
            self.myUserInfo?.myClubList = myClubList
        }
        if let hobbyList {
            self.myUserInfo?.hobbyList = hobbyList
        }
        if let myNoticeBoardList {
            self.myUserInfo?.myNoticeBoardList = myNoticeBoardList
        }
        if let myCommentList {
            self.myUserInfo?.myCommentList = myCommentList
        }
    }
    
    private func uploadProfileImage(imageData: Data, imageSize: ImageSize) {
        guard let uid = myUserInfo?.id else {
            print("uid가 존재하지 않아 이미지 저장에 실패하였습니다")
            return
        }
        let storageRef = Storage.storage().reference().child("UserProfileImages/\(uid)/\(imageSize.rawValue)")
        storageRef.putData(imageData) { _, error in
            if let error {
                print(error.localizedDescription)
            }
        }
    }
}
