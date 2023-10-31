//
//  FirebaseNoticeBoardManager.swift
//  IDo
//
//  Created by 김도현 on 2023/10/19.
//

import FirebaseDatabase
import Foundation

class FirebaseUserDatabaseManager: FBDatabaseManager<Club> {
    func appendUser(idoUser: IDoUser) {
        guard let model else { return }
        var userList = model.userList ?? []
        userList.append(idoUser)
        ref.updateChildValues(["userList":userList.asArrayDictionary()])
    }
    func removeUser(idoUser: IDoUser) {
        guard let model,
              var userList = model.userList else { return }
        userList.removeAll(where: { $0.id == idoUser.id })
        ref.updateChildValues(["userList":userList.asArrayDictionary()])
    }
}
