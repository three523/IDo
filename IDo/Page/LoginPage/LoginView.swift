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
        addStackView()
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

    private(set) lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "logo")
        return imageView
    }()
    
    private(set) var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이메일을 입력해주세요"
        textField.font = .bodyFont(.large, weight: .regular)
        textField.textColor = UIColor(color: .textStrong)
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        return textField
    }()

    private(set) var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호를 입력해주세요"
        textField.font = .bodyFont(.large, weight: .regular)
        textField.textColor = UIColor(color: .textStrong)
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        return textField
    }()

    private(set) var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("로그인", for: .normal)
        button.setTitleColor(UIColor(color: .white), for: .normal)
        button.titleLabel?.font = UIFont.bodyFont(.large, weight: .medium)
        button.backgroundColor = UIColor(color: .contentPrimary)
        button.layer.cornerRadius = 5
        return button
    }()
    
    private(set) lazy var signUpStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 4
        return stackView
    }()
    
    private(set) lazy var signUpLeftLabel: UILabel = {
        let label = UILabel()
        label.text = "처음 오셨나요?"
        label.textColor = UIColor(color: .placeholder)
        label.font = UIFont.bodyFont(.medium, weight: .medium)
        return label
    }()
    
    private(set) lazy var signUpRightLabel: UILabel = {
        let label = UILabel()
        label.text = "이메일로 가입하기"
        label.textColor = UIColor(color: .main)
        label.font = UIFont.bodyFont(.medium, weight: .medium)
        return label
    }()

    private(set) var signUpButton: UIButton = {
        let button = UIButton()
//        button.setTitle("회원가입", for: .normal)
//        button.setTitleColor(UIColor(color: .white), for: .normal)
//        button.backgroundColor = UIColor(color: .contentPrimary)
//        button.layer.cornerRadius = 5
        button.setImage(UIImage(systemName: "arrow.forward.circle"), for: .normal)
        button.tintColor = UIColor(color: .main)
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
        addSubview(logoImageView)
        addSubview(emailTextField)
        addSubview(passwordTextField)
        addSubview(loginButton)
        addSubview(signUpStackView)
    }
    
    func addStackView() {
        signUpStackView.addArrangedSubview(signUpLeftLabel)
        signUpStackView.addArrangedSubview(signUpRightLabel)
        signUpStackView.addArrangedSubview(signUpButton)
    }

    // 오토레이아웃 설정
    func autoLayout() {
//        kakaoLoginButton.snp.makeConstraints { make in
//            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(Constant.margin3)
//            make.centerX.equalToSuperview()
//            make.width.equalTo(300)
//            make.height.equalTo(45)
//        }
        
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(100)
            make.width.height.equalTo(100)
            make.centerX.equalToSuperview()
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(100)
            make.left.right.equalToSuperview().inset(Constant.margin4)
            make.height.equalTo(48)
        }
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(Constant.margin3)
            make.left.right.equalToSuperview().inset(Constant.margin4)
            make.height.equalTo(48)
        }
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(60)
            make.left.right.equalToSuperview().inset(Constant.margin4)
            make.height.equalTo(48)
        }
        
        signUpStackView.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(Constant.margin4)
            make.left.right.equalToSuperview().inset(Constant.margin4)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.width.height.equalTo(17)
        }
        
//        signUpLeftLabel.snp.makeConstraints { make in
//            make.top.equalTo(loginButton.snp.bottom).offset(Constant.margin3)
//            make.left.equalTo(snp.left).offset(Constant.margin4)
//        }
//        
//        signUpRightLabel.snp.makeConstraints { make in
//            make.top.equalTo(loginButton.snp.bottom).offset(Constant.margin3)
//            make.left.equalTo(signUpLeftLabel.snp.right).offset(32)
//        }
//        
//        signUpButton.snp.makeConstraints { make in
//            make.top.equalTo(loginButton.snp.bottom).offset(Constant.margin3)
//            make.left.equalTo(signUpRightLabel.snp.right).offset(32)
//            make.right.equalTo(snp.right).offset(Constant.margin4)
//        }
    }
}
