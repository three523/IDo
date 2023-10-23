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
    let joinClub = UILabel()
    let line = UIView()
    let joinClubList = ["신림 헬린이 모여라", "동대문구 배드민턴 모임"]
    var joinClubInfo = ["헬스 좋아하시는 분들을 위한 모임", "배드민턴 초보도 가능 :)"]
    var joinClubMember = ["멤버 295","멤버 43"]
    var joinClubTableView = UITableView()
    
    let suggestClub = UILabel()
    let line2 = UIView()
    let suggestClubList = ["종로 맛집 모임", "판교 앱개발 모임"]
    var suggestClubInfo = ["종로 맛집 공유 목적. 어서오세요", "개발 정보 나눠봐요"]
    var suggestClubMember = ["멤버 318","멤버 192"]
    var suggestTableView = UITableView()
    
    func makeJoinClub() {
        joinClub.text = "가입한 모임"
        joinClub.textColor = UIColor(color: .textStrong)
        joinClub.font = .headFont(.xSmall , weight: .semibold)
    }
    func makeLine() {
        line.backgroundColor = UIColor(color: .textStrong)
    }
    func makeLine2() {
        line2.backgroundColor = UIColor(color: .textStrong)
    }
    func makeSuggestClub() {
        suggestClub.text = "추천 모임"
        suggestClub.textColor = .black
        suggestClub.font = .headFont(.xSmall , weight: .semibold)
    }
    func makeTableView() {
        joinClubTableView.register(HomeViewcell.self, forCellReuseIdentifier: "Cell")
        joinClubTableView.dataSource = self
        joinClubTableView.delegate = self
    }
    func makeTableView2() {
        suggestTableView.register(HomeViewcell.self, forCellReuseIdentifier: "Cell")
        suggestTableView.dataSource = self
        suggestTableView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeJoinClub()
        makeSuggestClub()
        makeLine()
        makeLine2()
        makeTableView()
        makeTableView2()
        joinClubTableView.rowHeight = UITableView.automaticDimension
        
        setLayout()
    }
    func setLayout() {
        view.addSubview(joinClub)
        view.addSubview(suggestClub)
        view.addSubview(line)
        view.addSubview(line2)
        view.addSubview(joinClubTableView)
        view.addSubview(suggestTableView)
        
    
        joinClub.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.left.equalToSuperview().offset(20)
        }
        suggestClub.snp.makeConstraints { make in
            make.top.equalTo(joinClub.snp.bottom).offset(280)
            make.left.equalToSuperview().offset(20)
        }
        line.snp.makeConstraints { make in
            make.top.equalTo(joinClub.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(350)
            make.height.equalTo(1)
        }
        line2.snp.makeConstraints { make in
            make.top.equalTo(suggestClub.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(350)
            make.height.equalTo(1)
        }
        joinClubTableView.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom).offset(3)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
        suggestTableView.snp.makeConstraints { make in
            make.top.equalTo(line2.snp.bottom).offset(3)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
    }
}

extension HomeViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return joinClubList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HomeViewcell
        if tableView == joinClubTableView {
            cell.clubname1.text = joinClubList[indexPath.row]
            cell.clubname2.text = joinClubInfo[indexPath.row]
            cell.clubname3.text = joinClubMember[indexPath.row]
        } else {
            cell.clubname1.text = suggestClubList[indexPath.row]
            cell.clubname2.text = suggestClubInfo[indexPath.row]
            cell.clubname3.text = suggestClubMember[indexPath.row]
        }
        cell.clubView.image = UIImage(systemName: "photo")
        cell.clubView.frame = CGRect(x: 55, y: 10, width: 30, height: 30)
        return cell
    }
}
