//
//  NoticeBoardCRUD.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/19.
//

import Foundation
import Firebase


protocol FirebaseManagerDelegate: AnyObject {
    func reloadData()
}

class FirebaseManager {
    
    weak var delegate: FirebaseManagerDelegate?
    static var noticeBoards: [NoticeBoard] = []
    
    func saveNoticeBoard(noticeBoard: NoticeBoard, completion: ((Bool) -> Void)? = nil) {
        let ref = Database.database().reference().child("noticeBoards").child(noticeBoard.id)
        
        // UserSummary
        let userSummaryDict: [String: Any?] = [
            "id": noticeBoard.rootUser.id,
            "profileImage": noticeBoard.rootUser.profileImage?.base64EncodedString(),
            "nickName": noticeBoard.rootUser.nickName,
            "description": noticeBoard.rootUser.description
        ]
        
        // NoticeBoard
        let noticeBoardDict: [String: Any] = [
            "id": noticeBoard.id,
            "rootUser": userSummaryDict,
            "title": noticeBoard.title,
            "content": noticeBoard.content,
            "createDate": noticeBoard.createDate.dateToString
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
    
    // 임시 작성 유저 정보
    let currentUser = UserSummary(id: "currentUser", profileImage: nil, nickName: "파이브 아이즈", description: "This is the current user.")

    func createNoticeBoard(title: String, content: String) {
        let ref = Database.database().reference().child("noticeBoards")
        let newNoticeBoardID = ref.childByAutoId().key ?? ""
        let createDate = Date()

        let newNoticeBoard = NoticeBoard(id: newNoticeBoardID, rootUser: currentUser, createDate: createDate, title: title, content: content)
        
        saveNoticeBoard(noticeBoard: newNoticeBoard) { success in
            if success {
                FirebaseManager.noticeBoards.insert(newNoticeBoard, at: 0)
                self.delegate?.reloadData()
            }
        }
    }
    
    func readNoticeBoard() {
        let ref = Database.database().reference().child("noticeBoards")
        
        ref.observe(.value, with: { (snapshot) in
            var newNoticeBoards: [NoticeBoard] = []
            
            guard let value = snapshot.value as? [String: Any] else { return }
            
            for (_, item) in value {
                if let itemDict = item as? [String: Any],
                   let id = itemDict["id"] as? String,
                   let rootUserDict = itemDict["rootUser"] as? [String: Any],
                   let rootUserId = rootUserDict["id"] as? String,
                   let rootUserNickName = rootUserDict["nickName"] as? String,
                   let title = itemDict["title"] as? String,
                   let content = itemDict["content"] as? String,
                   let createDateStr = itemDict["createDate"] as? String,
                   let createDate = createDateStr.toDate {
                    
                    var profileImageData: Data? = nil
                    if let profileImageString = rootUserDict["profileImage"] as? String {
                        profileImageData = Data(base64Encoded: profileImageString)
                    }
                    
                    let rootUser = UserSummary(id: rootUserId, profileImage: profileImageData, nickName: rootUserNickName, description: rootUserDict["description"] as? String)
                    
                    let noticeBoard = NoticeBoard(id: id, rootUser: rootUser, createDate: createDate, title: title, content: content)
                    newNoticeBoards.append(noticeBoard)
                }
            }
            
            FirebaseManager.noticeBoards = newNoticeBoards.sorted(by: { $0.createDate > $1.createDate })
            
            self.delegate?.reloadData()
        })
    }

    
    func updateNoticeBoard(at index: Int, title newTitle: String, content newContent: String) {
        if index >= 0 && index < FirebaseManager.noticeBoards.count {
            var updatedNoticeBoard = FirebaseManager.noticeBoards[index]
            updatedNoticeBoard.title = newTitle
            updatedNoticeBoard.content = newContent
            
            saveNoticeBoard(noticeBoard: updatedNoticeBoard) { success in
                if success {
                    FirebaseManager.noticeBoards[index] = updatedNoticeBoard
                    self.delegate?.reloadData()
                }
            }
        }
    }
    
    func deleteNoticeBoard(at index: Int, completion: ((Bool) -> Void)? = nil) {
        if index >= 0 && index < FirebaseManager.noticeBoards.count {
            let noticeBoardID = FirebaseManager.noticeBoards[index].id
            let ref = Database.database().reference().child("noticeBoards").child(noticeBoardID)
            
            ref.removeValue { error, _ in
                if let error = error {
                    print("Error deleting notice board: \(error)")
                    completion?(false)
                }
                else {
                    print("Successfully deleted notice board.")
                    FirebaseManager.noticeBoards.remove(at: index)
                    completion?(true)
                }
            }
        } 
        else {
            completion?(false)
        }
    }
}
