//
//  SignUpViewController.swift
//  IDo
//
//  Created by 김도현 on 2023/10/20.
//

import UIKit

final class SignUpViewController: UIViewController {
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
    private let loginInfo = LoginInfo()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }

}

private extension SignUpViewController {
    func setup() {
        addViews()
        autolayoutSetup()
        setupButton()
    }
    func addViews() {
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(nextButton)
    }
    func autolayoutSetup() {
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
        nextButton.addTarget(self, action: #selector(nextButtonClick), for: .touchUpInside)
    }
    @objc func nextButtonClick() {
        guard let email = emailTextField.text,
        let password = passwordTextField.text else { return }
        loginInfo.email = email
        loginInfo.password = password
        let categoryVC = CategorySelectViewController(loginInfo: loginInfo)
        navigationController?.pushViewController(categoryVC, animated: true)
        
    }
}
