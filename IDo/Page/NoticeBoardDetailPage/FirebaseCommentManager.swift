//
//  File.swift
//  IDo
//
//  Created by 김도현 on 2023/10/19.
//

import Foundation

class FirebaseCommentManaer: FBDatabaseManager<Comment> {
    override func readDatas(completion: @escaping (Result<[Comment], Error>) -> Void = {_ in}) {
        ref.getData { error, dataSnapshot in
            if let error {
                let nsError = error as NSError
                if nsError.code == 1 { self.viewState = .error(true) }
                else { self.viewState = .error(false) }
                self.update()
                return
            }
            guard let dataSnapshot else {
                self.viewState = .error(false)
                self.update()
                return
            }
            guard let value = dataSnapshot.value as? [String: Any] else {
                self.viewState = .loaded
                self.dataList = []
                return
            }
            let dataList: [Comment] = self.decodingDataSnapshot(value: value).sorted(by: { $0.createDate <= $1.createDate })
            self.viewState = .loaded
            self.dataList = dataList
        }
    }
}
