//
//  FBDataManager.swift
//  IDo
//
//  Created by 김도현 on 2023/10/18.
//

import Foundation
import FirebaseDatabase

class FBDatabaseManager<T: Codable & Identifier> {
    
    typealias isDatabaseActionComplete = Bool
    
    var ref: DatabaseReference
    var viewState: ViewState = .loading
    var update: () -> Void = {}
    var model: T? {
        didSet {
            update()
        }
    }
    var modelList: [T] = [] {
        didSet {
            update()
        }
    }
    
    init(refPath: [String]) {
        self.ref = Database.database().reference()
        for path in refPath {
            self.ref = ref.child(path)
        }
    }
    
    func appendData(data: T, completion: ((Bool) -> Void)? = nil) {
        ref.child(data.id).setValue(data.dictionary) { error, _ in
            if let error {
                print(error.localizedDescription)
                completion?(false)
                return
            }
            self.modelList.insert(data, at: 0)
            completion?(true)
        }
        
    }
    
    func setData(data: T) {
        model = data
    }
    
    func readDatas(completion: @escaping (Result<[T],Error>)->Void = {_ in}) {
        ref.getData { error, dataSnapshot in
            if let error {
                let nsError = error as NSError
                if nsError.code == 1 { self.viewState = .error(true) }
                else { self.viewState = .error(false) }
                completion(.failure(nsError))
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
                self.modelList = []
                return
            }
            
            let dataList: [T] = self.decodingDataSnapshot(value: value)
            completion(.success(dataList))
            
            self.modelList = dataList
            self.viewState = .loaded
        }
    }
    
    func readData(completion: @escaping (Result<T,Error>)->Void = {_ in}) {
        ref.getData { error, dataSnapshot in
            if let error {
                let nsError = error as NSError
                if nsError.code == 1 { self.viewState = .error(true) }
                else { self.viewState = .error(false) }
                completion(.failure(nsError))
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
                self.modelList = []
                return
            }
            
            guard let data: T = self.decodingSingleDataSnapshot(value: value) else {
                print("decoding error")
                return
            }
            self.model = data
            completion(.success(data))
            
            self.viewState = .loaded
        }
    }
    
    func updateDatas(data: T, completion: @escaping (isDatabaseActionComplete) -> Void = {_ in}) {
        guard let index = modelList.firstIndex(where: { $0.id == data.id }) else { return }
        modelList[index] = data
        ref.updateChildValues([data.id: data.dictionary]) { error, _ in
            if let error {
                print(error.localizedDescription)
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func updateModel(data: T, completion: @escaping (isDatabaseActionComplete) -> Void = {_ in}) {
        guard var model else { return }
        self.model = data
        ref.updateChildValues([data.id: data.dictionary]) { error, _ in
            if let error {
                print(error.localizedDescription)
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func updateValue<V: Codable>(value: V, completion: ((isDatabaseActionComplete) -> Void)? = nil) {
        guard let dict = value.dictionary else { return }
        ref.updateChildValues(dict) { error, _ in
            if let error {
                print(error.localizedDescription)
                completion?(false)
                return
            }
            completion?(true)
        }
    }
    
    func deleteData(data: T, completion: @escaping (isDatabaseActionComplete) -> Void = {_ in}) {
        ref.updateChildValues([data.id: nil]) { error, _ in
            if let error {
                print(error.localizedDescription)
                completion(false)
                return
            }
            self.modelList.removeAll(where: { $0.id == data.id })
            completion(true)
        }
    }
    
    func decodingDataSnapshot<T: Decodable>(value: [String: Any]) -> [T] {
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
    
    func decodingSingleDataSnapshot<T: Decodable>(value: Any) -> T? {
        let decoder = JSONDecoder()
        guard let data = try? JSONSerialization.data(withJSONObject: value) else { return nil }
        do {
            let data = try JSONSerialization.data(withJSONObject: value)
            let result = try decoder.decode(T.self, from: data)
            
            return result
        } catch DecodingError.dataCorrupted(let context) {
            // 데이터가 손상된 경우 처리
            print("Data Corrupted: \(context.debugDescription)")
        } catch DecodingError.keyNotFound(let key, let context) {
            // 키를 찾을 수 없는 경우 처리
            print("Key Not Found: \(key.stringValue) in \(context.debugDescription)")
        } catch DecodingError.typeMismatch(_, let context) {
            // 타입 불일치 오류 처리
            print("Type Mismatch: \(context.debugDescription)")
        } catch DecodingError.valueNotFound(_, let context) {
            // 값을 찾을 수 없는 경우 처리
            print("Value Not Found: \(context.debugDescription)")
        } catch {
            // 기타 디코딩 오류 처리
            print("Error decoding JSON: \(error)")
        }
        return nil
    }
}
