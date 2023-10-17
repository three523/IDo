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
    let mainBarController = TabBarController()
    
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
        loginView.kakaoLoginButton.addTarget(self, action: #selector(kakaoLogin), for: .touchUpInside)
    }
    
    @objc func kakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")

                    //do something
                    _ = oauthToken
                    
                    
                    self.setUserInfo()
                    
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(self.mainBarController, animated: true)
                }
            }
        }
        else {
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoAccount() success.")
                    
                    //do something
                    _ = oauthToken
                    
                    
                    self.setUserInfo()
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(self.mainBarController, animated: true)
                }
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
                self.loginView.userIDLabel.text = String((user?.id)!)
            }
        }
    }
}
