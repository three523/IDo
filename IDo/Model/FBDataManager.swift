//
//  FBDataManager.swift
//  IDo
//
//  Created by 김도현 on 2023/10/18.
//

import Foundation
import FirebaseDatabase

class FBDataManager<T: Codable & Identifier> {
    var ref: DatabaseReference
    var viewState: ViewState = .loading
    var update: () -> Void = {}
    var dataList: [T] = [] {
        didSet {
            update()
        }
    }
    
    init(refPath: [String]) {
        self.ref = Database.database().reference()
        for path in refPath {
            self.ref = Database.database().reference().child(path)
        }
    }
    
    func addData(data: T) {
        ref.child(data.id).setValue(data.dictionary)
        dataList.append(data)
    }
    
    func readDatas() {
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
            let dataList: [T] = self.decodingDataSnapshot(value: value)
            self.viewState = .loaded
            self.dataList = dataList
        }
    }
    
    func updateDatas(data: T) {
        guard let index = dataList.firstIndex(where: { $0.id == data.id }) else { return }
        dataList[index] = data
        ref.updateChildValues([data.id: data.dictionary])
    }
    
    func deleteData(data: T) {
        dataList.removeAll(where: { $0.id == data.id })
        ref.updateChildValues([data.id: nil])
    }
    
    private func decodingDataSnapshot<T: Decodable>(value: [String: Any]) -> [T] {
        let commentTestList: [T] = value.compactMap { key, value in
            let comment: T? = decodingSingleDataSnapshot(value: value)
            return comment
        }
        return commentTestList
    }
    
    private func getDecodingData<T: Decodable>(dataSnapshot: DataSnapshot) -> T? {
        guard let value = dataSnapshot.value as? [String: Any] else { return nil }
        guard let data: T = self.decodingSingleDataSnapshot(value: value) else { return  nil }
        return data
    }
    
    private func decodingSingleDataSnapshot<T: Decodable>(value: Any) -> T? {
        let decoder = JSONDecoder()
        guard let data = try? JSONSerialization.data(withJSONObject: value) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }
}
