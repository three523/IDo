import FirebaseDatabase
import FirebaseStorage
import Foundation
import UIKit

class MeetingsData {
    var clubs: [Club] = []
    let category: String
    private let defaultRef: DatabaseReference
    var update: () -> Void = {}
    var clubImages: [String: UIImage] = [:] // 딕셔너리
    
    init(category: String) {
        self.category = category
        
        self.defaultRef = Database.database().reference().child(category).child("meetings")
    }

    // 새로 추가될 때 리로드 되는거 나중에 수정
    func addClub(club: Club, imageData: Data?, completion: @escaping (Bool) -> Void) {
        let ref = defaultRef.child(club.id)
        
        ref.setValue(club.dictionary) { error, _ in
            if let error = error {
                print(error.localizedDescription)
            }
            self.clubs.append(club)
            self.saveImage(imageData: imageData, club: club) { isSuccess in
                self.update()
                completion(isSuccess)
            }
            guard let myInfo = MyProfile.shared.myUserInfo else { return }
            var myClubList = myInfo.myClubList ?? []
            myClubList.append(club)
            MyProfile.shared.update(myClubList: myClubList)
        }
    }
    
    func readClub(completion: ((Bool) -> Void)? = nil) {
        defaultRef.getData { error, datasnapshot in
            if let error = error {
                print(error.localizedDescription)
                completion?(false)
                return
            }
            guard let value = datasnapshot?.value as? [String: Any] else {
                print("값이 없습니다")
                completion?(false)
                return
            }
            let tempClubs: [Club] = DataModelCodable.decodingDataSnapshot(value: value)
            self.clubs = tempClubs.sorted(by: {$0.title.count < $1.title.count})
            completion?(true)
            self.update()
        }
    }
    
    func saveImage(imageData: Data?, club: Club, completion: @escaping (Bool) -> Void) {
        if let imageData = imageData {
            let storageRef = Storage.storage().reference().child(category).child("meeting_images").child("\(club.id).png")
            
            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("Failed to upload image to Firebase Storage:", error)
                    completion(false)
                    return
                }
                self.updateImageURL(club: club, storageRef: storageRef.fullPath)
                completion(true)
            }
        }
    }
    
    func updateClub(club: Club, imagaData: Data?, completion: @escaping (Bool) -> Void) {
        
        defaultRef.updateChildValues([club.id: club.dictionary]) { error, _ in
            if let error = error {
                print(error)
                return
            }
            self.saveImage(imageData: imagaData, club: club) { isSuccess in
                if isSuccess {
                    completion(true)
                    print("업데이트 성공?") 
                }
            }
        }
    }
    
    func updateImageURL(club: Club, storageRef: String) {
        let ref = defaultRef.child(club.id)
        ref.updateChildValues(["imageURL": storageRef]) { error, _ in
            if let error = error {
                print(error)
                return
            }
            guard let index = self.clubs.firstIndex(where: { $0.id == club.id })
            else { return }
            self.clubs[index].imageURL = storageRef
        }
    }
    
    func loadImage(storagePath: String, clubId: String ,completion: @escaping (Result<UIImage, Error>) -> Void) {
        let storageRefPath =
        Storage.storage().reference().child(storagePath).fullPath
        FBURLCache.shared.downloadURL(storagePath: storageRefPath) { result in
            switch result {
            case .success(let image):
                self.clubImages[clubId] = image
                completion(.success(image))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // 삭제 기능 추가했을때 이 함수로 클럽만 넣으면 됨.
    func deleteClub(club: Club) {
        guard let index = clubs.firstIndex(where: { $0.id == club.id })
        else { return }
        defaultRef.updateChildValues([club.id: nil]) { error, _ in
            if let error = error {
                print(error)
                return
            }
            self.clubs.remove(at: index)
            self.update()
        }
    }
}
