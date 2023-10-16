//
//  FirebaseDataManager.swift
//  IDo
//
//  Created by 김도현 on 2023/10/16.
//

import Foundation
import FirebaseDatabase

enum RealTimeDatabaseError: Error {
    case dataSnapshotNil
}

class FirebaseCommentManager {
    private var ref: DatabaseReference!
    
    init(noticeBoardID: String) {
        self.ref = Database.database().reference().child("NoticeBoard").child(noticeBoardID)
    }
    
    func addComment() {
        
    }
    
    func readCommtents(completion: @escaping (Result<Comment, Error>) -> Void) {
        ref.getData { error, dataSnapshot in
            if let error {
                completion(.failure(error))
                return
            }
            guard let dataSnapshot else {
                completion(.failure(RealTimeDatabaseError.dataSnapshotNil))
                return
            }
            
        }
        
    }
    
    func updateComments() {
        
    }
    
    func deleteComment() {
        
    }
}
