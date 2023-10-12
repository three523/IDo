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
    var joinClub = UILabel()
    var suggestClub = UILabel()
    
    func makeJoinClub() {
        joinClub.text = "가입한 모임"
        joinClub.textColor = .white
        joinClub.font = .headFont(.small, weight: .regular)
    }
    
    func makeSuggestClub() {
        suggestClub.text = "추천 모임"
        suggestClub.textColor = .white
        suggestClub.font = .headFont(.small, weight: .regular)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeJoinClub()
        makeSuggestClub()
        setLayout()
    }
    func setLayout() {
        view.addSubview(joinClub)
        view.addSubview(suggestClub)
        
        joinClub.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.left.equalToSuperview().offset(20)
        }
        suggestClub.snp.makeConstraints { make in
            make.top.equalTo(joinClub.snp.bottom).offset(300)
            make.left.equalToSuperview().offset(20)
        }
    }
}

