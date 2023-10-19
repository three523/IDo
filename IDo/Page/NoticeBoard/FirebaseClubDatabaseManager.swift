//
//  FirebaseNoticeBoardManager.swift
//  IDo
//
//  Created by 김도현 on 2023/10/19.
//

import Foundation
import FirebaseDatabase

class FirebaseClubDatabaseManager: FBDatabaseManager<IDoUser> {
    func updateAddClub(club: Club) {
        guard var model else { return }
        var clubList = [Club]()
        if let myClubList = model.myClubList {
            clubList = myClubList
        }
        if clubList.contains(where: { $0.id == club.id }) { return }
        clubList.append(club)
        self.model?.myClubList = clubList
        ref.child("myClubList").setValue(self.model?.myClubList?.asArrayDictionary())
    }
}
