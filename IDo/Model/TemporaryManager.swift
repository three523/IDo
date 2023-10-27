//
//  TemporaryManager.swift
//  IDo
//
//  Created by t2023-m0091 on 10/18/23.
//

import Foundation

class TemporaryManager {
    static let shared = TemporaryManager()
    
    var meetingIndex: Int?
    var categoryData: String?
    var categoryIndex: Int?
    var selectedCategory: String?
    var selectedMeetingId: String?
    var meetingImageUrls: [String] = []
    var meetingTitle: [String] = []
    var meetingDescription: String?
    var meetingDate: [String] = []
    private init() {}
}

