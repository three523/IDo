    //
//  User.swift
//  IDo
//
//  Created by 김도현 on 2023/10/13.
//

import Foundation
 
struct IDoUser: Codable, Identifier {
    let id: String
    var profileImage: String?
    var nickName: String
    var description: String?
    var hobbyList: [String]?
    var myClubList: [Club]?
    var myNoticeBoardList: [NoticeBoard]?
    var myCommentList: [Comment]?
}
