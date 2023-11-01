//
//  UserSummary.swift
//  IDo
//
//  Created by 김도현 on 2023/10/18.
//

import Foundation

struct UserSummary: Codable, Identifier {
    let id: String // id 로 루트유저 구분해서 클럽 만들때 받기
    var profileImageURL: String?
    var nickName: String
}
