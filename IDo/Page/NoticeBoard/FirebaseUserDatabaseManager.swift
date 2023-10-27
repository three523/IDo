//
//  FirebaseNoticeBoardManager.swift
//  IDo
//
//  Created by 김도현 on 2023/10/19.
//

import FirebaseDatabase
import Foundation

class FirebaseUserDatabaseManager: FBDatabaseManager<IDoUser> {
    func updateAddClub(club: Club, compltion: (() -> Void)? = nil) {
        guard var model else { return }
        var clubList = [Club]()
        if let myClubList = model.myClubList {
            clubList = myClubList
        }
        if clubList.contains(where: { $0.id == club.id }) { return }
        clubList.append(club)
        self.model?.myClubList = clubList
        ref.child("myClubList").setValue(self.model?.myClubList?.asArrayDictionary())
        compltion?()
    }
}
