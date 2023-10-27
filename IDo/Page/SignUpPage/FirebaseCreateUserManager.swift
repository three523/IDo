//
//  FirebaseUserManager.swift
//  IDo
//
//  Created by 김도현 on 2023/10/26.
//

import FirebaseDatabase
import FirebaseStorage
import UIKit

class FirebaseCreateUserManager: FBDatabaseManager<IDoUser> {
    
    func addImage(uid: String, image: UIImage?, completion: ((Result<String, Error>) -> Void)? = nil) {
        guard let image else { return }
        if image == UIImage(systemName: "camera.circle.fill") { return }
        guard let smallImageData = image.resizeImage(targetSize: CGSize(width: 90, height: 90)).pngData(),
              let mediumImageData = image.resizeImage(targetSize: CGSize(width: 480, height: 480)).pngData() else { return }
        let datas = [smallImageData, mediumImageData]
        imageUpload(datas: datas, uid: uid)
        if let model {
            var myUserInfo = model.toMyUserInfo
            myUserInfo.profileImage[ImageSize.small.rawValue] = smallImageData
            myUserInfo.profileImage[ImageSize.medium.rawValue] = mediumImageData
            MyProfile.shared.saveMyUserInfo(myUserInfo: myUserInfo)
        }
    }
    
    private func imageUpload(datas: [Data], uid: String) {
        let imageSizes = ImageSize.allCases
        guard imageSizes.count == datas.count else {
            print("데이터 갯수와 이미지 사이즈 갯수가 맞지 않습니다.")
            return
        }
        
        let storageRef = Storage.storage().reference().child("UserProfileImages/\(uid)")
        let imageURL = storageRef.fullPath
        model?.profileImage = imageURL
        guard let model else { return }
        updateModel(data: model)
        
        for index in 0..<imageSizes.count {
            let imageSize = imageSizes[index]
            let imageData = datas[index]
            let storageSizeRef = storageRef.child(imageSize.rawValue)
            storageSizeRef.putData(imageData) { _, error in
                if let error {
                    print(error.localizedDescription)
                    return
                }
                print(storageSizeRef.fullPath)
            }
        }
    }
}
