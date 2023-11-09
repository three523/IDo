//
//  MyProfileUpdateManager.swift
//  IDo
//
//  Created by 김도현 on 2023/11/08.
//

import FirebaseDatabase

class MyProfileUpdateManager: FBDatabaseManager<IDoUser> {
    private let defaultRef = Database.database().reference()
    
    func updateUser(idoUser: IDoUser, completion: ((Bool) -> Void)?) {
        updateValue(value: idoUser) { isSuccess in
            if isSuccess {
                idoUser.myClubList?.forEach({ club in
                    self.updateClub(idoUser: idoUser, club: club)
                })
                idoUser.myNoticeBoardList?.forEach({ noticeBoard in
                    self.updateNoticeBoard(noticeBoard: noticeBoard, idoUser: idoUser)
                })
                idoUser.myCommentList?.forEach({ comment in
                    self.updateComment(comment: comment, idoUser: idoUser)
                })
                completion?(true)
            }
        }
    }
    
    private func updateClub(idoUser: IDoUser, club: Club, completion: ((Bool) -> Void)? = nil) {
        let clubUserRef = defaultRef.child(club.category).child("meetings").child(club.id).child("userList")
        
        clubUserRef.getData { error, dataSnapShot in
            if let error {
                print(error.localizedDescription)
                completion?(false)
                return
            }
            guard let dataSnapShot = dataSnapShot?.value as? Array<Any> else {
                print("데이터가 존재하지 않습니다.")
                return
            }
            var idoUsers: [UserSummary] = dataSnapShot.compactMap{ DataModelCodable.decodingSingleDataSnapshot(value: $0)}
            guard let index = idoUsers.firstIndex(where: { $0.id == idoUser.id }) else {
                print("내 유저 정보를 찾을수 없습니다")
                return
            }
            clubUserRef.updateChildValues(["\(index)": idoUser.toUserSummary.dictionary as Any]) { error, _ in
                if let error {
                    print(error.localizedDescription)
                    completion?(false)
                    return
                }
                completion?(true)
            }
        }
        
        let clubRootUserRef = defaultRef.child(club.category).child("meetings").child(club.id).child("rootUser")
        
        clubRootUserRef.getData { error, dataSnapShot in
            if let error {
                print(error.localizedDescription)
                return
            }
            guard let dataSnapShot = dataSnapShot?.value else {
                print("데이터가 존재하지 않습니다.")
                return
            }
            
            guard let rootUser: IDoUser = DataModelCodable.decodingSingleDataSnapshot(value: dataSnapShot) else {
                print("iDoUser 데이터를 가져오지 못합니다")
                return
            }
            if idoUser.id == rootUser.id {
                clubRootUserRef.setValue(idoUser.toUserSummary.dictionary) { error, _ in
                    if let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func updateNoticeBoard(noticeBoard: NoticeBoard, idoUser: IDoUser) {
        let noticeBoardRef = defaultRef.child("noticeBoards").child(noticeBoard.clubID).child(noticeBoard.id)
        noticeBoardRef.getData { error, dataSnapShot in
            if let error {
                print(error.localizedDescription)
                return
            }
            guard let dataSnapShot = dataSnapShot?.value else {
                print("게시판 데이터를 가져오지 못했습니다")
                return
            }
            guard let noticeBoard: NoticeBoard = DataModelCodable.decodingSingleDataSnapshot(value: dataSnapShot) else {
                print("datasnapshot을 게시판으로 디코딩하지 못했습니다")
                return
            }
            let noticeBoardRootUserRef = noticeBoardRef.child("rootUser")
            noticeBoardRootUserRef.setValue(idoUser.toUserSummary.dictionary) { error, _ in
                if let error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func updateComment(comment: Comment, idoUser: IDoUser) {
        let commentRef = defaultRef.child("CommentList").child(comment.noticeBoardID).child(comment.id).child("writeUser")
        commentRef.setValue(idoUser.toUserSummary.dictionary) { error, _ in
            if let error {
                print(error.localizedDescription)
            }
        }
    }
}
