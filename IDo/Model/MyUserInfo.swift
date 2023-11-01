//
//  MyUserInfo.swift
//  IDo
//
//  Created by 김도현 on 2023/10/26.
//

import UIKit

struct MyUserInfo: Codable {
    let id: String
    var updateAt: String?
    var profileImageURL: String?
    var profileImage: [String: Data]
    var nickName: String
    var description: String?
    var hobbyList: [String]?
    var myClubList: [Club]?
    var myNoticeBoardList: [NoticeBoard]?
    var myCommentList: [Comment]?

    var toIDoUser: IDoUser {
        return IDoUser(id: id, updateAt: updateAt, profileImage: profileImageURL, nickName: nickName, description: description, hobbyList: hobbyList, myClubList: myClubList, myNoticeBoardList: myNoticeBoardList, myCommentList: myCommentList)
    }
}
