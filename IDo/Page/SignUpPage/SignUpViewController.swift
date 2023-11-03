//
//  SignUpViewController.swift
//  IDo
//
//  Created by 김도현 on 2023/10/20.
//

import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import SwiftSMTP
import UIKit
final class SignUpViewController: UIViewController {
    var smtp: SMTP!
    var verificationCode: String?
    var isEmailChecked: Bool = false
    var isButtonClicked: Bool = false

    var passwordErrorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.text = "(최소 8자, 소문자, 숫자, 특수문자 필요)"
        label.font = UIFont.systemFont(ofSize: 12)
        label.isHidden = true
        return label
    }()

    var passwordConfirmErrorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .green
        label.font = UIFont.systemFont(ofSize: 12)
        label.isHidden = true
        return label
    }()

    var eyeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.backgroundColor = .clear
        button.tintColor = .black
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.setImage(UIImage(systemName: "eye"), for: .selected)

        return button
    }()

    var confirmEyeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.backgroundColor = .clear
        button.tintColor = .black
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.setImage(UIImage(systemName: "eye"), for: .selected)

        return button
    }()

    private let backButton: UIButton = {
        let button = UIButton()
        button.setTitle("〈 뒤로가기", for: .normal)
        button.titleLabel?.font = UIFont.bodyFont(.large, weight: .medium)
        button.setTitleColor(UIColor(color: .contentPrimary), for: .normal)
        return button
    }()

    private let linkButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("중복확인", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.setTitleColor(UIColor(color: .text2), for: .normal)

        return btn
    }()

    private let idLable: UILabel = {
        let label = UILabel()
        label.text = "이메일"
        return label
    }()

    private let passwordLable: UILabel = {
        let label = UILabel()
        label.text = "비밀번호"
        return label
    }()

    private let passwordConfirmLable: UILabel = {
        let label = UILabel()
        label.text = "비밀번호 재확인"
        return label
    }()

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이메일을 입력해주세요"
        textField.font = .bodyFont(.large, weight: .regular)
        textField.textColor = UIColor(color: .textStrong)
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        
        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호를 입력해주세요"
        textField.font = .bodyFont(.large, weight: .regular)
        textField.textColor = UIColor(color: .textStrong)
        textField.autocapitalizationType = .none
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.textContentType = .oneTimeCode
        return textField
    }()

    private let passwordConfirmTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호를 재입력해주세요"
        textField.font = .bodyFont(.large, weight: .regular)
        textField.textColor = UIColor(color: .textStrong)
        textField.autocapitalizationType = .none
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.textContentType = .oneTimeCode
        return textField
    }()

    private let authenticationNumberTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "인증번호"
        textField.font = .bodyFont(.medium, weight: .regular)
        textField.textColor = UIColor(color: .textStrong)
        textField.borderStyle = .roundedRect
        return textField
    }()

    private let emailAuthorizationButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("인증", for: .normal)
        btn.setTitleColor(UIColor(color: .white), for: .normal)
        btn.backgroundColor = UIColor(color: .contentPrimary)
        btn.layer.cornerRadius = 5
        return btn
    }()

    private let authenticationNumberButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("확인", for: .normal)
        btn.setTitleColor(UIColor(color: .white), for: .normal)
        btn.backgroundColor = UIColor(color: .contentPrimary)
        btn.layer.cornerRadius = 5
        return btn
    }()

    lazy var checkButton: UIButton = {
        var button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "rectangle"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.rectangle"), for: .selected)
        button.layer.cornerRadius = 5
        button.backgroundColor = .white

        return button
    }()

    private let termsLabel: UILabel = {
        let label = UILabel()
        label.text = "귀하는 IDo의 서비스 이용에 필요한 최소한의 개인정보 수집·이용에 동의하지 않을 수 있으나 동의를 거부할 경우 회원제 서비스 이용이 불가합니다."
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .left
        label.numberOfLines = 3
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    lazy var termsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [checkButton, termsLabel])
        stackView.spacing = 12
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()

    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("회원가입", for: .normal)
        button.setTitleColor(UIColor(color: .white), for: .normal)
        button.backgroundColor = UIColor(color: .contentPrimary)
        button.layer.cornerRadius = 5
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let backBarButtonItem = UIBarButtonItem(title: "뒤로가기", style: .plain, target: self, action: nil)
        backBarButtonItem.tintColor = .black
        navigationItem.backBarButtonItem = backBarButtonItem
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

private extension SignUpViewController {
    func setup() {
        view.backgroundColor = .white
        addViews()
        autolayoutSetup()
        setupButton()
        setupKeyboardEvent()
        passwordTextField.delegate = self
        passwordConfirmTextField.delegate = self
    }
    
    func addViews() {
        view.addSubview(emailTextField)
        view.addSubview(linkButton)
        view.addSubview(passwordTextField)
        view.addSubview(nextButton)
        view.addSubview(backButton)
        view.addSubview(idLable)
        view.addSubview(passwordLable)
        view.addSubview(passwordConfirmLable)
        view.addSubview(passwordTextField)
        view.addSubview(passwordConfirmTextField)
        view.addSubview(emailAuthorizationButton)
        view.addSubview(authenticationNumberTextField)
        view.addSubview(authenticationNumberButton)
        view.addSubview(passwordErrorLabel)
        view.addSubview(passwordConfirmErrorLabel)
        view.addSubview(termsStackView)
    }
    
    func autolayoutSetup() {
        let safeArea = view.safeAreaLayoutGuide
        backButton.snp.makeConstraints { make in
            make.top.left.equalTo(safeArea).inset(Constant.margin3)
        }
        passwordTextField.rightView = eyeButton
        passwordTextField.rightViewMode = .always
        
        passwordConfirmTextField.rightView = confirmEyeButton
        passwordConfirmTextField.rightViewMode = .always
        let contentHeight = 48
        
        idLable.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(Constant.margin3)
            make.leading.trailing.equalToSuperview().inset(Constant.margin4)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(idLable.snp.bottom).offset(Constant.margin2)
            make.left.equalToSuperview().inset(Constant.margin4)
            make.height.equalTo(contentHeight)
        }
        
        linkButton.snp.makeConstraints { make in
            make.centerY.equalTo(emailTextField)
            make.trailing.equalTo(emailTextField.snp.trailing).inset(5)
        }
        emailAuthorizationButton.snp.makeConstraints { make in
            make.centerY.equalTo(emailTextField)
            make.right.equalToSuperview().inset(Constant.margin4)
            make.width.equalTo(60)
            make.height.equalTo(contentHeight)
            make.left.equalTo(emailTextField.snp.right).offset(Constant.margin2)
        }
        authenticationNumberTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(Constant.margin2)
            make.left.equalToSuperview().inset(Constant.margin4)
            make.height.equalTo(contentHeight)
        }
        
        authenticationNumberButton.snp.makeConstraints { make in
            make.centerY.equalTo(authenticationNumberTextField)
            make.right.equalToSuperview().inset(Constant.margin4)
            make.width.equalTo(60)
            make.height.equalTo(contentHeight)
            make.left.equalTo(authenticationNumberTextField.snp.right).offset(Constant.margin2)
        }
        
        passwordLable.snp.makeConstraints { make in
            make.top.equalTo(authenticationNumberButton.snp.bottom).offset(Constant.margin3)
            make.leading.trailing.equalToSuperview().inset(Constant.margin4)
        }
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLable.snp.bottom).offset(Constant.margin2)
            make.left.right.equalToSuperview().inset(Constant.margin4)
            make.height.equalTo(contentHeight)
        }
        passwordErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(Constant.margin1)
            make.leading.trailing.equalToSuperview().inset(Constant.margin4)
        }
        passwordConfirmLable.snp.makeConstraints { make in
            make.top.equalTo(passwordErrorLabel.snp.bottom).offset(Constant.margin2)
            make.left.right.equalToSuperview().inset(Constant.margin4)
        }
        passwordConfirmTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordConfirmLable.snp.bottom).offset(Constant.margin2)
            make.left.right.equalToSuperview().inset(Constant.margin4)
            make.height.equalTo(contentHeight)
        }
        passwordConfirmErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordConfirmTextField.snp.bottom).offset(Constant.margin1)
            make.left.right.equalToSuperview().inset(Constant.margin4)
        }
        
        termsStackView.snp.makeConstraints { make in
            make.top.equalTo(passwordConfirmErrorLabel.snp.bottom).offset(Constant.margin2)
            make.left.equalToSuperview().inset(Constant.margin4)
            make.right.equalToSuperview().inset(Constant.margin4)
        }
        checkButton.snp.makeConstraints { make in
            make.width.equalTo(15)
            make.height.equalTo(15)
        }
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeArea).inset(Constant.margin3)
            make.left.right.equalToSuperview().inset(Constant.margin3)
            make.height.equalTo(48)
        }
    }
    
    func setupButton() {
        nextButton.addTarget(self, action: #selector(clickNextButton), for: .touchUpInside)
        
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
        
        eyeButton.addTarget(self, action: #selector(eyeClickButton), for: .touchUpInside)
        
        confirmEyeButton.addTarget(self, action: #selector(confirmEyeClickButton), for: .touchUpInside)
        
        linkButton.addTarget(self, action: #selector(clickLinkButton), for: .touchUpInside)
        
        emailAuthorizationButton.addTarget(self, action: #selector(addSMTPButton), for: .touchUpInside)
        
        authenticationNumberButton.addTarget(self, action: #selector(addSMTPNumberButton), for: .touchUpInside)
        
        checkButton.addTarget(self, action: #selector(checkButtonAction), for: .touchUpInside)
    }
    
    @objc func clickNextButton() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty
        else {
            showAlertDialog(title: "경고", message: "이메일 또는 비밀번호를 입력하세요.")
            return
        }
        
        guard password.isValidPassword() else {
            showAlertDialog(title: "경고", message: "비밀번호가 안전하지 않습니다.")
            return
        }
        guard let confirmPassword = passwordConfirmTextField.text, !confirmPassword.isEmpty else {
            showAlertDialog(title: "경고", message: "비밀번호 재확인을 입력하세요.")
            return
        }
        
        guard password == confirmPassword else {
            showAlertDialog(title: "경고", message: "비밀번호와 비밀번호 재확인이 일치하지 않습니다.")
            return
        }
        guard checkButton.isSelected else {
            showAlertDialog(title: "경고", message: "약관에 동의해주세요.")
            return
        }
        if authenticationNumberButton.title(for: .normal) != "완료" {
            if authenticationNumberTextField.text?.isEmpty == true {
                showAlertDialog(title: "경고", message: "인증번호를 입력해주세요")
            } else {
                showAlertDialog(title: "경고", message: "인증번호를 확인해주세요")
            }
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] _, error in
            if let error = error {
                let nsError = error as NSError
                let errorCode = AuthErrorCode(_nsError: nsError)
                print(errorCode)
                switch errorCode.code {
                case .emailAlreadyInUse:
                    self?.showAlertDialog(title: "경고", message: "이미 사용 중인 이메일입니다. 다른 이메일을 사용해주세요.")
                    self?.emailAuthorizationButton.isEnabled = true
                    self?.emailAuthorizationButton.setTitleColor(UIColor(color: .white), for: .normal)
                    self?.emailAuthorizationButton.backgroundColor = UIColor(color: .contentPrimary)
                    return
                case .weakPassword:
                    self?.showAlertDialog(title: "경고", message: "안정성이 낮은 비밀번호입니다.")
                case .invalidEmail:
                    self?.showAlertDialog(title: "경고", message: "이메일 주소의 형식이 잘못되었습니다.")
                default:
                    self?.showAlertDialog(title: "오류", message: error.localizedDescription)
                    return
                }
            } else {
                let categoryVC = CategorySelectViewController(email: email, password: password)
                self?.navigationController?.pushViewController(categoryVC, animated: true)
            }
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    func showAlertDialog(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func smtpNumberCode(completion: @escaping (Bool) -> Void) {
        guard let userInputCode = authenticationNumberTextField.text else {
            completion(false)
            return
        }
        if let savedCode = UserDefaults.standard.string(forKey: "emailVerificationCode"), savedCode == userInputCode {
            completion(true)
        } else {
            emailAuthorizationButton.isEnabled = true
            authenticationNumberTextField.text = ""
            showAlertDialog(title: "경고", message: "인증번호가 일치하지 않습니다.")
            
            // 인증에 실패한 경우 false를 반환
            completion(false)
        }
    }
    
    func verifyButtonPressed(_ sender: UIButton) {
        smtpNumberCode { _ in
            print("success")
        }
    }
    
    func setupKeyboardEvent() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        // keyboardFrame: 현재 동작하고 있는 이벤트에서 키보드의 frame을 받아옴
        // currentTextField: 현재 응답을 받고있는 UITextField를 알아냅니다.
        guard let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let currentTextField = UIResponder.currentResponder as? UITextField else { return }
        
        // Y축으로 키보드의 상단 위치
        let keyboardTopY = keyboardFrame.cgRectValue.origin.y
        // 현재 선택한 텍스트 필드의 Frame 값
        let convertedTextFieldFrame = view.convert(currentTextField.frame,
                                                   from: currentTextField.superview)
        // Y축으로 현재 텍스트 필드의 하단 위치
        let textFieldBottomY = convertedTextFieldFrame.origin.y + convertedTextFieldFrame.size.height
        
        // Y축으로 텍스트필드 하단 위치가 키보드 상단 위치보다 클 때 (즉, 텍스트필드가 키보드에 가려질 때가 되겠죠!)
        if textFieldBottomY > keyboardTopY {
            let textFieldTopY = convertedTextFieldFrame.origin.y
            // 노가다를 통해서 모든 기종에 적절한 크기를 설정함.
            let newFrame = textFieldTopY - keyboardTopY / 1.6
            view.frame.origin.y -= newFrame
        }
    }

    @objc func keyboardWillHide(_ sender: Notification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }

    @objc func addSMTPButton() {
        guard isButtonClicked else {
            showAlertDialog(title: "경고", message: "중복확인 버튼을 눌러주세요.")
            return
        }
        guard let emailText = emailTextField.text,
              !emailText.isEmpty,
              emailText.isValidEmail()
        else {
            showAlertDialog(title: "알림", message: "이메일 형식이 잘못되었거나 이메일이 비어있습니다.")
            return
        }
        
        let smtp = SMTP(hostname: "smtp.naver.com", email: "ido345849@naver.com", password: "UX5W8Y7VUHLW")
        
        let drLight = Mail.User(name: "iDo", email: "ido345849@naver.com")
        let megaman = Mail.User(name: "사용자", email: emailTextField.text!)
        
        let code = "\(Int.random(in: 100000 ... 999999))"
        
        let mail = Mail(from: drLight, to: [megaman], subject: "IDo 이메일 코드", text: "인증 번호 \(code) \n" + "IDo 앱으로 돌아가 인증 번호를 입력해주세요.")
        
        DispatchQueue.global().async {
            smtp.send(mail) { [weak self] error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("전송 실패: \(error)")
                        self?.showAlertDialog(title: "오류", message: "인증 번호를 보내는데 실패했습니다.")
                    } else {
                        print("전송 성공!")
                        UserDefaults.standard.set(code, forKey: "emailVerificationCode")
                        self?.showAlertDialog(title: "성공", message: "인증 번호가 이메일로 발송되었습니다.")
                    }
                }
            }
        }
    }
    
    @objc func addSMTPNumberButton() {
        // 1. 입력된 이메일의 상태를 확인합니다.
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlertDialog(title: "경고", message: "이메일을 입력해주세요.")
            return
        }
        
        Auth.auth().fetchSignInMethods(forEmail: email) { [weak self] signInMethods, error in
            if let error = error {
                print("Error checking for email existence: \(error)")
                self?.showAlertDialog(title: "오류", message: "이메일 확인 중 오류가 발생했습니다.")
                return
            }
            
            if let signInMethods = signInMethods, !signInMethods.isEmpty {
                self?.emailAuthorizationButton.isEnabled = true
                self?.emailAuthorizationButton.setTitleColor(.blue, for: .normal) // 원하는 색상으로 변경
                self?.emailAuthorizationButton.backgroundColor = .white // 원하는 배경색으로 변경
            } else {
                self?.smtpNumberCode { success in
                    if success {
                        self?.showAlertDialog(title: "인증", message: "인증이 성공적으로 처리되었습니다")
                        self?.authenticationNumberButton.setTitle("완료", for: .normal)
                        self?.emailAuthorizationButton.isEnabled = false
                        self?.emailAuthorizationButton.setTitleColor(.white, for: .normal)
                        self?.emailAuthorizationButton.backgroundColor = .lightGray
                    }
                }
            }
        }
    }
    
    @objc func eyeClickButton() {
        passwordTextField.isSecureTextEntry.toggle()
        eyeButton.isSelected.toggle()
    }
    
    @objc func confirmEyeClickButton() {
        passwordConfirmTextField.isSecureTextEntry.toggle()
        confirmEyeButton.isSelected.toggle()
    }
    
    @objc func clickBackButton() {
        dismiss(animated: true)
    }
    
    @objc func clickLinkButton() {
        isButtonClicked = true
        print("중복 확인 버튼이 클릭되었습니다")
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlertDialog(title: "경고", message: "이메일을 입력해주세요.")
            return
        }
        
        guard isValidEmail(email) else {
            showAlertDialog(title: "경고", message: "올바른 이메일 형식을 입력해주세요.")
            return
        }

        print("중복확인: \(email)")
        let firebaseManager: FBDatabaseManager<IDoUser> = FBDatabaseManager(refPath: ["Users"])
        firebaseManager.readDatas(completion: { result in
            switch result {
            case .success(let users):
                let emailList = users.compactMap { $0.email }
                if emailList.contains(email) {
                    self.showAlertDialog(title: "경고", message: "현재 사용 중인 아이디입니다.")
                } else {
                    self.isEmailChecked = true
                    self.showAlertDialog(title: "알림", message: "사용 가능한 아이디입니다.")
                }
            case .failure(let error):
                print(error.localizedDescription)
                self.showAlertDialog(title: "오류", message: "중복 확인 중 오류가 발생했습니다.")
            }
        })
    }
    
    @objc func checkButtonAction(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
}

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.(com|co\\.kr|net)"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }

    func isValidPassword() -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,50}"
        if NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: self) {
            return true
        } else {
            if count < 8 {
                print("비밀번호는 최소 8자 이상이어야 합니다.")
            }
            return false
        }
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let currentText = textField.text ?? ""
        
        if textField == passwordTextField {
            // passwordTextField의 유효성 검사
            passwordErrorLabel.isHidden = currentText.isValidPassword()
            validatePasswordConfirm()
        } else if textField == passwordConfirmTextField {
            validatePasswordConfirm()
        }
    }

    private func validatePasswordConfirm() {
        let passwordText = passwordTextField.text ?? ""
        let passwordConfirmText = passwordConfirmTextField.text ?? ""

        if passwordText == passwordConfirmText {
            passwordConfirmErrorLabel.isHidden = false
            passwordConfirmErrorLabel.textColor = .green
            passwordConfirmErrorLabel.text = "비밀번호가 일치합니다."
        } else if !passwordConfirmText.isEmpty {
            passwordConfirmErrorLabel.textColor = .red
            passwordConfirmErrorLabel.isHidden = false
            passwordConfirmErrorLabel.text = "비밀번호가 일치하지 않습니다."
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTextField {
            view.frame.origin.y = 0
               
        } else if textField == passwordTextField || textField == passwordConfirmTextField || textField == authenticationNumberTextField {
            // 부드러운 효과를 위해 애니메이션 처리
            UIView.animate(withDuration: 0.3) {
                let transform = CGAffineTransform(translationX: 0, y: -100)
                self.view.transform = transform
            }
        }
    }
       
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField {
            view.frame.origin.y = 0
               
        } else if textField == passwordTextField {
            UIView.animate(withDuration: 0.3) {
                let transform = CGAffineTransform(translationX: 0, y: 0)
                self.view.transform = transform
            }
        }
    }
}

extension UIResponder {
    private enum Static {
        weak static var responder: UIResponder?
    }
    
    static var currentResponder: UIResponder? {
        Static.responder = nil
        UIApplication.shared.sendAction(#selector(UIResponder._trap), to: nil, from: nil, for: nil)
        return Static.responder
    }
    
    @objc private func _trap() {
        Static.responder = self
    }
}
