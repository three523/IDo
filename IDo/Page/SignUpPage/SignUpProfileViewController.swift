//
//  SingUpProfileViewController.swift
//  IDo
//
//  Created by 김도현 on 2023/10/23.
//

import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SnapKit
import UIKit

class SignUpProfileViewController: UIViewController {
    private let email: String
    private let password: String
    private let selectedCategorys: [String]
    private var user: IDoUser?
    private let fbUserDatabaseManager: FirebaseCreateUserManager = .init(refPath: ["Users"])
    private let imagePickerViewController: UIImagePickerController = .init()
    private var bottomButtonConstraint: Constraint?
    
    private var aboutUs: String = ""
    private var nickName: String = ""
    
    init(email: String, password: String, selectedCategorys: [String]) {
        self.email = email
        self.password = password
        self.selectedCategorys = selectedCategorys
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // 백 버튼 아이템 생성 및 설정
        NavigationBar.setNavigationBackButton(for: navigationItem, title: "")
        
        // 타이틀 생성 및 설정
        if let navigationBar = self.navigationController?.navigationBar {
            NavigationBar.setNavigationTitle(for: navigationItem, in: navigationBar, title: "프로필 생성")
        }
        
        setup()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        addKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        removeKeyboardNotifications()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.nickNameTextView.resignFirstResponder()
        self.descriptionTextView.resignFirstResponder()
    }
    
    // MARK: - 컴포넌트 생성
    private let profileImageView: UIImageView = .init(image: UIImage(systemName: "camera.circle.fill"))
    
//    private let nickNameTextField: UITextField = {
//        let textField = UITextField()
//        textField.font = .bodyFont(.large, weight: .regular)
//        textField.textColor = UIColor(color: .textStrong)
//        textField.placeholder = "닉네임을 입력해주세요(10자 이내)"
//        textField.borderStyle = .roundedRect
//        textField.layer.cornerRadius = 5.0
//        textField.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
//        textField.layer.borderWidth = 1.0
//
//        return textField
//    }()
    
    // 닉네임 입력 TextView
    private(set) lazy var nickNameTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor(color: .backgroundPrimary)
        textView.font = UIFont.bodyFont(.large, weight: .medium)
        textView.text = "닉네임을 입력해주세요"
        textView.textColor = UIColor(color: .placeholder)
        textView.layer.cornerRadius = 5
        textView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        textView.layer.borderWidth = 1.0
        textView.resignFirstResponder()
        return textView
    }()
    
    // 닉네임 글자 수 표시 label
    private(set) lazy var nickNameCountLabel: UILabel = {
        var label = UILabel()
        label.text = "(0/10)"
        label.textColor = UIColor(color: .placeholder)
        label.font = UIFont.bodyFont(.small, weight: .regular)
        return label
    }()
    
    // 자기소개 입력 TextView
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor(color: .backgroundPrimary)
        textView.font = UIFont.bodyFont(.medium, weight: .regular)
        textView.text = "자기소개를 입력해주세요"
        textView.textColor = UIColor(color: .placeholder)
        //textView.textAlignment = .left
        textView.layer.cornerRadius = 5.0
        textView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        textView.layer.borderWidth = 1.0
        textView.resignFirstResponder()
        return textView
    }()
    
    // 자기소개 글자 수 표시 label
    private(set) lazy var descriptionCountLabel: UILabel = {
        var label = UILabel()
        label.text = "(0/300)"
        label.textColor = UIColor(color: .placeholder)
        label.font = UIFont.bodyFont(.small, weight: .regular)
        return label
    }()

    private let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("완료", for: .normal)
        button.setTitleColor(UIColor(color: .white), for: .normal)
        button.titleLabel?.font = UIFont.bodyFont(.large, weight: .medium)
        button.backgroundColor = UIColor(color: .contentPrimary)
        button.layer.cornerRadius = 5
        return button
    }()

//    let aboutUsLabel: UILabel = {
//        let label = UILabel()
//        label.text = "자기소개를 입력해주세요."
//        label.font = UIFont(name: "SF Pro", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .regular)
//        label.textColor = UIColor.placeholderText
//
//        return label
//    }()


    // MARK: - 노티피케이션 관련
    // 노티피케이션을 추가하는 메서드
    func addKeyboardNotifications() {
        // 키보드가 나타날 때 앱에게 알리는 메서드 추가
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        // 키보드가 사라질 때 앱에게 알리는 메서드 추가
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // 노티피케이션을 제거하는 메서드
    func removeKeyboardNotifications() {
        // 키보드가 나타날 때 앱에게 알리는 메서드 제거
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        // 키보드가 사라질 때 앱에게 알리는 메서드 제거
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(_ noti: NSNotification) {
        if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height

            if #available(iOS 11.0, *) {
                let bottomInset = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.bottom ?? 0
                let adjustedKeyboardHeight = keyboardHeight - bottomInset
                bottomButtonConstraint?.update(inset: adjustedKeyboardHeight + Constant.margin3)
            } else {
                bottomButtonConstraint?.update(inset: keyboardHeight + Constant.margin3)
            }

            view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(_ noti: NSNotification) {
        bottomButtonConstraint?.update(inset: Constant.margin3)
        view.layoutIfNeeded()
    }
}

private extension SignUpProfileViewController {
    
    // MARK: - UI 및 오토레이아웃 관련
    func setup() {
        addViews()
        setupAutoLayout()
        setupTextField()
        setupImagePicker()
        setupImageView()
        setupButton()
    }

    func addViews() {
        view.addSubview(profileImageView)
        //view.addSubview(nickNameTextField)
        view.addSubview(nickNameTextView)
        view.addSubview(nickNameCountLabel)
        view.addSubview(descriptionTextView)
        view.addSubview(descriptionCountLabel)
        view.addSubview(signUpButton)
        //view.addSubview(aboutUsLabel)
    }

    func setupAutoLayout() {
        let safeArea = view.safeAreaLayoutGuide
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(safeArea).inset(Constant.margin3)
            make.centerX.equalTo(safeArea)
            make.width.height.equalTo(90)
        }
//        nickNameTextField.snp.makeConstraints { make in
//            make.top.equalTo(profileImageView.snp.bottom).offset(Constant.margin2)
//            make.left.right.equalTo(safeArea).inset(Constant.margin4)
//        }
        nickNameTextView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(Constant.margin3)
            make.left.right.equalTo(safeArea).inset(Constant.margin4)
            make.height.equalTo(40)
        }
        
        nickNameCountLabel.snp.makeConstraints { make in
            make.top.equalTo(nickNameTextView.snp.bottom).offset(Constant.margin1)
            make.trailing.equalTo(safeArea.snp.trailing).inset(Constant.margin4)
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(nickNameCountLabel.snp.bottom).offset(Constant.margin4)
            make.left.right.equalTo(safeArea).inset(Constant.margin4)
            make.height.equalTo(200)
        }
        descriptionCountLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextView.snp.bottom).offset(Constant.margin1)
            make.trailing.equalTo(safeArea.snp.trailing).inset(Constant.margin4)
        }

//        aboutUsLabel.snp.makeConstraints { make in
//            make.top.equalTo(aboutUsTextView).offset(12)
//            make.left.equalTo(aboutUsTextView).offset(12.8) // textview, textfield 간의 placeholder margin 차이로 인해 미세한 위치조정
//        }
        signUpButton.snp.makeConstraints { make in
            
            make.left.right.equalTo(safeArea).inset(Constant.margin4)
            make.bottom.equalTo(safeArea).inset(Constant.margin3)
//            self.bottomButtonConstraint = make.bottom.equalTo(safeArea).inset(Constant.margin3).constraint
            make.height.equalTo(48)
        }
    }
    
    // MARK: - 컴포넌트 세팅 관련
    func setupTextField() {
//        nickNameTextField.delegate = self
        nickNameTextView.delegate = self
        descriptionTextView.delegate = self
    }

    func setupImageView() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(profileImagePick))
        profileImageView.addGestureRecognizer(gesture)
        profileImageView.isUserInteractionEnabled = true
        profileImageView.layoutIfNeeded()
        profileImageView.tintColor = UIColor(color: .contentBackground)
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.layer.masksToBounds = true
    }

    @objc func profileImagePick() {
        present(imagePickerViewController, animated: true)
    }

    func setupImagePicker() {
        imagePickerViewController.sourceType = .photoLibrary
        imagePickerViewController.delegate = self
    }

    func setupButton() {
        signUpButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
    }

    @objc func signUp() {
        guard !nickNameTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, nickNameTextView.textColor == UIColor.black else {
//            showAlert(message: "닉네임을 입력해주세요")
            AlertManager.showAlert(on: self, title: "알림", message: "닉네임을 입력해주세요.")
            return
        }
        guard !descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, descriptionTextView.textColor == UIColor.black else {
//            showAlert(message: "자기소개를 입력해주세요")
            AlertManager.showAlert(on: self, title: "알림", message: "자기소개를 입력해주세요.")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authDataResult, error in
            guard let self = self else { return }
            if let error {
//                self.showAlert(message: "로그인에 실패하였습니다.")
                AlertManager.showAlert(on: self, title: "알림", message: "로그인에 실패하였습니다.")
                return
            }
            guard let authDataResult = authDataResult else { return }
            let uid = authDataResult.user.uid
            var user = IDoUser(id: uid, updateAt: Date().toString(), email: email, nickName: nickNameTextView.text, description: descriptionTextView.text, hobbyList: self.selectedCategorys)

            self.fbUserDatabaseManager.model = user
            self.fbUserDatabaseManager.appendData(data: user)
            self.fbUserDatabaseManager.addImage(uid: uid, image: profileImageView.image)
            self.firebaseLogin()
        }
    }

//    func showAlert(message: String) {
//        DispatchQueue.main.async {
//            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
//            alert.addAction(okAction)
//            self.present(alert, animated: true, completion: nil)
//        }
//    }

    func firebaseLogin() {
        Auth.auth().signIn(withEmail: email, password: password) { authData, error in
            if let error {
                print("Login Error: \(error.localizedDescription)")
                return
            }
            guard let authData else { return }
            let uid = authData.user.uid
            MyProfile.shared.getUserProfile(uid: uid) { isSuccess in
                guard isSuccess else {
                    print("사용자 정보를 가져오지 못했습니다.")
                    return
                }
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(TabBarController(), animated: true)
            }
        }
    }
}

// MARK: - 텍스트 뷰 관련
extension SignUpProfileViewController: UITextViewDelegate {
    
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
        if textView == nickNameTextView {
            if nickNameTextView.textColor == UIColor(color: .placeholder) {
                
                nickNameTextView.text = nil
                nickNameTextView.textColor = UIColor.black
            }
        }
        
        // 내용 textView
        if textView == descriptionTextView {
            if descriptionTextView.textColor == UIColor(color: .placeholder) {
                
                descriptionTextView.text = nil
                descriptionTextView.textColor = UIColor.black
            }
        }
    }
    
    // 입력 시 호출
    func textViewDidChange(_ textView: UITextView) {
        
        if textView == nickNameTextView {
            let textCount = textView.text.count
            nickNameCountLabel.text = "(\(textCount)/10)"
            
            if textCount == 0 {
                nickNameCountLabel.textColor = UIColor(color: .placeholder)
            } else {
                nickNameCountLabel.textColor = UIColor.black
            }
        }
        
        if textView == descriptionTextView {
            let textCount = textView.text.count
            descriptionCountLabel.text = "(\(textCount)/300)"
            
            if textCount == 0 {
                descriptionCountLabel.textColor = UIColor(color: .placeholder)
            } else {
                descriptionCountLabel.textColor = UIColor.black
            }
        }
    }
    
    // 입력 종료 시 호출
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if nickNameTextView.text.isEmpty {
            nickNameTextView.text = "닉네임을 입력해주세요."
            nickNameTextView.textColor = UIColor(color: .placeholder)
        }
        
        if descriptionTextView.text.isEmpty {
            descriptionTextView.text = "자기소개를 입력해주세요."
            descriptionTextView.textColor = UIColor(color: .placeholder)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        if textView == nickNameTextView {
            if changedText.count > 10 {
                nickNameCountLabel.textColor = UIColor.red
                shakeAnimation(for: nickNameCountLabel)
                return false
            }
            return true
        }
        
        if textView == descriptionTextView {
            if changedText.count > 300 {
                descriptionCountLabel.textColor = UIColor.red
                shakeAnimation(for: descriptionCountLabel)
                return false
            }
            return true
        }
        return true
    }
    
//    func textViewDidChange(_ textView: UITextView) {
//        aboutUsLabel.isHidden = !textView.text.isEmpty
//        countDescriptionLabel.text = "\(textView.text.count)/300"
//
//        if textView.text.count >= 300 {
//            shakeAnimation(for: countDescriptionLabel)
//            countDescriptionLabel.textColor = .red
//        } else {
//            countDescriptionLabel.textColor = .black
//        }
//    }
//
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        let currentText = textView.text ?? ""
//        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: text)
//
//        if prospectiveText.count > 300 {
//            return false
//        }
//        return true
//    }
}

// MARK: - 이미지 피커 관련
extension SignUpProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) {
            if let image = info[.editedImage] as? UIImage {
                self.profileImageView.image = image
            } else if let image = info[.originalImage] as? UIImage {
                self.profileImageView.image = image
            }
        }
    }
}

extension SignUpProfileViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return range.location < 10
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        nickName = text
    }
}
