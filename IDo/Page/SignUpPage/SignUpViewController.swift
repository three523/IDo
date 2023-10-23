//
//  SignUpViewController.swift
//  IDo
//
//  Created by 김도현 on 2023/10/20.
//

import FirebaseAuth
import UIKit

final class SignUpViewController: UIViewController {
    private let backButton: UIButton = {
        let button = UIButton()
        button.setTitle("back", for: .normal)
        button.setTitleColor(UIColor(color: .contentPrimary), for: .normal)
        return button
    }()

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이메일을 입력해주세요"
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
        return textField
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
        view.addSubview(passwordTextField)
        view.addSubview(nextButton)
        view.addSubview(backButton)
    }

    func autolayoutSetup() {
        let safeArea = view.safeAreaLayoutGuide
        backButton.snp.makeConstraints { make in
            make.top.left.equalTo(safeArea).inset(Constant.margin3)
        }
        emailTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview().inset(Constant.margin3)
        }
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(Constant.margin2)
            make.left.right.equalToSuperview().inset(Constant.margin3)
        }
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(Constant.margin3)
            make.left.right.equalToSuperview().inset(Constant.margin3)
        }
    }

    func setupButton() {
        nextButton.addTarget(self, action: #selector(clickNextButton), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
    }

    @objc func clickNextButton() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else { return }

        if !isValidEmail(email) {
            showAlertDialog(title: "경고", message: "올바른 이메일 형식을 입력해주세요.")
            return
        }

        if password.count < 6 {
            showAlertDialog(title: "경고", message: "비밀번호는 6자 이상이어야 합니다.")
            return
        }

        let categoryVC = CategorySelectViewController(email: email, password: password)
        navigationController?.pushViewController(categoryVC, animated: true)
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

    @objc func clickBackButton() {
        dismiss(animated: true)
    }
}
