//
//  UserImageSize.swift
//  IDo
//
//  Created by 김도현 on 2023/10/24.
//
import UIKit
enum ImageSize: String, CaseIterable {
    case small
    case medium
    
    var size: CGSize {
        switch self {
        case .small:
            return CGSize(width: 120, height: 120)
        case .medium:
            return CGSize(width: 320, height: 280)
        }
    }
}
