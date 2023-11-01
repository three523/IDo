//
//  Club.swift
//  IDo
//
//  Created by 김도현 on 2023/10/13.
//

import Foundation

struct Club: Codable, Identifier {
    let id: String
    var rootUser: IDoUser?
    var title: String
    var imageURL: String?
    var description: String
    var category: String
    var noticeBoardList: [NoticeBoard]?
    var userList: [IDoUser]?
//    var createDate: String // 만든 날짜로 정렬 ..
}
