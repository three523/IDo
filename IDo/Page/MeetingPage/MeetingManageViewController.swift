import UIKit
import FirebaseDatabase
import FirebaseStorage

class MeetingManageViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let containerView: UIView = {
           let view = UIView()
           return view
       }()
    
    var originalY: CGFloat?
    var meetingTitle: String?
    var meetingImageURL: String?
    var ref: DatabaseReference?
    let storage = Storage.storage()
    lazy var storageRef = storage.reference()
    private var meetingsData: MeetingsData
    private var club: Club
    private var clubImage: UIImage?
    var updateHandler: ((Club, Data) -> Void)?
    
    init(club: Club, clubImage: UIImage?) {
        self.club = club
        self.clubImage = clubImage
        self.meetingsData = MeetingsData(category: club.category)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var profileImageButton: MeetingProfileImageButton = {
        let button = MeetingProfileImageButton()
        button.addTarget(self, action: #selector(profileImageTapped), for: .touchUpInside)
        return button
    }()
    
    let meetingNameField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: "SF Pro", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .regular)
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(named: "BackgroundSecondary")
        textField.placeholder = "모임 이름을 설정하세요."
        return textField
    }()
    
    let countMeetingNameField: UILabel = {
        let label = UILabel()
        label.text = "(0/16)"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.gray
        return label
    }()
    
    
    
    let meetingDescriptionField: UITextView = {
        let textView = UITextView()
        textView.font = UIFont(name: "SF Pro", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .regular)
        textView.backgroundColor = UIColor(named: "BackgroundSecondary")
        textView.textAlignment = .left
        textView.layer.cornerRadius = 5.0
        textView.layer.borderColor = UIColor.lightGray.cgColor// .
        textView.layer.borderWidth = 0.2
        textView.clipsToBounds = true
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 12)
        return textView
    }()
    
    let countDescriptionField: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.text = "(0/300)"
        return label
    }()
    
    func shakeAnimation(for view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.5
        animation.values = [-2, 2, -2, 2, -2, 2] // 애니메이션 값 조정
        view.layer.add(animation, forKey: "shake")
    }
    
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "모임에 대한 소개를 해주세요."
        label.font = UIFont(name: "SF Pro", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = UIColor.placeholderText
        return label
    }()
    
    private let manageFinishButton = FinishButton(title: "수정 완료")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        configureUI()
        meetingNameField.text = club.title
        meetingDescriptionField.text = club.description
        placeholderLabel.isHidden = !club.description.isEmpty
        if let clubImage {
            profileImageButton.setImage(clubImage, for: .normal)
        } else {
            if let imagePath = club.imageURL {
                FBURLCache.shared.downloadURL(storagePath: imagePath) { result in
                    switch result {
                    case .success(let image):
                        DispatchQueue.main.async {
                            self.profileImageButton.setImage(image, for: .normal)
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
        ref = Database.database().reference()
        manageFinishButton.addTarget(self, action: #selector(manageFinishButtonTapped), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        if let navigationBar = self.navigationController?.navigationBar {
            NavigationBar.setNavigationTitle(for: navigationItem, in: navigationBar, title: "모임 수정하기")
        }
        countDescriptionField.text = "(\(meetingDescriptionField.text.count)/300)"
        countMeetingNameField.text = "(\(meetingNameField.text?.count ?? 0)/16)"
//        placeholderLabel.isHidden = !meetingDescriptionField.text.isEmpty
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if originalY == nil {
            originalY = self.view.frame.origin.y
        }
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            let adjustmentHeight = keyboardHeight - (self.tabBarController?.tabBar.frame.size.height ?? 0)
            self.view.frame.origin.y = originalY! - adjustmentHeight
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let originalY = originalY {
            self.view.frame.origin.y = originalY
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    private func configureUI() {
        // UI 설정
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        meetingNameField.delegate = self
        containerView.addSubview(profileImageButton)
        containerView.addSubview(meetingNameField)
        containerView.addSubview(countMeetingNameField)
        containerView.addSubview(manageFinishButton)
        containerView.addSubview(countDescriptionField)
        containerView.addSubview(meetingDescriptionField)
        containerView.addSubview(placeholderLabel)
        
        
        scrollView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }

            containerView.snp.makeConstraints { (make) in
                make.top.bottom.leading.trailing.equalTo(scrollView)
                make.width.equalTo(scrollView)
                make.bottom.equalTo(manageFinishButton.snp.bottom)
            }
        

        let desiredAspectRatio: CGFloat = 2.0 / 3.0
                
        profileImageButton.snp.makeConstraints { (make) in
            make.top.equalTo(containerView.safeAreaLayoutGuide.snp.top).offset(Constant.margin3)
            make.centerX.equalTo(containerView)
            make.left.right.equalTo(containerView).inset(Constant.margin4)
            make.height.equalTo(profileImageButton.snp.width).multipliedBy(desiredAspectRatio)
        }
                
        meetingNameField.snp.makeConstraints { (make) in
            make.top.equalTo(profileImageButton.snp.bottom).offset(Constant.margin4)
            make.centerX.equalTo(containerView)
            make.left.right.equalTo(containerView).inset(Constant.margin4)
            make.height.equalTo(37)
        }
              
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: meetingNameField.frame.height))
        meetingNameField.leftView = leftPaddingView
        meetingNameField.leftViewMode = .always
        
        countMeetingNameField.snp.makeConstraints { (make) in
            make.top.equalTo(meetingNameField.snp.bottom).offset(4)
            make.right.equalTo(meetingNameField.snp.right)
        }
                
        meetingDescriptionField.snp.makeConstraints { (make) in
            make.top.equalTo(meetingNameField.snp.bottom).offset(22)
            make.centerX.equalTo(containerView)
            make.left.right.equalTo(containerView).inset(Constant.margin4)
            make.height.equalTo(160)
        }
        meetingDescriptionField.delegate = self
        
        placeholderLabel.snp.makeConstraints { (make) in
            make.top.equalTo(meetingDescriptionField).offset(12)
            make.left.equalTo(meetingDescriptionField).offset(12.8) // textview, textfield 간의 placeholder margin 차이로 인해 미세한 위치조정
           
        }
                
        manageFinishButton.snp.makeConstraints { (make) in
            make.top.equalTo(countDescriptionField.snp.bottom).offset(4)
            make.centerX.equalTo(containerView)
            make.left.right.equalTo(containerView).inset(Constant.margin4)
            make.height.equalTo(48)
//            make.bottom.equalTo(containerView.safeAreaLayoutGuide.snp.bottom).offset(-8)
        }
                
        countDescriptionField.snp.makeConstraints { (make) in
            make.top.equalTo(meetingDescriptionField.snp.bottom).offset(4)
            make.right.equalTo(meetingDescriptionField.snp.right)
        }
        
    }
    
    @objc private func profileImageTapped() {
        profileImageButton.openImagePicker(in: self)
    }
    
    @objc func manageFinishButtonTapped() {
        guard let name = meetingNameField.text, !name.isEmpty,
              let description = meetingDescriptionField.text, let meetingImage = profileImageButton.imageView?.image else {
            
            return
        }
        
        guard let imageData = meetingImage.jpegData(compressionQuality: 0.8) else {
            
            return
        }
        
        saveMeetingToFirebase(name: name, description: description, imageData: imageData)
    }
    
    private func saveMeetingToFirebase(name: String, description: String, imageData: Data) {
        club.title = name
        club.description = description
        meetingsData.updateClub(club: club, imagaData: imageData) { isSuccess in
            if isSuccess {
                print("데이터 수정 성공")
                
                let alert = UIAlertController(title: "완료", message: "모임 정보가 수정되었습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.updateHandler?(self.club, imageData)
                self.present(alert, animated: true, completion: nil)
            } else {
                print("데아터 수정 실패")
            }
        }
        }
    }






extension MeetingManageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//                let roundedImage = selectedImage.resizedAndRoundedImage()
                profileImageButton.setImage(selectedImage, for: .normal)
            }
            picker.dismiss(animated: true, completion: nil)
        }
}


extension MeetingManageViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        countDescriptionField.text = "(\(textView.text.count)/300)"
        
        if textView.text.count > 300 {
            shakeAnimation(for: countDescriptionField)
            countDescriptionField.textColor = .red
        } else {
            countDescriptionField.textColor = .black
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if prospectiveText.count > 301 { 
            return false
        }
        return true
    }
}


extension MeetingManageViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == meetingNameField else {
            return true
        }
        
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        countMeetingNameField.text = "(\(prospectiveText.count)/16)"
        
        if prospectiveText.count > 16 {
            shakeAnimation(for: countMeetingNameField)
            countMeetingNameField.textColor = .red
            return false
        } else {
            countMeetingNameField.textColor = .black
        }
        return true
    }
}




