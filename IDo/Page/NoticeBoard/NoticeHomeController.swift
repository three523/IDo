//
//  NoticeHomeController.swift
//  IDo
//
//  Created by t2023-m0053 on 2023/10/12.
//

import FirebaseAuth
import FirebaseDatabase
import SnapKit
import UIKit

class NoticeHomeController: UIViewController {
    var meetingId: String?
    var categoryData: String?
    var meetingIndex: Int?
    var club: Club
    var signUpButtonUpdate: ((Bool) -> Void)?
    let fbUserDatabaseManager: FirebaseUserDatabaseManager
    let clubImage: UIImage
    
    lazy var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "MeetingProfileImage")
        return imageView
    }()
    
    lazy var label: UILabel = {
        var label = UILabel()
        label.font = .headFont(.xSmall, weight: .bold)
        label.text = "[B.R.P] 보라매 런앤플레이"
        return label
    }()
    
    lazy var textLabel: UILabel = {
        var textLabel = UILabel()
        textLabel.font = .bodyFont(.medium, weight: .regular)
        textLabel.numberOfLines = 0
        textLabel.text = "안녕하세요. 설명입니다. "
        textLabel.text = "안녕하세요. 설명입니다. 설명입니다. 설명입니다. 설명입니다. 설명입니다. 설명입니다. 설명입니다. 설명입니다. 설명입니다.설명입니다. "
        return textLabel
    }()

    lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.scrollsToTop = true
        return scrollView
    }()
    
    private let scrollStackViewContainer: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.axis = .vertical
        view.distribution = .fill
        view.spacing = 25
        return view
    }()
    
    init(club: Club, isJoin: Bool, fbUserDatabaseManager: FirebaseUserDatabaseManager, clubImage: UIImage) {
        self.clubImage = clubImage
        self.club = club
        self.fbUserDatabaseManager = fbUserDatabaseManager
        super.init(nibName: nil, bundle: nil)
        signUpButton.isHidden = isJoin
        guard let myInfo = MyProfile.shared.myUserInfo else { return }
        self.fbUserDatabaseManager.update = { [weak self] in
            guard let userInfo = MyProfile.shared.myUserInfo,
                  let joinUserList = self?.fbUserDatabaseManager.model?.userList else { return }
            self?.signUpButton.isHidden = joinUserList.contains(where: { $0.id == userInfo.id })
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadDataFromFirebase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fbUserDatabaseManager.readData()
    }
    
    @objc func handleSignUp() {
        print("Sign Up button tapped!")
        
        if fbUserDatabaseManager.model == nil { return }
        fbUserDatabaseManager.updateAddClub(club: club) {
            self.signUpButtonUpdate?()
            self.signUpButton.isHidden = true
        }
    }

    func setup() {
        view.addSubview(scrollView)
        scrollView.addSubview(scrollStackViewContainer)
        
        view.addSubview(signUpButton)
        
        scrollStackViewContainer.snp.makeConstraints { make in
            make.leading.equalTo(scrollView.contentLayoutGuide.snp.leading)
            make.trailing.equalTo(scrollView.contentLayoutGuide.snp.trailing)
            make.top.equalTo(scrollView.contentLayoutGuide.snp.top).offset(50)
            make.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
        }
        
        scrollView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(view.layoutMarginsGuide.snp.top)
            make.bottom.equalTo(signUpButton.snp.top).offset(-10)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
        }
        
        configureContainerView()
    }
    
    private func configureContainerView() {
        scrollStackViewContainer.addArrangedSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(150)
        }
        scrollStackViewContainer.addArrangedSubview(label)
        scrollStackViewContainer.addArrangedSubview(textLabel)
        
        signUpButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }

    func loadDataFromFirebase() {
        label.text = club.title
        textLabel.text = club.description
        imageView.image = clubImage
//        scrollStackViewContainer.addArrangedSubview(label)
//        scrollStackViewContainer.addArrangedSubview(textLabel)
    }

    func update(club: Club, imageData: Data) {
        DispatchQueue.main.async {
            self.label.text = club.title
            self.textLabel.text = club.description
            self.imageView.image = UIImage(data: imageData)
        }
    }
}
