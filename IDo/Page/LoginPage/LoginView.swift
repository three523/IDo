//
//  LoginView.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/16.
//

import SnapKit
import UIKit

class LoginView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        configureUI()
        addSubView()
        autoLayout()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 카카오 로그인 버튼
    private(set) lazy var kakaoLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "kakao_login_large_wide"), for: .normal)
        return button
    }()

    private(set) var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이메일을 입력해주세요"
        textField.font = .bodyFont(.medium, weight: .regular)
        textField.textColor = UIColor(color: .textStrong)
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        return textField
    }()

    private(set) var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호를 입력해주세요"
        textField.font = .bodyFont(.medium, weight: .regular)
        textField.textColor = UIColor(color: .textStrong)
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        return textField
    }()

    private(set) var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("로그인", for: .normal)
        button.setTitleColor(UIColor(color: .white), for: .normal)
        button.backgroundColor = UIColor(color: .contentPrimary)
        button.layer.cornerRadius = 5
        return button
    }()

    private(set) var signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("회원가입", for: .normal)
        button.setTitleColor(UIColor(color: .white), for: .normal)
        button.backgroundColor = UIColor(color: .contentPrimary)
        button.layer.cornerRadius = 5
        return button
    }()
}

private extension LoginView {
    // NoticeBoardView의 기본 UI 설정
    func configureUI() {
        backgroundColor = UIColor.white
    }

    // noticeBoardTableView를 SubView에 추가
    func addSubView() {
//        addSubview(kakaoLoginButton)
        addSubview(emailTextField)
        addSubview(passwordTextField)
        addSubview(loginButton)
        addSubview(signUpButton)
    }

    // 오토레이아웃 설정
    func autoLayout() {
//        kakaoLoginButton.snp.makeConstraints { make in
//            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(Constant.margin3)
//            make.centerX.equalToSuperview()
//            make.width.equalTo(300)
//            make.height.equalTo(45)
//        }
        emailTextField.snp.makeConstraints { make in
            make.bottom.equalTo(snp.centerY).inset(60)
            make.left.right.equalToSuperview().inset(Constant.margin3)
        }
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(Constant.margin2)
            make.left.right.equalToSuperview().inset(Constant.margin3)
        }
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(Constant.margin3)
            make.left.right.equalToSuperview().inset(Constant.margin3)
        }
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(Constant.margin2)
            make.left.right.equalToSuperview().inset(Constant.margin3)
        }
    }
}
