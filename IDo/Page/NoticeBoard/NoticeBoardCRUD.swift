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
    var noticeBoards: [NoticeBoard] = []
    
    func createNoticeBoard(title: String, content: String) {
        let ref = Database.database().reference().child("noticeBoards")
        let newNoticeBoardID = ref.childByAutoId().key ?? ""
        
        // NoticeBoard 객체를 [String: Any] 형태로 변환
        let noticeBoardDict: [String: Any] = [
            "id": newNoticeBoardID,
            "title": title,
            "content": content
        ]
        
        // 데이터 저장
        ref.child(newNoticeBoardID).setValue(noticeBoardDict) { error, _ in
            if let error = error {
                print("Error saving notice board: \(error)")
            } else {
                print("Successfully saved notice board.")
                
                self.addNoticeBoards(id: newNoticeBoardID, title: title, content: content)
            }
        }
        delegate?.reloadData()
    }
    
    func addNoticeBoards(id newID: String, title newTitle: String, content newContent: String) {
        // 새로운 NoticeBoard 객체 생성
        let newNoticeBoard = NoticeBoard(id: newID, title: newTitle, content: newContent)
        
        // noticeBoards 배열에 추가
        noticeBoards.append(newNoticeBoard)
    }

    func readNoticeBoard() {
        let ref = Database.database().reference().child("noticeBoards")
        
        // 2. 데이터 읽기
        ref.observe(.value, with: { (snapshot) in
            guard let value = snapshot.value as? [[String: Any]] else { return }
            
            for item in value {
                let id = item["id"] as? String ?? ""
                let title = item["title"] as? String ?? ""
                let content = item["content"] as? String ?? ""
            }
        })
    }
    
    func updateNoticeBoard(at index: Int, title newTitle: String, content newContent: String) {
        if index >= 0 && index < noticeBoards.count {
            noticeBoards[index].title = newTitle
            noticeBoards[index].content = newContent
            
            let ref = Database.database().reference().child("noticeBoards").child(noticeBoards[index].id)
            ref.updateChildValues(["title": newTitle, "content": newContent]) { error, _ in
                if let error = error {
                    print("Error updating notice board: \(error)")
                } else {
                    print("Successfully updated notice board.")
                }
            }
        }
    }
}
