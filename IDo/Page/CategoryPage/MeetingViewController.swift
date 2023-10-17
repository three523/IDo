//
//  MeetingViewController.swift
//  IDo
//
//  Created by t2023-m0053 on 2023/10/11.
//

import Foundation
import UIKit
import FirebaseDatabase

class MeetingViewController: UIViewController {
//    let meetingTitle = ["테니스모임", "개발자 스터디", "게임"]
//    let meetingDate = ["테니스 모임에 대해 소개합니다.", "개발 공부를 하는 모임입니다.", "게임하는 사람들을 모으고 있습니다."]
    let meetingImage = UIImage(systemName: "camera.circle")
    
    var meetingTitle: [String] = []
    var meetingDate: [String] = []
    var categoryData: String?
    var categoryIndex: Int?
    private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataFromFirebase()
        setupNavigationBar()
        setupTableView()
        navigationItem()
        if let data = categoryData, // 카테고리 Index에 따른 제목 표시
           let index = categoryIndex,
           index < meetingTitle.count && index < meetingDate.count
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
        titleLabel.text = categoryData ?? ""
        titleLabel.textAlignment = .center

        navigationItem.titleView = titleLabel
    }
    
    func loadDataFromFirebase() {
        guard let category = categoryData else { return }
            
        let ref = Database.database().reference().child(category).child("meetings")
        
        ref.observe(.value) { [weak self] (snapshot) in
            
            var newTitles: [String] = []
            var newDates: [String] = []
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let title = dict["title"] as? String,
                   let description = dict["description"] as? String {
                    newTitles.append(title)
                    newDates.append(description)
                }
            }
            
            self?.meetingTitle = newTitles
            self?.meetingDate = newDates
            self?.tableView.reloadData()
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
        createMeetingVC.selectedCategory = self.categoryData
        navigationController?.pushViewController(createMeetingVC, animated: true)
        
        
    }

}

extension MeetingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meetingTitle.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BasicCell
        cell.titleLabel.text = meetingTitle[indexPath.row]
        cell.aboutLabel.text = meetingDate[indexPath.row]
        cell.basicImageView.image = meetingImage

        return cell
    }



    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let noticeBoardVC = NoticeMeetingController()
        noticeBoardVC.meetingIndex = indexPath.row
        noticeBoardVC.categoryData = self.categoryData
        navigationController?.pushViewController(noticeBoardVC, animated: true)
    }


}
