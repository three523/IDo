import UIKit
import FirebaseDatabase
import FirebaseStorage

class MeetingCreateViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        setupCreateButton()
        updateFinishButtonState()
        configureUI()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        if let navigationBar = self.navigationController?.navigationBar {
            NavigationBar.setNavigationTitle(for: navigationItem, in: navigationBar, title: "모임 생성하기")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.meetingNameTextView.resignFirstResponder()
        self.meetingDescriptionTextView.resignFirstResponder()
    }
    
    init(meetingsData: MeetingsData) {
        self.meetingsData = meetingsData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 컴포넌트 생성
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let containerView: UIView = {
           let view = UIView()
           return view
       }()
    
    private let meetingsData: MeetingsData
    // contentmode 종류 봐보기
    var originalY: CGFloat?
    let profileImageButton: MeetingProfileImageButton = {
        let button = MeetingProfileImageButton()
        button.addTarget(self, action: #selector(profileImageTapped), for: .touchUpInside)
        return button
    }()
    
//    let meetingNameField: UITextField = {
//        let textField = UITextField()
//        textField.font = UIFont(name: "SF Pro", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .regular)
//        textField.borderStyle = .roundedRect
//        textField.backgroundColor = UIColor(named: "BackgroundSecondary")
//        textField.placeholder = "모임 이름을 설정하세요."
//        return textField
//    }()
    
    //    let placeholderLabel: UILabel = {
    //        let label = UILabel()
    //        label.text = "모임에 대한 소개를 해주세요."
    //        label.font = UIFont(name: "SF Pro", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .regular)
    //        label.textColor = UIColor.placeholderText
    //        return label
    //    }()
    
    // 이름을 작성하는 textView
    let meetingNameTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor(color: .backgroundSecondary)
        textView.font = UIFont.bodyFont(.large, weight: .medium)
        textView.text = "모임 이름을 입력해주세요."
        textView.textColor = UIColor(color: .placeholder)
        textView.layer.cornerRadius = 5
        textView.resignFirstResponder()
        return textView
    }()
    
    // 이름 글자 수 표시 label
    let countMeetingNameLabel: UILabel = {
        let label = UILabel()
        label.text = "(0/16)"
        label.textColor = UIColor(color: .placeholder)
        label.font = UIFont.bodyFont(.small, weight: .regular)
        return label
    }()
    
    // 소개글을 작성하는 textView
    let meetingDescriptionTextView: UITextView = {
//        let textView = UITextView()
//        textView.font = UIFont(name: "SF Pro", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .regular)
//        textView.backgroundColor = UIColor(named: "BackgroundSecondary")
//        textView.textAlignment = .left
//        textView.layer.cornerRadius = 5.0
//        textView.layer.borderColor = UIColor.lightGray.cgColor
//        textView.layer.borderWidth = 0.2
//        textView.clipsToBounds = true
//        textView.isEditable = true
//        textView.isScrollEnabled = true
//        textView.textContainerInset = UIEdgeInsets.zero
//        textView.textContainer.lineFragmentPadding = 0
//        textView.textContainerInset = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 12)
        
        let textView = UITextView()
        textView.backgroundColor = UIColor(color: .backgroundSecondary)
        textView.font = UIFont.bodyFont(.medium, weight: .regular)
        textView.text = "모임에 대한 소개를 입력해주세요."
        textView.textColor = UIColor(color: .placeholder)
        textView.layer.cornerRadius = 5.0
        textView.resignFirstResponder()
        return textView
    }()
    
    // 소개글 글자 수 표시 label
    let countDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "(0/300)"
        label.textColor = UIColor(color: .placeholder)
        label.font = UIFont.bodyFont(.small, weight: .regular)
        return label
    }()
    
    private let createFinishButton = FinishButton()
    
    // MARK: - 버튼 관련
    private func setupCreateButton() {
        createFinishButton.addTarget(self, action: #selector(createMeeting), for: .touchUpInside)
    }

    @objc private func createMeeting() {
//            guard let name = meetingNameField.text, !name.isEmpty,
//        guard let name = meetingNameTextView.text, !name.isEmpty,
//              let description = meetingDescriptionTextView.text, !description.isEmpty else {
        if meetingNameTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && meetingNameTextView.textColor != UIColor.black && meetingDescriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && meetingDescriptionTextView.textColor != UIColor.black {
            AlertManager.showAlert(on: self, title: "알림", message: "모임의 이름과 설명은 필수 입력 항목입니다.")
            print("모임의 이름과 설명은 필수 입력 항목입니다.")
            
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

        let club = Club(id: UUID().uuidString, rootUser: currentUserSummary, title: meetingNameTextView.text, imageURL: nil, description: meetingDescriptionTextView.text, category: meetingsData.category, userList: [currentUserSummary], createDate: Date().dateToString)
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
    
    func updateFinishButtonState() {
        // meetingNameField와 meetingDescriptionField가 모두 내용이 있을때만 활성화
//        let istitleFieldEmpty = meetingNameTextView.text?.isEmpty ?? true
//        let isDescriptionEmpty = meetingDescriptionTextView.text.isEmpty
//        
//        createFinishButton.isEnabled = !(istitleFieldEmpty || isDescriptionEmpty)
        
//        if !meetingNameTextView.text.isEmpty, meetingNameTextView.textColor ==  UIColor.black, meetingDescriptionTextView.textColor == UIColor.black ,!meetingDescriptionTextView.text.isEmpty {
//            createFinishButton.isEnabled = true
//        }
//        else {
//            createFinishButton.isEnabled = false
//        }
        createFinishButton.isEnabled = false
    }
    
    // MARK: - 키보드 관련
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

    // MARK: - UI 설정 및 오토레이아웃
    private func configureUI() {
        
        // UI 설정
//        meetingNameField.delegate = self
//        containerView.addSubview(meetingNameField)
//        containerView.addSubview(placeholderLabel)
        view.backgroundColor = UIColor(color: .backgroundPrimary)
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        meetingNameTextView.delegate = self
        meetingDescriptionTextView.delegate = self
        containerView.addSubview(profileImageButton)
        containerView.addSubview(meetingNameTextView)
        containerView.addSubview(countMeetingNameLabel)
        containerView.addSubview(meetingDescriptionTextView)
        containerView.addSubview(countDescriptionLabel)
        containerView.addSubview(createFinishButton)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalTo(scrollView)
            make.width.equalTo(scrollView)
            make.bottom.equalTo(createFinishButton.snp.bottom).offset(-16)
        }
        
        
        let desiredAspectRatio: CGFloat = 2.0 / 3.0
        
        profileImageButton.snp.makeConstraints { (make) in
            make.top.equalTo(containerView.safeAreaLayoutGuide.snp.top).offset(Constant.margin3)
            make.centerX.equalTo(containerView)
            make.left.right.equalTo(containerView).inset(Constant.margin4)
            make.height.equalTo(profileImageButton.snp.width).multipliedBy(desiredAspectRatio)
        }
                
//        meetingNameField.snp.makeConstraints { (make) in
//            make.top.equalTo(profileImageButton.snp.bottom).offset(Constant.margin4)
//            make.centerX.equalTo(containerView)
//            make.left.right.equalTo(containerView).inset(Constant.margin4)
//            make.height.equalTo(40)
//        }
        meetingNameTextView.snp.makeConstraints { (make) in
            make.top.equalTo(profileImageButton.snp.bottom).offset(Constant.margin3)
            make.centerX.equalTo(containerView)
            make.left.right.equalTo(containerView).inset(Constant.margin4)
            make.height.equalTo(40)
        }
              
//        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: meetingNameField.frame.height))
//        meetingNameField.leftView = leftPaddingView
//        meetingNameField.leftViewMode = .always
        
        countMeetingNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(meetingNameTextView.snp.bottom).offset(Constant.margin1)
            make.right.equalTo(meetingNameTextView.snp.right)
        }
                
        meetingDescriptionTextView.snp.makeConstraints { (make) in
            make.top.equalTo(countMeetingNameLabel.snp.bottom).offset(Constant.margin4)
            make.centerX.equalTo(containerView)
            make.left.right.equalTo(containerView).inset(Constant.margin4)
            make.height.equalTo(160)
        }
        
//        placeholderLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(meetingDescriptionField).offset(12)
//            make.left.equalTo(meetingDescriptionField).offset(12.8) // textview, textfield 간의 placeholder margin 차이로 인해 미세한 위치조정
//        }
        
        countDescriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(meetingDescriptionTextView.snp.bottom).offset(Constant.margin1)
            make.right.equalTo(meetingDescriptionTextView.snp.right)
        }
        
        createFinishButton.snp.makeConstraints { (make) in
            make.top.equalTo(countDescriptionLabel.snp.bottom).offset(Constant.margin4)
            make.centerX.equalTo(containerView)
            make.left.right.equalTo(containerView).inset(Constant.margin4)
            make.height.equalTo(48)
            //            make.bottom.equalTo(containerView.safeAreaLayoutGuide.snp.bottom).offset(-8)
        }
    }
    
    @objc private func profileImageTapped() {
        profileImageButton.openImagePicker(in: self)
    }
}

// MARK: - 이미지 피커 관련
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

// MARK: - 텍스트 뷰 관련
extension MeetingCreateViewController: UITextViewDelegate {
    
    func shakeAnimation(for view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.5
        animation.values = [-2, 2, -2, 2, -2, 2] // 애니메이션 값 조정
        view.layer.add(animation, forKey: "shake")
    }
    
    // 초기 호출
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        // 이름 textView
        if textView == meetingNameTextView {
            if meetingNameTextView.textColor == UIColor(color: .placeholder) {
                
                meetingNameTextView.text = nil
                meetingNameTextView.textColor = UIColor.black
            }
        }
        
        // 내용 textView
        if textView == meetingDescriptionTextView {
            if meetingDescriptionTextView.textColor == UIColor(color: .placeholder) {
                
                meetingDescriptionTextView.text = nil
                meetingDescriptionTextView.textColor = UIColor.black
            }
        }
    }
    
    // 입력 시 호출
    func textViewDidChange(_ textView: UITextView) {
        
        if textView == meetingNameTextView {
            let textCount = textView.text.count
            countMeetingNameLabel.text = "(\(textCount)/10)"
            
            if textCount == 0 {
                countMeetingNameLabel.textColor = UIColor(color: .placeholder)
            } else {
                countMeetingNameLabel.textColor = UIColor.black
            }
        }
        
        if textView == meetingDescriptionTextView {
            let textCount = textView.text.count
            countDescriptionLabel.text = "(\(textCount)/300)"
            
            if textCount == 0 {
                countDescriptionLabel.textColor = UIColor(color: .placeholder)
            } else {
                countDescriptionLabel.textColor = UIColor.black
            }
        }
        
        if !meetingNameTextView.text.isEmpty, meetingNameTextView.textColor ==  UIColor.black, meetingDescriptionTextView.textColor == UIColor.black ,!meetingDescriptionTextView.text.isEmpty {
            createFinishButton.isEnabled = true
        }
        else {
            createFinishButton.isEnabled = false
        }
    }
    
    // 입력 종료 시 호출
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if meetingNameTextView.text.isEmpty {
            meetingNameTextView.text = "모임 이름을 입력해주세요."
            meetingNameTextView.textColor = UIColor(color: .placeholder)
        }
        
        if meetingDescriptionTextView.text.isEmpty {
            meetingDescriptionTextView.text = "모임에 대한 소개를 입력해주세요."
            meetingDescriptionTextView.textColor = UIColor(color: .placeholder)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        if textView == meetingNameTextView {
            if changedText.count > 10 {
                countMeetingNameLabel.textColor = UIColor.red
                shakeAnimation(for: countMeetingNameLabel)
                return false
            }
            return true
        }
        
        if textView == meetingDescriptionTextView {
            if changedText.count > 300 {
                countDescriptionLabel.textColor = UIColor.red
                shakeAnimation(for: countDescriptionLabel)
                return false
            }
            return true
        }
        return true
    }
    
    
    
//    func textViewDidChange(_ textView: UITextView) {
////        placeholderLabel.isHidden = !textView.text.isEmpty
//        countDescriptionTextView.text = "\(textView.text.count)/300"
//        updateFinishButtonState()
//        
//        if textView.text.count > 300 {
//            shakeAnimation(for: countDescriptionTextView)
//            countDescriptionTextView.textColor = .red
//        } else {
//            countDescriptionTextView.textColor = .black
//        }
//    }
//    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        let currentText = textView.text ?? ""
//        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: text)
//        
//        if prospectiveText.count > 301 {
//            return false
//        }
//        return true
//    }
}


extension MeetingCreateViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == meetingNameTextView else {
            return true
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
                updateFinishButtonState()
            }
        
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        countMeetingNameLabel.text = "\(prospectiveText.count)/16"
        
        if prospectiveText.count > 16 {
            shakeAnimation(for: countMeetingNameLabel)
            countMeetingNameLabel.textColor = .red
            return false
        } else {
            countMeetingNameLabel.textColor = .black
        }
        
        return true
        
    }
}

// 키보드 올라왔을 때 화면 터치시 키보드 내리는 로직을 uiviewcontroller 에 대해 익스텐션으로 추가해서
// self.hideKeyboardWhenTappedAround() 만 추가하면 모든 뷰컨트롤러에서 적용

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}



