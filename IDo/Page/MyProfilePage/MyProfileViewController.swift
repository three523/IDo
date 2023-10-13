//
//  MyProfileViewController.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/11.
//

import UIKit
import SnapKit

class MyProfileViewController: UIViewController {
//    
//    var profileImage = UIImage
//    var profileName = UITextField
//    var choiceEnjoy = UITextView
//    var choiceEnjoy2 = UITableView
//    var choiceEnjoy3 = UITextView
//    
//    func profileImage() {
//        
//    }
//    
    
    var profileImage = UIImageView()
//    var profileName = UITextField()
//    var choiceEnjoy = UITextView()
//    var choiceEnjoy2 = UITableView()
//    var choiceEnjoy3 = UITextView()
    
    func makeProfileImage() {
        profileImage.image = UIImage(systemName: "camera.circle.fill")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeProfileImage()
        setLayout()
    }
    func setLayout() {
        view.addSubview(profileImage)
        
        profileImage.snp.makeConstraints { make in
            make.center.equalToSuperview()

        }
    }
}
