//
//  FirebaseDataManager.swift
//  IDo
//
//  Created by 김도현 on 2023/10/16.
//

import Foundation
import Firebase
import FirebaseDatabase

enum FirebaseError: Error {
    case dataSnapshotNil
    case networkError
    case userNotFound
    case userTokenExpired
    case tooManyRequests
    case otherError
}

class FirebaseCommentManager: ObservableObject {
    private var ref: DatabaseReference!
    var commentList = [CommentTest]() {
        didSet {
            update()
        }
    }
    var viewState: ViewState = .loading
    var update: () -> Void = {}
    
    init(noticeBoardID: String) {
        self.ref = Database.database().reference().child("NoticeBoard").child("CommentList")
    }
    
    func addComment(comment: CommentTest) {
        ref.child(comment.id).setValue(comment.toDictionary())
        commentList.append(comment)
    }
    
    func readCommtents() {
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
                self.commentList = []
                return
            }
            let commentList: [CommentTest] = self.decodingDataSnapshot(value: value)
            let commentSortedList: [CommentTest] = commentList.sorted(by: {
                $0.createDate.toDate ?? Date() <= $1.createDate.toDate ?? Date()
            })
            self.viewState = .loaded
            self.commentList = commentSortedList
        }
    }
    
    func updateComments(comment: CommentTest) {
        guard let index = commentList.firstIndex(where: { $0.id == comment.id }) else { return }
        commentList[index] = comment
        ref.updateChildValues([comment.id: comment.toDictionary()])
    }
    
    func deleteComment(comment: CommentTest) {
        commentList.removeAll(where: { $0.id == comment.id })
        ref.updateChildValues([comment.id: nil])
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

struct CommentTest: Codable {
    let id: String
    let createDate: String
    var content: String
    var noticeBoardID: String
    let writeUser: String
    
    func toDictionary() -> [String: Any] {
        let dictionary = ["id": id, "createDate": createDate, "content": content, "noticeBoardID": noticeBoardID, "writeUser": writeUser]
        return dictionary
    }
}

struct WriteUser {
    let id: String
}
