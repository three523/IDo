//
//  NoticeBoard.swift
//  IDo
//
//  Created by 김도현 on 2023/10/13.
//

import Foundation

struct NoticeBoard: Codable {
    let id: String
    let rootUser: UserSummary
    let createDate: Date
    let clubID: String
    var title: String
    var content: String
    var imageList: [String]
    var commentList: [Comment]?
}
