//
//  FirebaseNoticeBoardManager.swift
//  IDo
//
//  Created by 김도현 on 2023/10/19.
//

import FirebaseDatabase
import Foundation

class FirebaseUserDatabaseManager: FBDatabaseManager<IDoUser> {
    
    func updateAddClub(club: Club, compeltion: (() -> Void)? = nil) {
        guard var model else { return }
        var clubList = [Club]()
        if let myClubList = model.myClubList {
            clubList = myClubList
        }
        if clubList.contains(where: { $0.id == club.id }) { return }
        clubList.append(club)
        self.model?.myClubList = clubList
        ref.child("myClubList").setValue(self.model?.myClubList?.asArrayDictionary())
        compeltion?()
    }
    func addMyNoticeBoard(noticeBoard: NoticeBoard, completion: (() -> Void)? = nil) {
        guard var model else { return }
        var noticeBoardList = [NoticeBoard]()
        if let myNoticeBoardList = model.myNoticeBoardList {
            noticeBoardList = myNoticeBoardList
        }
        if noticeBoardList.contains(where: { $0.id == noticeBoard.id }) { return }
        noticeBoardList.append(noticeBoard)
        self.model?.myNoticeBoardList = noticeBoardList
        ref.child("myNoticeBoardList").setValue(self.model?.myNoticeBoardList?.asArrayDictionary())
        completion?()
    }
    func updateMyNoticeBoard(noticeBoard: NoticeBoard, completion: (() -> Void)? = nil) {
        guard var model else { return }
        var noticeBoardList = [NoticeBoard]()
        if let myNoticeBoardList = model.myNoticeBoardList {
            noticeBoardList = myNoticeBoardList
        }
        guard let index = noticeBoardList.firstIndex(where: { $0.id == noticeBoard.id }) else { return }
        noticeBoardList[index] = noticeBoard
        self.model?.myNoticeBoardList = noticeBoardList
        ref.child("myNoticeBoardList").updateChildValues([String(index): noticeBoard.dictionary])
        completion?()
    }
    func removeMyNoticeBoard(noticeBoard: NoticeBoard, completion: (() -> Void)? = nil) {
        guard var model else { return }
        var noticeBoardList = [NoticeBoard]()
        if let myNoticeBoardList = model.myNoticeBoardList {
            noticeBoardList = myNoticeBoardList
        }
        noticeBoardList.removeAll(where: { $0.id == noticeBoard.id })
        self.model?.myNoticeBoardList = noticeBoardList
        ref.child("myNoticeBoardList").setValue(self.model?.myNoticeBoardList?.asArrayDictionary())
        completion?()
    }
}
