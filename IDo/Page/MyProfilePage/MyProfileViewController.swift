//
//  MyProfileViewController.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/11.
//

import UIKit
import SnapKit

class MyProfileViewController: UIViewController {
    //프로필
    var profileImage = UIButton()
    var profileName = UITextView()
    var choiceEnjoy = UITextView()
    
    //자기소개
    let selfInfo = UILabel()
    var selfInfoDetail = UITextView()
    
    //내가쓴글
    let writeMe = UILabel()
    var writeMeList = ["헬린이 멤버 구합니다","카본 낚시대 20만원선에서 추천 받아요"]
    var writeMeDate = ["yyyy-mm-dd","yyyy-mm-dd"]
    var writeMeTableView = UITableView()
    
    var isEdit = false
    
    func makeProfileImage() {
        profileImage.setImage(UIImage(named: "MeetingProfileImage"), for: .normal )
        profileImage.imageView?.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = 50
        profileImage.clipsToBounds = true
    }
    func makeProfileName() {
        profileName.text = "애라링"
        profileName.textAlignment = .center
        profileName.textColor = .black
        profileName.font = UIFont.headFont(.xSmall , weight: .semibold)
        profileName.isUserInteractionEnabled = false
    }
    func makeChoiceEnjoy() {
        let makeChoiceEnjoy = choiceEnjoy
        let firstText = "낚시/캠핑"
        let secondText = "맛집/여행"
        let thirdText = "운동/스포츠"
        let totalText = firstText + ",  " + secondText + ",  " + thirdText
        choiceEnjoy.text = totalText
        choiceEnjoy.textColor = UIColor(color: .borderSelected)
        choiceEnjoy.backgroundColor = UIColor(color: .contentBackground)
        choiceEnjoy.font = UIFont.bodyFont(.small, weight:.semibold)
        choiceEnjoy.layer.cornerRadius = 10 // 원하는 값으로 설정
        choiceEnjoy.layer.borderWidth = 5 // 원하는 두께로 설정
        choiceEnjoy.layer.borderColor = UIColor(color: .contentBackground).cgColor //원하는 테두리 색상으로 설정
        choiceEnjoy.clipsToBounds = true
        choiceEnjoy.textAlignment = .center
        choiceEnjoy.isUserInteractionEnabled = false
    }
    func makeSelfInfo() {
        selfInfo.text = "자기소개"
        selfInfo.textColor = .black
        selfInfo.font = UIFont.bodyFont(.large, weight: .semibold)
    }
    func makeSelfInfoDetail() {
        selfInfoDetail.font = UIFont.bodyFont(.medium, weight: .regular)
        selfInfoDetail.text = "안녕하세요. 이애라입니다."
        selfInfoDetail.textColor = UIColor(named: "ui-text-strong")
        selfInfoDetail.backgroundColor = UIColor(color: .backgroundSecondary)
        selfInfoDetail.layer.cornerRadius = 10
        selfInfoDetail.textContainerInset = UIEdgeInsets(top: 9, left: 8, bottom: 0, right: 9)
        selfInfoDetail.isUserInteractionEnabled = false
    }
    func makeWriteMe() {
        writeMe.text = "작성한 글"
        writeMe.textColor = .black
        writeMe.font = UIFont.bodyFont(.large, weight: .semibold)
    }
    func makeWriteMeTableView() {
        writeMeTableView.register(WriteMeTableViewCell.self, forCellReuseIdentifier: "Cell")
        writeMeTableView.dataSource = self
        writeMeTableView.delegate = self
    }
    //로딩되는 뷰
    override func viewDidLoad() {
        super.viewDidLoad()
        makeProfileImage()
        makeProfileName()
        makeChoiceEnjoy()
        makeSelfInfo()
        makeSelfInfoDetail()
        makeWriteMe()
        makeWriteMeTableView()
        setLayout()
        profileEditControllerSet()
        navigationBarButtonAction()
        buttonAction()
        navigationController?.delegate = self
        profileName.delegate = self
        choiceEnjoy.delegate = self
        selfInfoDetail.delegate = self
        isEdit = false
    }
    //로드가 된 뒤에 보여지는 뷰
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profileName.resignFirstResponder()
        choiceEnjoy.resignFirstResponder()
        selfInfoDetail.resignFirstResponder()
    }
    
    func setLayout() {
        view.addSubview(profileImage)
        view.addSubview(profileName)
        view.addSubview(choiceEnjoy)
        view.addSubview(selfInfo)
        view.addSubview(selfInfoDetail)
        view.addSubview(writeMe)
        view.addSubview(writeMeTableView)
        
        profileImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(90)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        profileName.snp.makeConstraints { make in
            make.top.equalTo(profileImage.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(70)
            make.height.equalTo(40)
        }
        choiceEnjoy.snp.makeConstraints { make in
            make.top.equalTo(profileName.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(80)
            make.width.equalTo(60)
            make.height.equalTo(35)
        }
        selfInfo.snp.makeConstraints { make in
            make.top.equalTo(choiceEnjoy.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(30)
        }
        selfInfoDetail.snp.makeConstraints { make in
            make.top.equalTo(selfInfo.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(30)
            make.width.equalTo(330)
            make.height.equalTo(130)
        }
        writeMe.snp.makeConstraints { make in
            make.top.equalTo(selfInfoDetail.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(30)
        }
        writeMeTableView.snp.makeConstraints { make in
            make.top.equalTo(writeMe.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension MyProfileViewController : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let chagedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        if textView == selfInfoDetail {
            return chagedText.count <= 299
        }
        return true
    }
}

extension MyProfileViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return writeMeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as!
        WriteMeTableViewCell
        if tableView == writeMeTableView {
            cell.write.text = writeMeList[indexPath.row]
            cell.write2.text = writeMeDate[indexPath.row]
        }
        cell.writeImageView.image = UIImage(systemName: "photo")
        return cell
    }
}

private extension MyProfileViewController {
    
    func profileEditControllerSet() {
        
        // 네비게이션 LargeTitle 비활성화 및 title 입력
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func navigationBarButtonAction() {
        
        // 네비게이션 오른쪽 버튼 생성
        let editButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(editVC))
        navigationItem.rightBarButtonItem = editButton
        navigationItem.rightBarButtonItem?.tintColor = UIColor(color: .main)
        
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        backBarButtonItem.tintColor = UIColor(color: .main)
        self.navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    @objc func editVC() {
        
        //기본 isEdit은 false. toggle(전등스위치개념) 사용하여 true(수정중인 상태)로 바꿔줌
        isEdit.toggle()
        
        // isEdit = true인 상태의 실행 코드
        if isEdit {
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: "checkmark.circle")
            
            //각각 텍스트뷰를 활성화 시킴
            profileName.isUserInteractionEnabled = true
            choiceEnjoy.isUserInteractionEnabled = true
            selfInfoDetail.isUserInteractionEnabled = true
            
            //isEdit = false인 상태의 실행 코드
        } else {
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: "square.and.pencil")
            profileName.isUserInteractionEnabled = false
            choiceEnjoy.isUserInteractionEnabled = false
            selfInfoDetail.isUserInteractionEnabled = false
        }
    }
}

extension MyProfileViewController: UINavigationControllerDelegate {
}
private extension MyProfileViewController {
    
    func buttonAction() {
        profileImage.addTarget(self, action: #selector(addPicture), for: .touchUpInside)
    }
    
    @objc func addPicture() {
        let imagePicker1 = UIImagePickerController()
        imagePicker1.delegate = self
        imagePicker1.sourceType = .photoLibrary
        present(imagePicker1, animated: true, completion: nil)
    }
}

extension MyProfileViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            profileImage.setImage(image, for: .normal)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}






