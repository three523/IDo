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

class FirebaseCommentManager {
    private var ref: DatabaseReference!
    
    init(noticeBoardID: String) {
        self.ref = Database.database().reference().child("NoticeBoard").child("CommentList")
    }
    
    func addComment(comment: CommentTest) {
        ref.child(comment.id).setValue(comment.toDictionary())
    }
    
    func readCommtents(completion: @escaping (Result<[CommentTest], FirebaseError>) -> Void) {
        ref.getData { error, dataSnapshot in
            if let error {
                let nsError = error as NSError
                if nsError.code == 1 { completion(.failure(.networkError)) }
                else if nsError.code == 2 { completion(.failure(.userNotFound)) }
                else if nsError.code == 3 { completion(.failure(.userTokenExpired)) }
                else if nsError.code == 4 { completion(.failure(.tooManyRequests)) }
                else { completion(.failure(.otherError)) }
                return
            }
            guard let dataSnapshot else {
                completion(.failure(.dataSnapshotNil))
                return
            }
            let commentList = dataSnapshot.value as? NSDictionary
            var commentTest = [CommentTest]()
            commentList?.forEach({ key, value in
                let comment = value as! NSDictionary
                guard let writeUser = comment["writeUser"] as? String else { return }
                commentTest.append(CommentTest(id: comment["id"] as! String, createDate: (comment["createDate"] as! String).toDate!, content: comment["content"] as! String, noticeBoardID: comment["noticeBoardID"] as! String, writeUser: writeUser))
                
            })
            completion(.success(commentTest))
        }
        
    }
    
    func updateComments(comment: CommentTest) {
        ref.updateChildValues([comment.id: comment.toDictionary()])
    }
    
    func deleteComment(comment: CommentTest) {
        ref.updateChildValues([comment.id: nil])
    }
}

struct CommentTest {
    let id: String
    let createDate: Date
    var content: String
    var noticeBoardID: String
    let writeUser: String
    
    func toDictionary() -> [String: Any] {
        let dictionary = ["id": id, "createDate": createDate.dateToString, "content": content, "noticeBoardID": noticeBoardID, "writeUser": writeUser]
        return dictionary
    }
}

struct WriteUser {
    let id: String
}
