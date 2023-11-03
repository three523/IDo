//
//  TableHeaderView.swift
//  IDo
//
//  Created by 김도현 on 2023/11/02.
//

import UIKit

final class MemberListHeaderView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .headFont(.xSmall, weight: .medium)
        label.text = "맴버 목록"
        label.textColor = UIColor(color: .textStrong)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.verticalEdges.equalToSuperview().inset(Constant.margin1)
        }
    }

}
