////
////  ViewController.swift
////  IDo
////
////  Created by Junyoung_Hong on 2023/10/10.
////
///
import UIKit
import SnapKit

class HomeViewController : UIViewController {
    
    let suggestClub = UILabel()
    let line = UIView()
    let suggestClubList = "종로 맛집 모임"
    var suggestClubInfo = "종로 맛집 공유 목적. 어서오세요"
    var suggestClubMember = "멤버 318"
    var suggestTableView = UITableView()
    
    let joinClub = UILabel()
    let line2 = UIView()
    let joinClubList = ["신림 헬린이 모여라", "동대문구 배드민턴 모임"]
    var joinClubInfo = ["헬스 좋아하시는 분들을 위한 모임", "배드민턴 초보도 가능 :)"]
    var joinClubMember = ["멤버 295","멤버 43"]
    var joinClubTableView = UITableView()
    
    var myClubList = MyProfile.shared.myUserInfo?.myClubList ?? []
    
    func makeSuggestClub() {
        suggestClub.text = "이런 모임은 어떠신가요?"
        suggestClub.textColor = UIColor(color: .textStrong)
        suggestClub.font = .bodyFont(.large, weight: .bold)
    }
    func makeLine() {
        line.backgroundColor = UIColor(color: .textStrong)
    }
    func makeTableView() {
        suggestTableView.register(BasicCell.self, forCellReuseIdentifier: "Cell")
        suggestTableView.dataSource = self
        suggestTableView.delegate = self
        suggestTableView.separatorStyle = .none
        suggestTableView.rowHeight = UITableView.automaticDimension
        suggestTableView.isScrollEnabled = false
    }
    func makeLine2() {
        line2.backgroundColor = UIColor(color: .textStrong)
    }
    func makeJoinClub() {
        joinClub.text = "가입한 모임"
        joinClub.textColor = UIColor(color: .textStrong)
        joinClub.font = .bodyFont(.large, weight: .bold)
    }
    func makeTableView2() {
        joinClubTableView.register(BasicCell.self, forCellReuseIdentifier: "Cell")
        joinClubTableView.dataSource = self
        joinClubTableView.delegate = self
        joinClubTableView.separatorInset.left = 20
        joinClubTableView.separatorInset.right = 20
        joinClubTableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeJoinClub()
        makeSuggestClub()
        makeLine()
        makeLine2()
        makeTableView()
        makeTableView2()
        HomeViewTopControllerSet()
        navigationBar()
        setLayout()
    }
    func setLayout() {
        view.addSubview(joinClub)
        view.addSubview(suggestClub)
        view.addSubview(line)
        view.addSubview(line2)
        view.addSubview(joinClubTableView)
        view.addSubview(suggestTableView)
        
        suggestClub.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Constant.margin3)
            make.leading.equalToSuperview().offset(Constant.margin4)
        }
        line.snp.makeConstraints { make in
            make.top.equalTo(suggestClub.snp.bottom).offset(Constant.margin2)
            make.leading.equalToSuperview().offset(Constant.margin4)
            make.trailing.equalToSuperview().offset(-Constant.margin4)
            make.height.equalTo(1)
        }
        suggestTableView.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(78)
        }
        
        joinClub.snp.makeConstraints { make in
            make.top.equalTo(suggestTableView.snp.bottom).offset(Constant.margin4)
            make.leading.equalToSuperview().offset(Constant.margin4)
        }
        line2.snp.makeConstraints { make in
            make.top.equalTo(joinClub.snp.bottom).offset(Constant.margin2)
            make.leading.equalToSuperview().offset(Constant.margin4)
            make.trailing.equalToSuperview().offset(-Constant.margin4)
            make.height.equalTo(1)
        }
        joinClubTableView.snp.makeConstraints { make in
            make.top.equalTo(line2.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
    }
}


extension HomeViewController : UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 75
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == suggestTableView {
            return 1
        }
        
        return myClubList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BasicCell
        if tableView == suggestTableView {
            // 현재 유저가 선택한 카테고리에 접근 -> 해당 카테고리에 있는 클럽 보여주기
            cell.titleLabel.text = suggestClubList
            cell.aboutLabel.text = suggestClubInfo
            cell.memberLabel.text = suggestClubMember
        } else {
//            cell.titleLabel.text = joinClubList[indexPath.row]
//            cell.aboutLabel.text = joinClubInfo[indexPath.row]
//            cell.memberLabel.text = joinClubMember[indexPath.row]
            cell.titleLabel.text = myClubList[indexPath.row].title
            cell.aboutLabel.text = myClubList[indexPath.row].description
            cell.memberLabel.text = myClubList[indexPath.row].userList?.count as? String
        }
        cell.selectionStyle = .none
        return cell
    }
}

private extension HomeViewController {
    
    func HomeViewTopControllerSet() {
        
        // 네비게이션 LargeTitle 비활성화 및 title 입력
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    func navigationBar() {
        
        // 네비게이션 라벨 생성
        let label = UILabel()
        label.text = "i들아 모여라"
        label.font = UIFont.headFont(.xSmall , weight: .bold)
        label.textColor = UIColor(color: .borderSelected)
        let containerView = UIView(); containerView.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(7) // 또는 적절한 값을 사용
            make.top.bottom.trailing.equalToSuperview()
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: containerView)
    }
}
