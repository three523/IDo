//
//  NoticeBoardCRUD.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/19.
//

import Foundation
import Firebase

class FirebaseManager {
//    func createNoticeBoard(noticeBoard: NoticeBoard) {
//        // 레퍼런스 설정
//        let ref = Database.database().reference().child("noticeBoards")
//        
//        // NoticeBoard 객체를 [String: Any] 형태로 변환
//        let noticeBoardDict: [String: Any] = [
//            "id": ref.childByAutoId().key ?? "",
//            "rootUser": [
//                "id": noticeBoard.rootUser.id,
//                "profileImage": String(data: noticeBoard.rootUser.profileImage!, encoding: .utf8) ?? "",
//                "nickName": noticeBoard.rootUser.nickName
//            ],
//            "createDate": noticeBoard.createDate.timeIntervalSince1970,
//            "clubID": noticeBoard.clubID,
//            "title": noticeBoard.title,
//            "content": noticeBoard.content,
//            "imageList": noticeBoard.imageList.map { String(data: $0, encoding: .utf8) ?? "" },
//            "commentList": noticeBoard.commentList ?? ""
//        ]
//        
//        // 데이터 저장
//        ref.setValue(noticeBoardDict) { error, _ in
//            if let error = error {
//                print("Error saving notice board: \(error)")
//            } else {
//                print("Successfully saved notice board.")
//            }
//        }
//    }
    
//    func readNoticeBoards(completion: @escaping ([NoticeBoard]) -> Void) {
//        // 1. Reference 설정
//        let ref = Database.database().reference().child("noticeBoards")
//        
//        // 2. 데이터 읽기
//        ref.observeSingleEvent(of: .value, with: { (snapshot) in
//            guard let value = snapshot.value as? [[String: Any]] else {
//                completion([])
//                return
//            }
//            
//            // 3. 데이터 변환
//            var noticeBoards: [NoticeBoard] = []
//            
//            for item in value {
//                guard let id = item["id"] as? String,
//                      let rootUserData = item["rootUser"] as? [String: Any],
//                      let rootUserId = rootUserData["id"] as? String,
//                      let rootUserNickName = rootUserData["nickName"] as? String,
//                      let createDateTimestamp = item["createDate"] as? TimeInterval,
//                      let clubID = item["clubID"] as? String,
//                      let content = item["content"] as? String,
//                      let title = item["title"] as? String else {
//                    continue
//                }
//                
//                let rootUser = IDoUser(
//                    id: rootUserId,
//                    profileImage: (rootUserData["profileImage"] as? String)?.data(using: .utf8),
//                    nickName: rootUserNickName,
//                    description: rootUserData["description"] as? String,
//                    hobbyList: [],
//                    myClubList: [],
//                    myNoticeBoardList: [],
//                    myCommentList: []
//                )
//                
//                let noticeBoard = NoticeBoard(
//                    id: id,
//                    rootUser: rootUser,
//                    createDate: Date(timeIntervalSince1970: createDateTimestamp),
//                    clubID: clubID,
//                    title: title,
//                    content: content,
//                    imageList: (item["imageList"] as? [String])?.compactMap { $0.data(using: .utf8) } ?? [],
//                    commentList: []
//                )
//                
//                noticeBoards.append(noticeBoard)
//            }
//            
//            completion(noticeBoards)
//        })
//    }
    
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
//                let newNoticeBoard = NoticeBoard(id: newNoticeBoardID, title: title, content: content)
//                
//                // noticeBoards 배열에 추가
//                FirebaseManager.noticeBoards.append(newNoticeBoard)
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
