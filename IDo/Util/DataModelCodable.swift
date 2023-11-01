//
//  DataModelCodable.swift
//  IDo
//
//  Created by 김도현 on 2023/11/01.
//

import FirebaseDatabase

struct DataModelCodable {
    static func decodingDataSnapshot<T: Decodable>(value: [String: Any]) -> [T] {
        let commentTestList: [T] = value.compactMap { key, value in
            let comment: T? = decodingSingleDataSnapshot(value: value)
            return comment
        }
        return commentTestList
    }
    
    static func decodingSingleDataSnapshot<T: Decodable>(value: Any) -> T? {
        let decoder = JSONDecoder()
        do {
            let data = try JSONSerialization.data(withJSONObject: value)
            let result = try decoder.decode(T.self, from: data)
            
            return result
        } catch DecodingError.dataCorrupted(let context) {
            print("Data Corrupted: \(context.debugDescription)")
        } catch DecodingError.keyNotFound(let key, let context) {
            print("Key Not Found: \(key.stringValue) in \(context.debugDescription)")
        } catch DecodingError.typeMismatch(_, let context) {
            print("Type Mismatch: \(context.debugDescription)")
        } catch DecodingError.valueNotFound(_, let context) {
            print("Value Not Found: \(context.debugDescription)")
        } catch {
            // 기타 디코딩 오류 처리
            print("Error decoding JSON: \(error)")
        }
        return nil
    }
}
