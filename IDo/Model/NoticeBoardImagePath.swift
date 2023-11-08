//
//  StorageImage.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/11/08.
//

import UIKit

struct NoticeBoardImagePath: Codable {
    let imageUID: String
    let savedImagePath: String
}

struct StorageImage {
    let imageUID: String
    let savedImage: UIImage
}
