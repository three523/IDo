//
//  NoticeBoardCRUD.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/19.
//

import Foundation
import Firebase

class FirebaseManager {

    
    static var noticeBoards: [NoticeBoard] = []
    
    static func createNoticeBoard(title: String, content: String) {
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
                
                // 새로운 NoticeBoard 객체 생성
                let newNoticeBoard = NoticeBoard(id: newNoticeBoardID, title: title, content: content)
                
                // noticeBoards 배열에 추가
                FirebaseManager.noticeBoards.append(newNoticeBoard)
            }
        }
    }

    static func readNoticeBoard() {
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

    
}
