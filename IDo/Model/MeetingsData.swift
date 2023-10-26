import Foundation
import FirebaseDatabase
import FirebaseStorage

class MeetingsData {
    var clubs: [Club] = []
    let category: String
    private let defaultRef: DatabaseReference
    var update: () -> Void = {}
    
    init(category: String) {
        self.category = category
        
        self.defaultRef = Database.database().reference().child(category).child("meetings")
    }
    
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
//            self.update()
        }
    }
    
    
    func readClub() {
        defaultRef.getData { error, datasnapshot in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let value = datasnapshot?.value as? [String: Any] else {
                print("값이 없습니다")
                return
            }
            for (_, item) in value {
                if let itemDict = item as? [String: Any],
                   let id = itemDict["id"] as? String,
                   let description = itemDict["description"] as? String,
                   let title = itemDict["title"] as? String,
                   let imageURL = itemDict["imageURL"] as? String {
                    let club = Club(id: id, title: title, imageURL: imageURL, description: description)
                    self.clubs.append(club)
                }
                
                
            }
            self.update()
        }
        
    }
    
    func saveImage(imageData: Data?, club: Club, completion: @escaping (Bool) -> Void) {
        if let imageData = imageData {
            let storageRef = Storage.storage().reference().child(category).child("meeting_images").child("\(club.id).png")
            
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
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
    
    func updateImageURL(club: Club, storageRef: String) {
        let ref = defaultRef.child(club.id)
        ref.updateChildValues(["imageURL":storageRef]) { error, _ in
            if let error = error {
                print(error)
                return
            }
            guard let index = self.clubs.firstIndex(where: { $0.id == club.id })
            else { return }
            self.clubs[index].imageURL = storageRef
        }
    }
    
    func loadImage(storagePath: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let storageRef =
        Storage.storage().reference().child(storagePath)
        storageRef.downloadURL { url, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let url = url else { return }
            FBURLCache.shared.downloadURL(url: url) { result in
                switch result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    // 삭제 기능 추가했을때 이 함수로 클럽만 넣으면 됨.
    func deleteClub(club: Club) {
        guard let index = self.clubs.firstIndex(where: { $0.id == club.id })
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


