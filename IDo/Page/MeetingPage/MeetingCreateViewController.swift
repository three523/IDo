import UIKit
import FirebaseDatabase
import FirebaseStorage

class MeetingCreateViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let meetingsData: MeetingsData
    // contentmode 종류 봐보기
    var originalY: CGFloat?
    let profileImageButton: MeetingProfileImageButton = {
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
        textView.layer.borderColor = UIColor.lightGray.cgColor
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
    
    init(meetingsData: MeetingsData) {
        self.meetingsData = meetingsData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "모임에 대한 소개를 해주세요."
        label.font = UIFont(name: "SF Pro", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = UIColor.placeholderText
        return label
    }()
    
    func shakeAnimation(for view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.5
        animation.values = [-2, 2, -2, 2, -2, 2] // 애니메이션 값 조정
        view.layer.add(animation, forKey: "shake")
    }
    
    private let createFinishButton = FinishButton()


    @objc private func createMeeting() {
            guard let name = meetingNameField.text, !name.isEmpty,
                  let description = meetingDescriptionField.text, !description.isEmpty else {
                print("모임의 이름과 설명은 필수 입력 항목입니다.")
                return
            }

        if !profileImageButton.profileImageChanged {
                let alert = UIAlertController(title: "알림", message: "대표 사진은 필수입니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        
        guard let myUserInfo = MyProfile.shared.myUserInfo else {
            print("현재 사용자 정보를 가져오지 못했습니다.")
            return
        }

        let currentUserSummary = myUserInfo.toUserSummary
        
        var imageData: Data? = nil
            if let image = profileImageButton.image(for: .normal) {
                imageData = image.jpegData(compressionQuality: 0.8) // 이미지 품질
            }

        let club = Club(id: UUID().uuidString, rootUser: currentUserSummary,title: name, imageURL: nil, description: description, category: meetingsData.category, userList: [currentUserSummary], createDate: Date().dateToString)
        meetingsData.addClub(club: club, imageData: imageData) { isSuccess in
            if isSuccess {
                let alert = UIAlertController(title: "완료", message: "모임을 개설했습니다!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    private func setupCreateButton() {
        createFinishButton.addTarget(self, action: #selector(createMeeting), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCreateButton()
        updateFinishButtonState()
        configureUI()
        setupScrollView()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        if let navigationBar = self.navigationController?.navigationBar {
            NavigationBar.setNavigationTitle(for: navigationItem, in: navigationBar, title: "모임 생성하기")
        }
    }
    
    

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        let adjustmentHeight = keyboardHeight - (self.tabBarController?.tabBar.frame.size.height ?? 0)
        scrollView.snp.updateConstraints { make in
            make.height.equalTo(view.safeAreaLayoutGuide).offset(-adjustmentHeight)
        }
        
        DispatchQueue.main.async {
            self.scrollView.layoutIfNeeded()
            let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height + self.scrollView.contentInset.bottom)
            if bottomOffset.y > 0 {
                self.scrollView.setContentOffset(bottomOffset, animated: true)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.snp.updateConstraints { make in
            make.height.equalTo(view.safeAreaLayoutGuide)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    private func configureUI() {
        // UI 설정
        view.addSubview(scrollView)
//        scrollView.addSubview(containerView)
        meetingNameField.delegate = self
        scrollView.addSubview(profileImageButton)
        scrollView.addSubview(meetingNameField)
        scrollView.addSubview(countMeetingNameField)
        scrollView.addSubview(createFinishButton)
        scrollView.addSubview(countDescriptionField)
        scrollView.addSubview(meetingDescriptionField)
        scrollView.addSubview(placeholderLabel)
        
        let safeArea = view.safeAreaLayoutGuide
        scrollView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(safeArea)
            make.height.equalTo(safeArea)
        }
        scrollView.contentLayoutGuide.snp.makeConstraints { make in
            make.top.left.right.equalTo(safeArea)
            make.height.equalTo(safeArea)
        }
        
        let desiredAspectRatio: CGFloat = 2.0 / 3.0
                
        profileImageButton.snp.makeConstraints { (make) in
            make.top.equalTo(scrollView.snp.top).offset(Constant.margin3)
            make.centerX.equalTo(scrollView)
            make.left.right.equalTo(scrollView).inset(Constant.margin4)
            make.height.equalTo(profileImageButton.snp.width).multipliedBy(desiredAspectRatio)
        }
                
        meetingNameField.snp.makeConstraints { (make) in
            make.top.equalTo(profileImageButton.snp.bottom).offset(Constant.margin4)
            make.centerX.equalTo(scrollView)
            make.left.right.equalTo(scrollView).inset(Constant.margin4)
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
            make.centerX.equalTo(scrollView)
            make.left.right.equalTo(scrollView).inset(Constant.margin4)
            make.height.equalTo(160)
        }
        meetingDescriptionField.delegate = self
        
        placeholderLabel.snp.makeConstraints { (make) in
            make.top.equalTo(meetingDescriptionField).offset(12)
            make.left.equalTo(meetingDescriptionField).offset(12.8) // textview, textfield 간의 placeholder margin 차이로 인해 미세한 위치조정
        }
                
        createFinishButton.snp.makeConstraints { (make) in
            make.top.equalTo(countDescriptionField.snp.bottom).offset(4)
            make.centerX.equalTo(scrollView)
            make.left.right.equalTo(scrollView).inset(Constant.margin4)
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
    
    func updateFinishButtonState() {
            // meetingNameField와 meetingDescriptionField가 모두 내용이 있을때만 활성화
            let istitleFieldEmpty = meetingNameField.text?.isEmpty ?? true
            let isDescriptionEmpty = meetingDescriptionField.text.isEmpty
            createFinishButton.isEnabled = !(istitleFieldEmpty || isDescriptionEmpty)
        }

    private func setupScrollView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        scrollView.isUserInteractionEnabled = true
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    @objc func endEditing() {
        view.endEditing(true)
    }
    
}

extension MeetingCreateViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//                let roundedImage = selectedImage.resizedAndRoundedImage()
                profileImageButton.setImage(selectedImage, for: .normal)
                profileImageButton.profileImageChanged = true
            }
            picker.dismiss(animated: true, completion: nil)
        }
}


extension MeetingCreateViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        countDescriptionField.text = "\(textView.text.count)/300"
        updateFinishButtonState()
        
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


extension MeetingCreateViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == meetingNameField else {
            return true
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
                updateFinishButtonState()
            }
        
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        countMeetingNameField.text = "\(prospectiveText.count)/16"
        
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




