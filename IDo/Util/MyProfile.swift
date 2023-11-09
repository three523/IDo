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
    private var firebaseManager: MyProfileUpdateManager!
    private var fileCache: ProfileImageCache = ProfileImageCache()
    var myUserInfo: MyUserInfo?
    
    private init() {}
    
    func getUserProfile(uid: String, completion: ((Bool) -> Void)? = nil) {
        firebaseManager = MyProfileUpdateManager(refPath: ["Users",uid])
        //MARK: 데이터가 바꼈는지 체크하는 부분 로직 생각해보기
//        if let currentUser = fileCache.getFile(uid: uid) {
//            self.myUserInfo = currentUser
//            completion?(true)
//            return
//        }
        firebaseManager.readData { result in
            switch result {
            case .success(let idoUser):
//                if let currentUpdateAt = self.myUserInfo?.updateAt,
//                   let serverUpdateAt = idoUser.updateAt {
//                    if currentUpdateAt >= serverUpdateAt {
//                        completion?(true)
//                        return
//                    }
//                }
                self.myUserInfo = idoUser.toMyUserInfo
                if let profilePath = idoUser.profileImagePath {
                    self.loadImage(defaultPath: profilePath, paths: ImageSize.allCases)
                    completion?(true)
                    return
                }
                completion?(true)
                return
            case .failure(let error):
                completion?(false)
                print(error.localizedDescription)
                return
            }
        }
    }
    
    func loadImage(defaultPath: String, paths: [ImageSize], completion: (() -> Void)? = nil) {
        let defaultStorageRef = Storage.storage().reference().child(defaultPath)
        paths.forEach { path in
            let storageRefPath = defaultStorageRef.child(path.rawValue).fullPath
            FBURLCache.shared.downloadURL(storagePath: storageRefPath) { result in
                switch result {
                case .success(let image):
                    self.myUserInfo?.profileImage[path.rawValue] = image.pngData()
                    guard let myUserInfo = self.myUserInfo else { return }
                    self.fileCache.storeFile(myUserInfo: myUserInfo)
                    completion?()
                case .failure(let error):
                    print(error.localizedDescription)
                    completion?()
                }
            }
        }
    }
    
    func saveMyUserInfo(myUserInfo: MyUserInfo) {
        self.myUserInfo = myUserInfo
        fileCache.storeFile(myUserInfo: myUserInfo)
    }
    
    func update(nickName: String? = nil, updateProfileImage: UIImage? = nil, description: String? = nil, myClubList: [Club]? = nil, hobbyList: [String]? = nil, myNoticeBoardList: [NoticeBoard]? = nil, myCommentList: [Comment]? = nil, completion: ((Bool) -> Void)? = nil) {
        var myInfo = self.myUserInfo
        if let nickName {
            myInfo?.nickName = nickName
        }
        if let updateProfileImage {
            let smallImage = updateProfileImage.resizeImage(targetSize: CGSize(width: 90, height: 90))
            let mediumImage = updateProfileImage.resizeImage(targetSize: CGSize(width: 480, height: 480))
            if let smallImageData = smallImage.pngData(),
               let mediumImageData = mediumImage.pngData() {
                myInfo?.profileImage[ImageSize.small.rawValue] = smallImageData
                myInfo?.profileImage[ImageSize.small.rawValue] = mediumImageData
                uploadProfileImage(imageData: smallImageData, imageSize: .small)
                uploadProfileImage(imageData: mediumImageData, imageSize: .medium)
            }
        }
        if let description {
            myInfo?.description = description
        }
        if let myClubList {
            myInfo?.myClubList = myClubList
        }
        if let hobbyList {
            myInfo?.hobbyList = hobbyList
        }
        if let myNoticeBoardList {
            myInfo?.myNoticeBoardList = myNoticeBoardList
        }
        if let myCommentList {
            myInfo?.myCommentList = myCommentList
        }
        guard let idoUser = myInfo?.toIDoUser else { return }
        firebaseManager.updateUser(idoUser: idoUser) { isCompletion in
            if isCompletion {
                self.myUserInfo = myInfo
                completion?(isCompletion)
                return
            }
            completion?(false)
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
    
    func deleteAllUserData(completion: ((Bool) -> Void)? = nil) {
            // 먼저 프로필 이미지를 삭제합니다.
            deleteProfileImage { [weak self] success in
                guard success, let self = self else {
                    completion?(false)
                    return
                }
                
                // 프로필 이미지 삭제에 성공하면 사용자 데이터를 삭제합니다.
                if let idoUser = self.myUserInfo?.toIDoUser {
                    self.firebaseManager.deleteUser(idoUser: idoUser) { success in
                        if success {
                            self.myUserInfo = nil
                            self.fileCache.removeFile(uid: idoUser.id)
                            completion?(true)
                        }
                    }
                }
                else {
                    print("사용자 정보 삭제에 실패했습니다.")
                    completion?(false)
                }
            }
        }

    // 프로필 이미지 삭제
    private func deleteProfileImage(completion: ((Bool) -> Void)? = nil) {
        guard let uid = myUserInfo?.id else {
            print("UID가 존재하지 않아 프로필 이미지 삭제에 실패했습니다.")
            completion?(false)
            return
        }
        // 모든 이미지 사이즈에 대해 삭제를 진행합니다.
        ImageSize.allCases.forEach { imageSize in
            let storageRef = Storage.storage().reference().child("UserProfileImages/\(uid)/\(imageSize.rawValue)")
            storageRef.delete { error in
                if let error = error {
                    print("프로필 이미지(\(imageSize.rawValue)) 삭제 실패: \(error.localizedDescription)")
                    completion?(false)
                }
            }
        }
        completion?(true)
    }
}


