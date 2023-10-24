//
//  TemporaryManager.swift
//  IDo
//
//  Created by t2023-m0091 on 10/18/23.
//

import Foundation

class TemporaryManager {
    static let shared = TemporaryManager()
    
    var meetingIndex: Int? //               NoticeMeetingController        NoticeHomeController          MeetingViewController
    var categoryData: String? //            NoticeHomeController           CategoryViewController        MeetingViewController
    var categoryIndex: Int? //              MeetingViewController
    var selectedCategory: String? //        MeetingCreateViewController     MeetingManageViewController  CategoryViewController  MeetingViewController
    var selectedMeetingId: String? //       MeetingManageViewController     NoticeMeetingController
    var meetingImageUrls: [String] = [] //  MeetingViewController           NoticeMeetingController
    var meetingTitle: [String] = [] //      MeetingViewController           NoticeMeetingController
    var meetingDescription: String? //      MeetingManageViewController     NoticeMeetingController
    var meetingDate: [String] = [] //       MeetingViewController           NoticeMeetingController
//    var meetingId: String?
    
    private init() {}
}

