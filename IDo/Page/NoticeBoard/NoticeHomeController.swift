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

final class IntrinsicTableView: UITableView {

    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }


    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }

}

final class NoticeHomeController: UIViewController {
    private var club: Club
    var signUpButtonUpdate: ((AuthState) -> Void)?
    private let firebaseClubDatabaseManager: FirebaseClubDatabaseManager
    private let clubImage: UIImage
    private let memberTableView: IntrinsicTableView = {
        let tableview = IntrinsicTableView()
        tableview.rowHeight = 36 + 8 + 8
        tableview.isScrollEnabled = false
        tableview.separatorStyle = .none
        return tableview
    }()
    
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
        return scrollView
    }()
    
    private let scrollStackViewContainer: UIStackView = {
        let view = UIStackView()
        view.alignment = .fill
        view.axis = .vertical
        view.distribution = .fill
        view.spacing = 25
        return view
    }()
    
    init(club: Club, isJoin: Bool, firebaseClubDataManager: FirebaseClubDatabaseManager, clubImage: UIImage) {
        self.clubImage = clubImage
        self.club = club
        self.firebaseClubDatabaseManager = firebaseClubDataManager
        super.init(nibName: nil, bundle: nil)
        signUpButton.isHidden = isJoin
        self.firebaseClubDatabaseManager.update = { [weak self] in
            guard let userInfo = MyProfile.shared.myUserInfo,
                  let joinUserList = self?.firebaseClubDatabaseManager.model?.userList else { return }
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
        firebaseClubDatabaseManager.readData { _ in
            DispatchQueue.main.async {
                self.memberTableView.reloadData()
            }
        }
    }
    
    @objc func handleSignUp() {
        print("Sign Up button tapped!.")
        addUser()
        addMyClubList()
    }
    
    private func addUser() {
        guard let idoUser = MyProfile.shared.myUserInfo?.toIDoUser else { return }
        firebaseClubDatabaseManager.appendUser(user: idoUser.toUserSummary) { isCompleted in
            if isCompleted { self.signUpButton.isHidden = isCompleted }
            let authState: AuthState = isCompleted ? .member : .notMember
            self.signUpButtonUpdate?(authState)
        }
    }
    
    private func addMyClubList() {
        var myClubList = MyProfile.shared.myUserInfo?.myClubList ?? []
        myClubList.append(club)
        MyProfile.shared.update(myClubList: myClubList)
    }

    func setup() {
        addViews()
        setupAutoLayout()
        setupTableView()
    }
    
    private func addViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(scrollView)
        scrollView.addSubview(scrollStackViewContainer)
        scrollStackViewContainer.addArrangedSubview(imageView)
        scrollStackViewContainer.addArrangedSubview(label)
        scrollStackViewContainer.addArrangedSubview(textLabel)
        scrollStackViewContainer.addArrangedSubview(memberTableView)
        view.addSubview(signUpButton)
    }
    
    private func setupAutoLayout() {
        let safeArea = view.safeAreaLayoutGuide
        imageView.snp.makeConstraints { make in
            make.height.equalTo(150)
        }
        
        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(safeArea.snp.top).inset(Constant.margin3)
            make.bottom.equalTo(signUpButton.snp.top).offset(-10)
        }
        
        scrollStackViewContainer.snp.makeConstraints { make in
            make.left.right.equalTo(scrollView.contentLayoutGuide).inset(Constant.margin4)
            make.top.equalTo(scrollView.contentLayoutGuide.snp.top).offset(30)
            make.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width).inset(Constant.margin4)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.left.right.equalToSuperview().inset(Constant.margin4)
            make.bottom.equalTo(safeArea.snp.bottom).inset(20)
        }
    }
    
    private func setupTableView() {
        memberTableView.delegate = self
        memberTableView.dataSource = self
        memberTableView.register(MemberTableViewCell.self, forCellReuseIdentifier: MemberTableViewCell.identifier)
    }

    func loadDataFromFirebase() {
        label.text = club.title
        textLabel.text = club.description
        imageView.image = clubImage
    }

    func update(club: Club, imageData: Data) {
        DispatchQueue.main.async {
            self.label.text = club.title
            self.textLabel.text = club.description
            self.imageView.image = UIImage(data: imageData)
        }
    }
}

extension NoticeHomeController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return club.userList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "맴버 목록"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemberTableViewCell.identifier, for: indexPath) as? MemberTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        if let userList = club.userList {
            let user = userList[indexPath.row]
            cell.nameLabel.text = user.nickName
            cell.descriptionLabel.text = user.description
            guard let profilePath = user.profileImagePath else { return cell }
            FBURLCache.shared.downloadURL(storagePath: profilePath + "/\(ImageSize.small.rawValue)") { result in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        cell.profileImageView.image = image
                    }
                    cell.profileImageView.backgroundColor = UIColor(color: .white)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let removeAction = UIContextualAction(style: .normal, title: "삭제") { _, _, _ in
            
        }
        removeAction.backgroundColor = UIColor(color: .negative)
        let config = UISwipeActionsConfiguration(actions: [removeAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
}
