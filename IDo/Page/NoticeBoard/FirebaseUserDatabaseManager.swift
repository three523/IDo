//
//  FirebaseNoticeBoardManager.swift
//  IDo
//
//  Created by 김도현 on 2023/10/19.
//

import FirebaseDatabase
import Foundation

class FirebaseUserDatabaseManager: FBDatabaseManager<Club> {
    func appendUser(user: UserSummary) {
        guard let model else { return }
        var userList = model.userList ?? []
        userList.append(user)
        ref.updateChildValues(["userList":userList.asArrayDictionary()])
    }
    func removeUser(user: UserSummary) {
        guard let model,
              var userList = model.userList else { return }
        userList.removeAll(where: { $0.id == user.id })
        ref.updateChildValues(["userList":userList.asArrayDictionary()])
    }
}
