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
    let storage = Storage.storage().reference()
    var currentIDoUser: IDoUser?
    var profileUpdate: ()->Void = {}

    init(refPath: [String], noticeBoard: NoticeBoard) {
        self.noticeBoardRef = Database.database().reference().child("noticeBoards").child("\(noticeBoard.id)")
        super.init(refPath: refPath)
    }
    
    override func readDatas(completion: @escaping (Result<[Comment], Error>) -> Void = {_ in}) {
        ref.getData { error, dataSnapshot in
            if let error {
                let nsError = error as NSError
                if nsError.code == 1 { self.viewState = .error(true) }
                else { self.viewState = .error(false) }
                self.update()
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
                return
            }
            let dataList: [Comment] = self.decodingDataSnapshot(value: value).sorted(by: { $0.createDate <= $1.createDate })
            self.viewState = .loaded
            self.modelList = dataList
        }
    }
    
    func noticeBoardUpdate(completion: ((Bool) -> Void)? = nil) {
        noticeBoardRef.updateChildValues(["commentCount": "\(modelList.count)"]) { error, _ in
            if let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func getMyProfileImage(uid: String, completion: @escaping (UIImage?)->Void ) {
        let myProfileRef = Database.database().reference().child("Users").child(uid)
        myProfileRef.getData { error, dataSnapShot in
            if let error {
                print(error.localizedDescription)
            }
            guard let value = dataSnapShot?.value,
                let idoUser: IDoUser = self.decodingSingleDataSnapshot(value: value) else { return }
            self.currentIDoUser = idoUser
            self.getUserImage(referencePath: idoUser.profileImage) { profileImage in
                completion(profileImage)
            }
        }
    }
    
    func getUserImage(referencePath: String?, completion: @escaping(UIImage?) -> Void) {
        guard let referencePath else { return }
        let imageRef = storage.child(referencePath)
        imageRef.downloadURL { url, error in
            if let error {
                print(error)
            }
            guard let url else { return }
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error {
                    print(error.localizedDescription)
                }
                guard let data else { return }
                completion(UIImage(data: data))
            }.resume()
        }
    }
}
