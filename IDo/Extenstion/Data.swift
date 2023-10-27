//
//  Data.swift
//  IDo
//
//  Created by 김도현 on 2023/10/27.
//

import Foundation
import CryptoKit

extension Data {
    var sha256Hash: String {
        let hash = SHA256.hash(data: self)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
