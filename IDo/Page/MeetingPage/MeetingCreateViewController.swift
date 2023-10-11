import UIKit

class MeetingCreateViewController: UIViewController {
    
    let profileImageButton = MeetingProfileImageButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        // UI 설정
        view.addSubview(profileImageButton)
        profileImageButton.addTarget(self, action: #selector(profileImageTapped), for: .touchUpInside)
        profileImageButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(16)
            make.centerX.equalToSuperview()
        }
    }
    
    @objc private func profileImageTapped() {
        profileImageButton.openImagePicker(in: self)
    }
}

extension MeetingCreateViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let circularImage = selectedImage.circularImage(size: profileImageButton.bounds.size)
            profileImageButton.setImage(circularImage, for: .normal)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

    
    
    
    // 네비게이션
//    navigationController?.navigationBar.barTintColor = .white
//    navigationItem.title = "미팅 생성"
//    let cancelButton = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(cancelButtonTapped))
//    navigationItem.leftBarButtonItem = cancelButton
//}
//
//
//
//@objc func cancelButtonTapped() {
//    // 취소 버튼이 눌렸을 때의 액션
//    self.dismiss(animated: true, completion: nil)
//}

