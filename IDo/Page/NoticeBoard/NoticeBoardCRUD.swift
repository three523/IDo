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
    
    private func saveNoticeBoard(id: String, title: String, content: String, completion: ((Bool) -> Void)? = nil) {
        let ref = Database.database().reference().child("noticeBoards").child(id)
        let noticeBoardDict: [String: Any] = [
            "id": id,
            "title": title,
            "content": content
        ]
        
        ref.setValue(noticeBoardDict) { error, _ in
            if let error = error {
                print("Error saving notice board: \(error)")
                completion?(false)
            } else {
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
        
        saveNoticeBoard(id: newNoticeBoardID, title: title, content: content) { success in
            if success {
                // 새로운 NoticeBoard 객체 생성
                let newNoticeBoard = NoticeBoard(id: newNoticeBoardID, title: title, content: content)
                
                // noticeBoards 배열에 추가
                FirebaseManager.noticeBoards.append(newNoticeBoard)
                self.delegate?.reloadData()
            }
        }
    }
    
    func readNoticeBoard() {
        let ref = Database.database().reference().child("noticeBoards")
        
        ref.observe(.value, with: { (snapshot) in
            var newNoticeBoards: [NoticeBoard] = []
            
            guard let value = snapshot.value as? [[String: Any]] else { return }
            
            for item in value {
                let id = item["id"] as? String ?? ""
                let title = item["title"] as? String ?? ""
                let content = item["content"] as? String ?? ""
                
                let noticeBoard = NoticeBoard(id: id, title: title, content: content)
                newNoticeBoards.append(noticeBoard)
            }
            
            FirebaseManager.noticeBoards = newNoticeBoards
            
            self.delegate?.reloadData()
        })
    }

    
    func updateNoticeBoard(at index: Int, title newTitle: String, content newContent: String) {
        if index >= 0 && index < FirebaseManager.noticeBoards.count {
            let noticeBoardID = FirebaseManager.noticeBoards[index].id
            saveNoticeBoard(id: noticeBoardID, title: newTitle, content: newContent) { success in
                if success {
                    FirebaseManager.noticeBoards[index].title = newTitle
                    FirebaseManager.noticeBoards[index].content = newContent
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
