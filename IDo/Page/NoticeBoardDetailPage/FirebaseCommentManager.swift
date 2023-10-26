//
//  File.swift
//  IDo
//
//  Created by 김도현 on 2023/10/19.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import UIKit

class FirebaseCommentManaer: FBDatabaseManager<Comment> {
    let noticeBoardRef: DatabaseReference
    let urlCache = FBURLCache.shared
    let storage = Storage.storage().reference()
    var currentIDoUser: IDoUser?
    var profileUpdate: ()->Void = {}

    init(refPath: [String], noticeBoard: NoticeBoard) {
        self.noticeBoardRef = Database.database().reference().child("noticeBoards").child(noticeBoard.clubID).child("\(noticeBoard.id)")
        super.init(refPath: refPath)
    }
    
    override func readDatas(completion: @escaping (Result<[Comment], Error>) -> Void = {_ in}) {
        ref.getData { error, dataSnapshot in
            if let error {
                let nsError = error as NSError
                if nsError.code == 1 { self.viewState = .error(true) }
                else { self.viewState = .error(false) }
                self.update()
                completion(.failure(error))
                return
            }
            guard let dataSnapshot else {
                self.viewState = .error(false)
                self.update()
                return
            }
            guard let value = dataSnapshot.value as? [String: Any] else {
                self.viewState = .loaded
                self.modelList = []
                completion(.success(self.modelList))
                return
            }
            let dataList: [Comment] = self.decodingDataSnapshot(value: value).sorted(by: { $0.createDate >= $1.createDate })
            self.viewState = .loaded
            self.modelList = dataList
            completion(.success(dataList))
        }
    }
    
    func noticeBoardUpdate(completion: ((Bool) -> Void)? = nil) {
        noticeBoardRef.updateChildValues(["commentCount": "\(modelList.count)"]) { error, _ in
            if let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func getMyProfileImage(uid: String, imageSize: UserImageSize, completion: @escaping (UIImage?)->Void ) {
        let myProfileRef = Database.database().reference().child("Users").child(uid)
        myProfileRef.getData { error, dataSnapShot in
            if let error {
                print(error.localizedDescription)
            }
            guard let value = dataSnapShot?.value,
                let idoUser: IDoUser = self.decodingSingleDataSnapshot(value: value) else { return }
            self.currentIDoUser = idoUser
            self.getUserImage(referencePath: idoUser.profileImage, imageSize: imageSize) { profileImage in
                completion(profileImage)
            }
        }
    }
    
    func getUserImage(referencePath: String?, imageSize: UserImageSize, completion: @escaping(UIImage?) -> Void) {
        guard let referencePath else { return }
        let imageRef = storage.child(referencePath).child(imageSize.rawValue)
        imageRef.downloadURL { url, error in
            if let error {
                print(error)
            }
            guard let url else { return }
            self.urlCache.downloadURL(url: url) { result in
                switch result {
                case .success(let image):
                    completion(image)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}
