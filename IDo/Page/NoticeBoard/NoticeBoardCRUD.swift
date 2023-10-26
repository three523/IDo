//
//  NoticeBoardCRUD.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/19.
//

import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import Foundation
import UIKit


protocol FirebaseManagerDelegate: AnyObject {
    func reloadData()
    func updateComment(noticeBoardID: String, commentCount: String)
}

// completion을 escaping으로 바꾸기
// image URL 업로드

class FirebaseManager {
    weak var delegate: FirebaseManagerDelegate?

    var noticeBoards: [NoticeBoard] = []
    var selectedImage: [UIImage] = []
    
    // MARK: - 데이터 저장

    func saveNoticeBoard(noticeBoard: NoticeBoard, completion: ((Bool) -> Void)? = nil) {
        let ref = Database.database().reference().child("noticeBoards").child(noticeBoard.clubID).child(noticeBoard.id)
        
        // UserSummary
        let userSummaryDict: [String: Any?] = [
            "id": noticeBoard.rootUser.id,
            "profileImage": noticeBoard.rootUser.profileImageURL,
            "nickName": noticeBoard.rootUser.nickName
        ]
        
        // NoticeBoard
        let noticeBoardDict: [String: Any] = [
            "id": noticeBoard.id,
            "clubID": noticeBoard.clubID,
            "rootUser": userSummaryDict,
            "title": noticeBoard.title,
            "content": noticeBoard.content,
            "createDate": noticeBoard.createDate.dateToString,
            "imageList": noticeBoard.imageList,
            "commentCount": noticeBoard.commentCount
        ]
        
        ref.setValue(noticeBoardDict) { error, _ in
            if let error = error {
                print("Error saving notice board: \(error)")
                completion?(false)
            }
            else {
                print("Successfully saved notice board.")
                completion?(true)
            }
        }
    }
    
    // MARK: - 데이터 생성

    func createNoticeBoard(title: String, content: String, clubID: String, completion: @escaping (Bool) -> Void) {
        let ref = Database.database().reference().child("noticeBoards").child(clubID)
        let newNoticeBoardID = ref.childByAutoId().key ?? ""
        
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        let currentUser = UserSummary(id: currentUserID, profileImageURL: nil, nickName: "파이브 아이즈")
        
        self.uploadImages(clubID: clubID, noticeBoardID: newNoticeBoardID, imageList: self.selectedImage) { success, imageURLs in
            if success {
                let createDate = Date()
                let newNoticeBoard = NoticeBoard(id: newNoticeBoardID, rootUser: currentUser, createDate: createDate, clubID: clubID, title: title, content: content, imageList: imageURLs ?? [], commentCount: "0")
                
                self.saveNoticeBoard(noticeBoard: newNoticeBoard) { success in
                    if success {
                        self.noticeBoards.insert(newNoticeBoard, at: 0)
                        self.delegate?.reloadData()
                    }
                    completion(success)
                }
            } else {
                completion(false)
            }
        }
    }

    // MARK: - 데이터 읽기
    func readNoticeBoard(clubID: String, completion: ((Bool) -> Void)? = nil) {
        
        let ref = Database.database().reference().child("noticeBoards").child(clubID)
        
        ref.getData(completion: { (error, snapshot) in
            var newNoticeBoards: [NoticeBoard] = []
            
            if let error = error {
                print("Error getting data: \(error)")
                completion?(false)
                return
            }
            
            guard let value = snapshot?.value as? [String: Any] else {
                self.delegate?.reloadData()
                completion?(false)
                return
            }
            
            for (_, item) in value {
                if let itemDict = item as? [String: Any],
                   let id = itemDict["id"] as? String,
                   let clubID = itemDict["clubID"] as? String,
                   let rootUserDict = itemDict["rootUser"] as? [String: Any],
                   let rootUserId = rootUserDict["id"] as? String,
                   let rootUserNickName = rootUserDict["nickName"] as? String,
                   let title = itemDict["title"] as? String,
                   let content = itemDict["content"] as? String,
                   let createDateStr = itemDict["createDate"] as? String,
                   let createDate = createDateStr.toDate,
                   let commentCount = itemDict["commentCount"] as? String
                {
                    let profileImageString = rootUserDict["profileImage"] as? String
                    
                    let rootUser = UserSummary(id: rootUserId, profileImageURL: profileImageString, nickName: rootUserNickName)
                    
                    let imageList = itemDict["imageList"] as? [String] ?? []
                    
                    let noticeBoard = NoticeBoard(id: id, rootUser: rootUser, createDate: createDate, clubID: clubID, title: title, content: content, imageList: imageList, commentCount: commentCount)
                    newNoticeBoards.append(noticeBoard)
                }
            }
            
            self.noticeBoards = newNoticeBoards.sorted(by: { $0.createDate > $1.createDate })
            
            self.delegate?.reloadData()
            completion?(true)
        })
    }

    // MARK: - 데이터 업데이트

    func updateNoticeBoard(at index: Int, title newTitle: String, content newContent: String, completion: @escaping (Bool) -> Void) {
        if index >= 0, index < self.noticeBoards.count {
            var updatedNoticeBoard = self.noticeBoards[index]
            updatedNoticeBoard.title = newTitle
            updatedNoticeBoard.content = newContent
            
//            self.saveNoticeBoard(noticeBoard: updatedNoticeBoard) { success in
//                if success {
//                    self.noticeBoards[index] = updatedNoticeBoard
//                    self.delegate?.reloadData()
//                }
//            }
            self.uploadImages(clubID: self.noticeBoards[index].clubID, noticeBoardID: self.noticeBoards[index].id, imageList: self.selectedImage) { success, imageURLs in
                if success {
                    
                    self.saveNoticeBoard(noticeBoard: updatedNoticeBoard) { success in
                        if success {
                            self.noticeBoards[index] = updatedNoticeBoard
                            self.delegate?.reloadData()
                        }
                        completion(success)
                    }
                } else {
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - 데이터 삭제

    func deleteNoticeBoard(at index: Int, completion: ((Bool) -> Void)? = nil) {
        if index >= 0, index < self.noticeBoards.count {
            let noticeBoardID = self.noticeBoards[index].id
            let ref = Database.database().reference().child("noticeBoards").child(noticeBoards[index].clubID).child(noticeBoardID)
            
            ref.removeValue { error, _ in
                if let error = error {
                    print("Error deleting notice board: \(error)")
                    completion?(false)
                }
                else {
                    print("Successfully deleted notice board.")
                    self.noticeBoards.remove(at: index)
                    self.delegate?.reloadData()
                    completion?(true)
                }
            }
        }
        else {
            completion?(false)
        }
    }
    
    // MARK: - 이미지 업로드
    func uploadImages(clubID: String, noticeBoardID: String, imageList: [UIImage], completion: @escaping (Bool, [String]?) -> Void) {
        let storageRef = Storage.storage().reference().child("noticeBoards").child(clubID).child(noticeBoardID).child("images")
        var imageURLs: [String] = []
        
        let dispatchGroup = DispatchGroup()
        
        for (index, image) in imageList.enumerated() {
            dispatchGroup.enter()
            let imageName = "\(index)_\(UUID().uuidString)"
            let ref = storageRef.child(imageName)
            
            if let uploadData = image.jpegData(compressionQuality: 0.5) {
                ref.putData(uploadData, metadata: nil) { _, error in
                    if let error = error {
                        print("Failed to upload image:", error)
                    } else {
                        // fullPath 속성을 사용하여 참조 경로를 저장
                        let fullPath = ref.fullPath
                        imageURLs.append(fullPath)
                    }
                    dispatchGroup.leave()
                }
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(imageURLs.count == imageList.count, imageURLs.sorted())
        }
    }
    
    // MARK: - 이미지 다운로드
    func downloadImages(imagePaths: [String], completion: @escaping ([UIImage]?) -> Void) {
        let storageRef = Storage.storage().reference()
        var downloadedImages: [UIImage] = []
        var imageDict: [String: UIImage] = [:]
        
        let sortedPaths = imagePaths.sorted()
        let dispatchGroup = DispatchGroup()
        
        for path in sortedPaths {
            dispatchGroup.enter()
            let ref = storageRef.child(path)
            
            ref.downloadURL { url, error in
                if let error = error {
                    print("URL 가져오기 실패: \(error)")
                    dispatchGroup.leave()
                } else if let url = url {
                    FBURLCache.shared.downloadURL(url: url) { result in
                        switch result {
                        case .success(let image):
                            imageDict[path] = image
                        case .failure(let error):
                            print("이미지 다운로드 실패: \(error)")
                        }
                        dispatchGroup.leave()
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            for path in sortedPaths {
                if let image = imageDict[path] {
                    downloadedImages.append(image)
                }
            }
            
            if !downloadedImages.isEmpty {
                self.selectedImage = downloadedImages
                self.delegate?.reloadData()
            }
            completion(downloadedImages.isEmpty ? nil : downloadedImages)
        }
    }
    
    // MARK: - 이미지 삭제
    func deleteImage(imagePath: String, completion: @escaping (Bool, Error?) -> Void) {
        let storageRef = Storage.storage().reference()
        let ref = storageRef.child(imagePath)
        
        ref.delete { error in
            if let error = error {
                print("이미지 삭제 실패: \(error)")
                completion(false, error)
            } else {
                print("이미지 삭제 성공")
                completion(true, nil)
            }
        }
    }
}
