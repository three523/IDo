//
//  LoginViewController.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/16.
//

import UIKit
import KakaoSDKAuth
import KakaoSDKUser

class LoginViewController: UIViewController {
    
    private let loginView = LoginView()
    
    override func loadView() {
        view = loginView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        clickLoginButton()
    }

}

private extension LoginViewController {
    
    func clickLoginButton() {
        loginView.kakaoLoginByAppButton.addTarget(self, action: #selector(kakaoLoginByApp), for: .touchUpInside)
        loginView.kakaoLoginByWebButton.addTarget(self, action: #selector(kakaoLoginByWeb), for: .touchUpInside)
    }
    
    @objc func kakaoLoginByApp() {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")

                    //do something
                    _ = oauthToken
                    
                    let accessToken = oauthToken?.accessToken
                    self.setUserInfo()
                }
            }
        }
    }
    
    @objc func kakaoLoginByWeb() {
        UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
            if let error = error {
                print(error)
            }
            else {
                print("loginWithKakaoAccount() success.")
                
                //do something
                _ = oauthToken
                
                let accessToken = oauthToken?.accessToken
                self.setUserInfo()
            }
        }
    }
    
    func setUserInfo() {
        UserApi.shared.me() {(user, error) in
            if let error = error {
                print(error)
            }
            else {
                print("me() success.")
                //do something
                _ = user
                self.loginView.userNameLabel.text = user?.kakaoAccount?.profile?.nickname
            }
        }
    }
}
