//
//  LoginView.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/16.
//

import UIKit
import SnapKit

class LoginView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        addSubView()
        autoLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 카카오톡 로그인 버튼
    private(set) lazy var kakaoLoginByAppButton: UIButton = {
        let button = UIButton()
        button.setTitle("카카오톡으로 로그인", for: .normal)
        button.titleLabel?.textColor = UIColor.white
        button.backgroundColor = UIColor.systemBlue
        return button
    }()
    
    // 카카오 계정 로그인 버튼
    private(set) lazy var kakaoLoginByWebButton: UIButton = {
        let button = UIButton()
        button.setTitle("카카오계정으로 로그인", for: .normal)
        button.titleLabel?.textColor = UIColor.white
        button.backgroundColor = UIColor.systemBlue
        return button
    }()
    
    private(set) lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "userName"
        label.textColor = UIColor.black
        label.font = UIFont.bodyFont(.medium, weight: .bold)
        return label
    }()
}

private extension LoginView {
    
    // NoticeBoardView의 기본 UI 설정
    func configureUI() {
        backgroundColor = UIColor.white
    }
    
    // noticeBoardTableView를 SubView에 추가
    func addSubView() {
        addSubview(kakaoLoginByAppButton)
        addSubview(kakaoLoginByWebButton)
        addSubview(userNameLabel)
    }
    
    // 오토레이아웃 설정
    func autoLayout() {
        kakaoLoginByAppButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalTo(snp.leading).offset(Constant.margin3)
            make.trailing.equalTo(snp.trailing).offset(-Constant.margin3)
        }
        
        kakaoLoginByWebButton.snp.makeConstraints { make in
            make.top.equalTo(kakaoLoginByAppButton.snp.bottom).offset(Constant.margin3)
            make.leading.equalTo(snp.leading).offset(Constant.margin3)
            make.trailing.equalTo(snp.trailing).offset(-Constant.margin3)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(kakaoLoginByWebButton.snp.bottom).offset(Constant.margin3)
            make.leading.equalTo(snp.leading).offset(Constant.margin3)
            make.trailing.equalTo(snp.trailing).offset(-Constant.margin3)
        }
    }
}
