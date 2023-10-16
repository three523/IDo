//
//  MyProfileViewController.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/11.
//

import UIKit
import SnapKit

class MyProfileViewController: UIViewController {

    var profileImage = UIImageView()
    var profileName = UILabel()
    var choiceEnjoy = UITextView()
    var selfInfo = UILabel()
//    var choiceEnjoy3 = UITextView()
    
    func makeProfileImage() {
        profileImage.image = UIImage(systemName: "camera.circle.fill")
    }
    func makeProfileName() {
        profileName.text = "애라링"
        profileName.textColor = .black
        profileName.font = UIFont.headFont(.small , weight: .semibold)
    }
    func makeChoiceEnjoy() {
        let firstText = "낚시/캠핑"
        let secondText = "맛집/여행"
        let thirdText = "운동/스포츠"
        let totalText = firstText + "   " + secondText + "   " + thirdText
        choiceEnjoy.text = totalText
        choiceEnjoy.textColor = .systemBlue
        choiceEnjoy.backgroundColor = .lightGray
        choiceEnjoy.font = UIFont.bodyFont(.small, weight:.semibold)
        choiceEnjoy.layer.cornerRadius = 10
    }
    func makeSelfInfo() {
        selfInfo.text = "자기소개"
        selfInfo.textColor = .black
        selfInfo.font = UIFont.bodyFont(.large, weight: .semibold)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        makeProfileImage()
        makeProfileName()
        makeChoiceEnjoy()
        makeSelfInfo()
        setLayout()
    }
    func setLayout() {
        view.addSubview(profileImage)
        view.addSubview(profileName)
        view.addSubview(choiceEnjoy)
        view.addSubview(selfInfo)
        
        profileImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(120)
            make.left.equalToSuperview().offset(150)
            make.width.height.equalTo(100)
        }
        profileName.snp.makeConstraints { make in
            make.top.equalTo(profileImage.snp.bottom).offset(0)
            make.left.equalToSuperview().offset(170)
            make.width.height.equalTo(70)
        }
        choiceEnjoy.snp.makeConstraints { make in
            make.top.equalTo(profileName.snp.bottom).offset(0)
            make.leading.trailing.equalToSuperview().inset(90)
            make.width.height.equalTo(35)
        }
        selfInfo.snp.makeConstraints { make in
            make.top.equalTo(choiceEnjoy.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(30)
        }
    }
}
