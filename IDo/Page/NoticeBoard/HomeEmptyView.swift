//
//  HomeEmptyView.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/11/03.
//

import UIKit
import SnapKit

class HomeEmptyView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        addSubView()
        autoLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 게시판이 없을 때
    private(set) lazy var emptyMessageStackView = EmptyMessageStackView()
    
}

private extension HomeEmptyView {
    
    // NoticeBoardEmptyView의 기본 UI 설정
    func configureUI() {
        backgroundColor = UIColor(color: .backgroundPrimary)
        emptyMessageStackView.setImage(image: UIImage(systemName: "person.2"))
        emptyMessageStackView.titleLabel.text = "가입한 모임이 없습니다."
        emptyMessageStackView.descriptionLabel.text = "모임에 가입해서 취미/관심사를 공유해보세요."
    }
    
    // NoticeBoardEmptyView를 SubView에 추가
    func addSubView() {
        addSubview(emptyMessageStackView)
    }
    
    // 오토레이아웃 설정
    func autoLayout() {
        emptyMessageStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
               make.left.right.equalToSuperview().inset(Constant.margin3)
        }
    }
}
