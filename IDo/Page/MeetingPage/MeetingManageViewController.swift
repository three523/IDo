import UIKit
import FirebaseDatabase
import FirebaseStorage

class MeetingManageViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        configureUI()
        meetingNameTextView.text = club.title
        meetingNameTextView.textColor = UIColor.black
        countMeetingNameLabel.text = "(\(meetingNameTextView.text.count)/16)"
        countMeetingNameLabel.textColor = UIColor.black
        
        meetingDescriptionTextView.text = club.description
        meetingDescriptionTextView.textColor = UIColor.black
        countDescriptionLabel.text = "(\(meetingDescriptionTextView.text.count)/300)"
        countDescriptionLabel.textColor = UIColor.black
        
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
//        placeholderLabel.isHidden = !meetingDescriptionField.text.isEmpty
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.meetingNameTextView.resignFirstResponder()
        self.meetingDescriptionTextView.resignFirstResponder()
    }
    
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
    
    var profileImageButton: MeetingProfileImageButton = {
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
    
//    let placeholderLabel: UILabel = {
//        let label = UILabel()
//        label.text = "모임에 대한 소개를 해주세요."
//        label.font = UIFont(name: "SF Pro", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .regular)
//        label.textColor = UIColor.placeholderText
//        return label
//    }()
    
    // 수정 버튼
    private let manageFinishButton = FinishButton(title: "수정 완료")
    
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
    
    // MARK: - UI 및 오토레이아웃 설정
    private func configureUI() {
        // UI 설정
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
        containerView.addSubview(manageFinishButton)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.bottom.equalTo(containerView.snp.bottom).offset(Constant.margin4)
        }
        
        containerView.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalTo(scrollView)
            make.width.equalTo(scrollView)
            make.bottom.equalTo(manageFinishButton.snp.bottom).offset(24)
        }
        
        
        let desiredAspectRatio: CGFloat = 2.0 / 3.0
        
        profileImageButton.snp.makeConstraints { (make) in
            make.top.equalTo(containerView.safeAreaLayoutGuide.snp.top).offset(Constant.margin3)
            make.centerX.equalTo(containerView)
            make.left.right.equalTo(containerView).inset(Constant.margin4)
            make.height.equalTo(profileImageButton.snp.width).multipliedBy(desiredAspectRatio)
        }
        
        meetingNameTextView.snp.makeConstraints { (make) in
            make.top.equalTo(profileImageButton.snp.bottom).offset(Constant.margin3)
            make.centerX.equalTo(containerView)
            make.left.right.equalTo(containerView).inset(Constant.margin4)
            make.height.equalTo(40)
        }
        
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
        
        countDescriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(meetingDescriptionTextView.snp.bottom).offset(Constant.margin1)
            make.right.equalTo(meetingDescriptionTextView.snp.right)
        }
        
        manageFinishButton.snp.makeConstraints { (make) in
            make.top.equalTo(countDescriptionLabel.snp.bottom).offset(Constant.margin4)
            make.centerX.equalTo(containerView)
            make.left.right.equalTo(containerView).inset(Constant.margin4)
            make.height.equalTo(48)
            //            make.bottom.equalTo(containerView.safeAreaLayoutGuide.snp.bottom).offset(-8)
        }
    }
    
    // MARK: - 버튼 클릭 관련
    @objc private func profileImageTapped() {
        profileImageButton.openImagePicker(in: self)
    }
    
    @objc func manageFinishButtonTapped() {
        guard let name = meetingNameTextView.text, !name.isEmpty,
              let description = meetingDescriptionTextView.text, let meetingImage = profileImageButton.imageView?.image else {
            
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

// MARK: - 이미지 피커 관련
extension MeetingManageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //                let roundedImage = selectedImage.resizedAndRoundedImage()
            profileImageButton.setImage(selectedImage, for: .normal)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - TextView 관련
extension MeetingManageViewController: UITextViewDelegate {
    
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
            manageFinishButton.isEnabled = true
        }
        else {
            manageFinishButton.isEnabled = false
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
//        placeholderLabel.isHidden = !textView.text.isEmpty
//        countDescriptionField.text = "\(textView.text.count)/300"
//        
//        if textView.text.count > 300 {
//            shakeAnimation(for: countDescriptionField)
//            countDescriptionField.textColor = .red
//        } else {
//            countDescriptionField.textColor = .black
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



