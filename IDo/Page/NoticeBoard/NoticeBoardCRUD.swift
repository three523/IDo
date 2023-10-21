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
        let noticeBoardDict: [String: Any] = [
            "id": noticeBoard.id,
            "title": noticeBoard.title,
            "content": noticeBoard.content,
            "createDate": noticeBoard.createDate.timeIntervalSince1970
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
    
//    func addNoticeBoards(id newID: String, title newTitle: String, content newContent: String) {
//        // 새로운 NoticeBoard 객체 생성
//        let newNoticeBoard = NoticeBoard(id: newID, title: newTitle, content: newContent)
//        
//        // noticeBoards 배열에 추가
//        FirebaseManager.noticeBoards.append(newNoticeBoard)
//    
//    }
    
    func createNoticeBoard(title: String, content: String) {
        let ref = Database.database().reference().child("noticeBoards")
        let newNoticeBoardID = ref.childByAutoId().key ?? ""
        let createDate = Date()

        let newNoticeBoard = NoticeBoard(id: newNoticeBoardID, createDate: createDate, title: title, content: content)
        
        saveNoticeBoard(noticeBoard: newNoticeBoard) { success in
            if success {
                // noticeBoards 배열에 추가
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
                   let title = itemDict["title"] as? String,
                   let content = itemDict["content"] as? String,
                   let createDateTimestamp = itemDict["createDate"] as? TimeInterval {
                    
                    let createDate = Date(timeIntervalSince1970: createDateTimestamp)
                    let noticeBoard = NoticeBoard(id: id, createDate: createDate, title: title, content: content)
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
                } else {
                    print("Successfully deleted notice board.")
                    FirebaseManager.noticeBoards.remove(at: index)
                    completion?(true)
                }
            }
        } else {
            completion?(false)
        }
    }
}
