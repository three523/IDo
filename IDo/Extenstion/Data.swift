//
//  Data.swift
//  IDo
//
//  Created by 김도현 on 2023/10/27.
//

import Foundation
import CryptoKit

extension Data {
    var md5Hash: String {
        let hash = Insecure.MD5.hash(data: self)
        return Data(hash).base64EncodedString()
    }
}
