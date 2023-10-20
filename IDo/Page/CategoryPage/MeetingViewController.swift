//
//  MeetingViewController.swift
//  IDo
//
//  Created by t2023-m0053 on 2023/10/11.
//

import FirebaseDatabase
import FirebaseAuth
import Foundation
import SnapKit
import UIKit

class MeetingViewController: UIViewController {
    let meetingImage = UIImage(systemName: "camera.circle")
    private var tableView: UITableView!
    private var emptyStateLabel: UILabel!
    private var noMeetingsView: UIView!
    private var clubList: [Club] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataFromFirebase()
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
    
func loadDataFromFirebase() {
    guard let category = TemporaryManager.shared.categoryData else { return }
    
    let ref = Database.database().reference().child(category).child("meetings")
    
        ref.observe(.value) { [weak self] (snapshot) in
            guard let strongSelf = self else { return }
            
            var newTitles: [String] = []
            var newDates: [String] = []
            var newImageUrls: [String] = []
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let id = dict["id"] as? String,
                   let title = dict["title"] as? String,
                   let description = dict["description"] as? String,
                   let imageUrl = dict["imageUrl"] as? String
                {
                    
                    //MARK: 추가한 부분
                    let club = Club(id: id, title: title, imageURL: imageUrl, description: description)
                    strongSelf.clubList.append(club)
                    
                    newTitles.append(title)
                    newDates.append(description)
                    newImageUrls.append(imageUrl)
                }
            }
            
            TemporaryManager.shared.meetingTitle = newTitles
            TemporaryManager.shared.meetingDate = newDates
            TemporaryManager.shared.meetingImageUrls = newImageUrls
            strongSelf.tableView.reloadData()
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
        let createMeetingVC = MeetingCreateViewController()
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
        return TemporaryManager.shared.meetingTitle.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BasicCell
        cell.titleLabel.text = TemporaryManager.shared.meetingTitle[indexPath.row]
        cell.aboutLabel.text = TemporaryManager.shared.meetingDate[indexPath.row]
        
        let imageUrl = TemporaryManager.shared.meetingImageUrls[indexPath.row]
        
        if let cachedImage = ImageCache.shared.getImage(for: imageUrl) {
            cell.basicImageView.image = cachedImage
        } else {
            URLSession.shared.dataTask(with: URL(string: imageUrl)!) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.basicImageView.image = image
                        ImageCache.shared.cacheImage(image, for: imageUrl)
                    }
                }
            }.resume()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TemporaryManager.shared.meetingIndex = indexPath.row
        TemporaryManager.shared.categoryData = TemporaryManager.shared.categoryData
        let club = clubList[indexPath.row]
        
        guard let currentUser = Auth.auth().currentUser else { return }
        let fbDatabaseUserManager = FirebaseUserDatabaseManager(refPath: ["Users",currentUser.uid])
        
        fbDatabaseUserManager.readData { result in
            switch result {
            case .success(let idoUser):
                var isJoin = false
                if let myClubList = idoUser.myClubList {
                    isJoin = myClubList.contains(where: { $0.id == club.id })
                }
                let noticeBoardVC = NoticeMeetingController(club: club, currentUser: currentUser, isJoin: isJoin)
                self.navigationController?.pushViewController(noticeBoardVC, animated: true)
            case .failure(let error):
                print(error)
            }
        }
    }
}
