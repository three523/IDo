//
//  SignUpViewController.swift
//  IDo
//
//  Created by 김도현 on 2023/10/20.
//

import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import UIKit

final class SignUpViewController: UIViewController {
    var eyeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.backgroundColor = .clear
        button.tintColor = .black
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.setImage(UIImage(systemName: "eye.slash"), for: .selected)

        return button
    }()
    
    var confirmEyeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.backgroundColor = .clear
        button.tintColor = .black
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.setImage(UIImage(systemName: "eye.slash"), for: .selected)

        return button
    }()

    private let backButton: UIButton = {
        let button = UIButton()
        button.setTitle("back", for: .normal)
        button.setTitleColor(UIColor(color: .contentPrimary), for: .normal)
        return button
    }()

    private let linkButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("중복확인", for: .normal)
        btn.setTitleColor(UIColor(color: .text2), for: .normal)
        
        return btn
    }()

    private let idLable: UILabel = {
        let label = UILabel()
        label.text = "아이디"
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
    
    private let emailLable: UILabel = {
        let label = UILabel()
        label.text = "이메일 인증"
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "아이디를 입력해주세요"
        textField.font = .bodyFont(.medium, weight: .regular)
        textField.textColor = UIColor(color: .textStrong)
        textField.borderStyle = .roundedRect

        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호를 입력해주세요"
        textField.font = .bodyFont(.medium, weight: .regular)
        textField.textColor = UIColor(color: .textStrong)
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.textContentType = nil // 임시로 넣어둠
        return textField
    }()
    
    private let passwordConfirmTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호를 재입력해주세요"
        textField.font = .bodyFont(.medium, weight: .regular)
        textField.textColor = UIColor(color: .textStrong)
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.textContentType = nil // 임시로 넣어둠
        return textField
    }()
    
    private let emailAuthorizationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "유효한 이메일을 입력해주세요."
        textField.font = .bodyFont(.medium, weight: .regular)
        textField.textColor = UIColor(color: .textStrong)
        textField.borderStyle = .roundedRect
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
        btn.setTitleColor(UIColor(color: .text2), for: .normal)
        btn.backgroundColor = UIColor(color: .contentPrimary)
        btn.layer.cornerRadius = 5
        return btn
    }()
    
    private let authenticationNumberButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("확인", for: .normal)
        btn.setTitleColor(UIColor(color: .text2), for: .normal)
        btn.backgroundColor = UIColor(color: .contentPrimary)
        btn.layer.cornerRadius = 5
        return btn
    }()

    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.setTitleColor(UIColor(color: .white), for: .normal)
        button.backgroundColor = UIColor(color: .contentPrimary)
        button.layer.cornerRadius = 5
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        view.addSubview(emailLable)
        view.addSubview(emailAuthorizationTextField)
        view.addSubview(emailAuthorizationButton)
        view.addSubview(authenticationNumberTextField)
        view.addSubview(authenticationNumberButton)
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

        idLable.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(Constant.margin3)
            make.leading.trailing.equalToSuperview().inset(Constant.margin3)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(idLable.snp.bottom).offset(Constant.margin2)
            make.left.right.equalToSuperview().inset(Constant.margin3)
        }
        
        linkButton.snp.makeConstraints { make in
            make.centerY.equalTo(emailTextField)
            make.trailing.equalTo(emailTextField.snp.trailing).inset(5)
        }
        
        passwordLable.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(Constant.margin3)
            make.leading.trailing.equalToSuperview().inset(Constant.margin3)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLable.snp.bottom).offset(Constant.margin2)
            make.left.right.equalToSuperview().inset(Constant.margin3)
        }
        passwordConfirmLable.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(Constant.margin2)
            make.left.right.equalToSuperview().inset(Constant.margin3)
        }
        passwordConfirmTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordConfirmLable.snp.bottom).offset(Constant.margin2)
            make.left.right.equalToSuperview().inset(Constant.margin3)
        }
        emailLable.snp.makeConstraints { make in
            make.top.equalTo(passwordConfirmTextField.snp.bottom).offset(Constant.margin2)
            make.left.right.equalToSuperview().inset(Constant.margin3)
        }
        emailAuthorizationTextField.snp.makeConstraints { make in
            make.top.equalTo(emailLable.snp.bottom).offset(Constant.margin2)
            make.left.equalToSuperview().inset(Constant.margin3)
            make.width.equalTo(280)
        }
        
        emailAuthorizationButton.snp.makeConstraints { make in
            make.centerY.equalTo(emailAuthorizationTextField)
            make.right.equalToSuperview().inset(Constant.margin3)
            make.width.equalTo(60)
        }
        authenticationNumberTextField.snp.makeConstraints { make in
            make.top.equalTo(emailAuthorizationTextField.snp.bottom).offset(Constant.margin2)
            make.left.equalToSuperview().inset(Constant.margin3)
            make.width.equalTo(280)
        }
        
        authenticationNumberButton.snp.makeConstraints { make in
            make.centerY.equalTo(authenticationNumberTextField)
            make.right.equalToSuperview().inset(Constant.margin3)
            make.width.equalTo(60)
        }
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(authenticationNumberTextField.snp.bottom).offset(Constant.margin3)
            make.left.right.equalToSuperview().inset(Constant.margin3)
        }
    }
    
    func setupButton() {
        nextButton.addTarget(self, action: #selector(clickNextButton), for: .touchUpInside)
        
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
        
        eyeButton.addTarget(self, action: #selector(eyeClickButton), for: .touchUpInside)
        
        confirmEyeButton.addTarget(self, action: #selector(confirmEyeClickButton), for: .touchUpInside)
        
        linkButton.addTarget(self, action: #selector(clickLinkButton), for: .touchUpInside)
    }
    
    @objc func clickNextButton() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else { return }
        
        if password.count < 6 {
            showAlertDialog(title: "경고", message: "비밀번호는 6자 이상이어야 합니다.")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] _, error in
            if let error = error {
                let nsError = error as NSError
                let errorCode = AuthErrorCode(_nsError: nsError)
                print(errorCode)
                switch errorCode.code {
                case .emailAlreadyInUse:
                    self?.showAlertDialog(title: "경고", message: "이미 사용 중인 이메일입니다.")
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
                    self.showAlertDialog(title: "알림", message: "사용 가능한 아이디입니다.")
                }
            case .failure(let error):
                print(error.localizedDescription)
                self.showAlertDialog(title: "오류", message: "중복 확인 중 오류가 발생했습니다.")
            }
        })
    }
}
