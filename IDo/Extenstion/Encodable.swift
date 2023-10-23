//
//  Encodable.swift
//  IDo
//
//  Created by 김도현 on 2023/10/18.
//

import Foundation

extension Encodable {
    var dictionary: [String: Any]? {
        do {
            let data = try JSONEncoder().encode(self)
        } catch let DecodingError.dataCorrupted(context) {
            print(DecodingError.dataCorrupted(context))
        } catch let DecodingError.valueNotFound(value, context) {
            print(DecodingError.valueNotFound(value, context))
        } catch let DecodingError.keyNotFound(key, context) {
            print(DecodingError.keyNotFound(key, context))
        } catch let DecodingError.typeMismatch(type, context) {
            print(DecodingError.typeMismatch(type, context))
        } catch let error {
            print(error)
        }
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

extension Array where Element: Encodable {
    func asArrayDictionary() -> [[String: Any]]? {
        var data: [[String: Any]] = []

        for element in self {
            if let ele = element.dictionary {
                data.append(ele)
            }
        }
        return data
    }
}
