//
//  Comment.swift
//  IDo
//
//  Created by 김도현 on 2023/10/13.
//

import Foundation

struct Comment {
    let id: String
    let noticeBoardID: String
    let writeUser: User
    let createDate: Date
    var content: String
}
