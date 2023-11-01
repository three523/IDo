//
//  MeetingViewController.swift
//  IDo
//
//  Created by t2023-m0053 on 2023/10/11.
//

import FirebaseAuth
import FirebaseDatabase
import Foundation
import SnapKit
import UIKit

class MeetingViewController: UIViewController {
    let meetingImage = UIImage(systemName: "camera.circle")
    private var emptyMessageView: EmptyMessageStackView = .init(messageType: .clubEmpty)
    private var tableView: UITableView!
    private var emptyStateLabel: UILabel!
    private var noMeetingsView: UIView!
    private var clubList: [Club] = []
    private var meetingsData: MeetingsData
    init(meetingsData: MeetingsData) {
        self.meetingsData = meetingsData
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        loadDataFromFirebase()
        meetingsData.update = { [weak self] in
            self?.tableView.reloadData()
            self?.updateNoMeetingsViewVisibility()
        }
        meetingsData.readClub { _ in
            self.setupEmptyMessageView()
            self.updateNoMeetingsViewVisibility()
        }
        navigationController?.navigationBar.tintColor = UIColor.black
        setupNavigationBar()
        setupTableView()
        navigationItem()
        setupNoMeetingsView()
        if let data = TemporaryManager.shared.categoryData, // 카테고리 Index에 따른 제목 표시
           let index = TemporaryManager.shared.categoryIndex,
           index < TemporaryManager.shared.meetingTitle.count && index < TemporaryManager.shared.meetingDate.count
        {
            navigationItem.titleView?.subviews.forEach { $0.removeFromSuperview() }
            navigationItem.titleView?.addSubview(createTitleLabel(with: data))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        meetingsData.readClub { _ in
            self.updateNoMeetingsViewVisibility()
        }
    }

    private func createTitleLabel(with data: String) -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = "\(data)"
        titleLabel.textAlignment = .center
        
        return titleLabel
    }
    
    private func setupNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.text = TemporaryManager.shared.categoryData ?? ""
        titleLabel.textAlignment = .center
        
        navigationItem.titleView = titleLabel
    }

    private func setupEmptyMessageView() {
        view.addSubview(emptyMessageView)
        emptyMessageView.isHidden = true
        emptyMessageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(Constant.margin3)
        }
    }

    private func updateNoMeetingsViewVisibility() {
        if meetingsData.clubs.isEmpty {
            noMeetingsView.isHidden = true // 기존 noMeetingsView를 숨깁니다.
            emptyMessageView.isHidden = false // EmptyMessageStackView를 보입니다.
        } else {
            emptyMessageView.isHidden = true // 회의가 있으면 EmptyMessageStackView를 숨깁니다.
        }
    }

    func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BasicCell.self, forCellReuseIdentifier: "Cell")
        
        view.addSubview(tableView)
    }
    
    func navigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .done, target: self, action: #selector(setBtnTap))
        
        //        button.addTarget(self, action: #selector(profileImageTapped), for: .touchUpInside)
        //        let noticeBoardVC = MeetingCreateViewController()
        //        navigationController?.pushViewController(noticeBoardVC, animated: true)
    }
    
    @objc
    func setBtnTap() {
        let createMeetingVC = MeetingCreateViewController(meetingsData: meetingsData)
        TemporaryManager.shared.selectedCategory = TemporaryManager.shared.categoryData
        navigationController?.pushViewController(createMeetingVC, animated: true)
    }
    
    private func setupNoMeetingsView() {
        noMeetingsView = UIView()
        noMeetingsView.backgroundColor = .white
        view.addSubview(noMeetingsView)
        
        noMeetingsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: "person.3.fill")
        iconImageView.tintColor = .gray
        noMeetingsView.addSubview(iconImageView)
        
        iconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-60)
            make.width.height.equalTo(100)
        }
        let messageLabel = UILabel()
        messageLabel.text = """
        모임하는 카테고리의 모임이 없습니다
        참여가 있는 모임에 참여하시거나
        새로운 카테고리를 만들어보세요.
        """
        messageLabel.numberOfLines = 3
        messageLabel.textAlignment = .center
        messageLabel.textColor = .gray
        noMeetingsView.addSubview(messageLabel)
        
        messageLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(iconImageView.snp.bottom).offset(20)
        }
        
        noMeetingsView.isHidden = true
    }
}

extension MeetingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meetingsData.clubs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BasicCell
        let club = meetingsData.clubs[indexPath.row]
        cell.titleLabel.text = club.title
        cell.aboutLabel.text = club.description
        cell.basicImageView.image = UIImage(named: "MeetingProfileImage")
        
        if let imageURL = club.imageURL {
            meetingsData.loadImage(storagePath: imageURL, clubId: club.id) { result in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        cell.basicImageView.image = image
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TemporaryManager.shared.meetingIndex = indexPath.row
        TemporaryManager.shared.categoryData = TemporaryManager.shared.categoryData
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BasicCell
        let club = meetingsData.clubs[indexPath.row]
        var clubImage = meetingsData.clubImages[club.id] ?? UIImage(named: "MeetingProfileImage")!
        print(meetingsData.clubImages)
        
        guard let currentUser = Auth.auth().currentUser else { return }
        let isJoin = club.userList?.contains(where: { $0.id == currentUser.uid }) ?? false
        let noticeBoardVC = NoticeMeetingController(club: club, currentUser: currentUser, isJoin: isJoin, clubImage: clubImage)
        self.navigationController?.pushViewController(noticeBoardVC, animated: true)
    }
}
