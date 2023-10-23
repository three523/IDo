//
//  NoticeBoardCRUD.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/19.
//

import FirebaseDatabase
import FirebaseStorage
import Foundation
import UIKit

protocol FirebaseManagerDelegate: AnyObject {
    func reloadData()
}

// 매개변수를 noticBoard로 통일
// completion을 escaping으로 바꾸기
// image URL 업로드

class FirebaseManager {
    weak var delegate: FirebaseManagerDelegate?

    var noticeBoards: [NoticeBoard] = []
    
    // MARK: - 데이터 저장

    func saveNoticeBoard(noticeBoard: NoticeBoard, completion: ((Bool) -> Void)? = nil) {
        let ref = Database.database().reference().child("noticeBoards").child(noticeBoard.id)
        
        // UserSummary
        let userSummaryDict: [String: Any?] = [
            "id": noticeBoard.rootUser.id,
            "profileImage": noticeBoard.rootUser.profileImageURL,
            "nickName": noticeBoard.rootUser.nickName,
            "description": noticeBoard.rootUser.description
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

    // 임시 작성 유저 정보
    let currentUser = UserSummary(id: "currentUser", profileImageURL: nil, nickName: "파이브 아이즈", description: "This is the current user.")

    func createNoticeBoard(title: String, content: String, clubID: String) {
        let ref = Database.database().reference().child("noticeBoards")
        let newNoticeBoardID = ref.childByAutoId().key ?? ""
        let createDate = Date()

        let newNoticeBoard = NoticeBoard(id: newNoticeBoardID, rootUser: currentUser, createDate: createDate, clubID: clubID, title: title, content: content, imageList: [], commentCount: "0")
        
        self.saveNoticeBoard(noticeBoard: newNoticeBoard) { success in
            if success {
//                FirebaseManager.noticeBoards.insert(newNoticeBoard, at: 0)
                self.delegate?.reloadData()
            }
        }
    }
    // MARK: - 데이터 읽기

    func readNoticeBoard() {
        let ref = Database.database().reference().child("noticeBoards")
        
        ref.observe(.value, with: { snapshot in
            var newNoticeBoards: [NoticeBoard] = []
            
            guard let value = snapshot.value as? [String: Any] else { return }
            
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
                    
                    let rootUser = UserSummary(id: rootUserId, profileImageURL: profileImageString, nickName: rootUserNickName, description: rootUserDict["description"] as? String)
                    
                    let imageList = itemDict["imageList"] as? [String] ?? []
                    
                    let noticeBoard = NoticeBoard(id: id, rootUser: rootUser, createDate: createDate, clubID: clubID, title: title, content: content, imageList: imageList, commentCount: commentCount)
                    newNoticeBoards.append(noticeBoard)
                }
            }
            
            self.noticeBoards = newNoticeBoards.sorted(by: { $0.createDate > $1.createDate })
            
            self.delegate?.reloadData()
            print("오류 테스트")
        })
    }

    // MARK: - 데이터 업데이트

    func updateNoticeBoard(at index: Int, title newTitle: String, content newContent: String) {
        if index >= 0, index < self.noticeBoards.count {
            var updatedNoticeBoard = self.noticeBoards[index]
            updatedNoticeBoard.title = newTitle
            updatedNoticeBoard.content = newContent
            
            self.saveNoticeBoard(noticeBoard: updatedNoticeBoard) { success in
                if success {
                    self.noticeBoards[index] = updatedNoticeBoard
                    self.delegate?.reloadData()
                }
            }
        }
    }
    
    // MARK: - 데이터 삭제

    func deleteNoticeBoard(at index: Int, completion: ((Bool) -> Void)? = nil) {
        if index >= 0, index < self.noticeBoards.count {
            let noticeBoardID = self.noticeBoards[index].id
            let ref = Database.database().reference().child("noticeBoards").child(noticeBoardID)
            
            ref.removeValue { error, _ in
                if let error = error {
                    print("Error deleting notice board: \(error)")
                    completion?(false)
                }
                else {
                    print("Successfully deleted notice board.")
                    self.noticeBoards.remove(at: index)
                    completion?(true)
                }
            }
        }
        else {
            completion?(false)
        }
    }
    
    // MARK: - 이미지 업로드 & 다운로드

    func uploadImages(_ images: [UIImage], completion: @escaping ([String]) -> Void) {
        let storageRef = Storage.storage().reference().child("images")
        var imageURLs: [String] = []
        
        let dispatchGroup = DispatchGroup()
        
        for image in images {
            dispatchGroup.enter()
            let imageName = UUID().uuidString
            let ref = storageRef.child(imageName)
            
            if let uploadData = image.jpegData(compressionQuality: 0.5) {
                ref.putData(uploadData, metadata: nil) { _, error in
                    if error != nil {
                        print("Failed to upload image:", error!)
                        dispatchGroup.leave()
                        return
                    }
                    
                    ref.downloadURL { url, _ in
                        if let imageUrl = url?.absoluteString {
                            imageURLs.append(imageUrl)
                        }
                        dispatchGroup.leave()
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(imageURLs)
        }
    }
}
