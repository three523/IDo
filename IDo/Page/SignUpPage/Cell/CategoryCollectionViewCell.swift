//
//  CategoryCollectionViewCell.swift
//  IDo
//
//  Created by 김도현 on 2023/10/20.
//

import UIKit

final class CategoryCollectionViewCell: UICollectionViewCell, Reusable {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.medium, weight: .regular)
        label.textColor = UIColor(color: .textStrong)
        return label
    }()
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? UIColor(color: .contentPrimary) : UIColor(color: .backgroundPrimary)
            titleLabel.textColor = isSelected ? UIColor(color: .white) : UIColor(color: .textStrong)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension CategoryCollectionViewCell {
    func setup() {
        addViews()
        setupAutolayout()
    }
    func addViews() {
        contentView.addSubview(titleLabel)
    }
    func setupAutolayout() {
        titleLabel.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(Constant.margin2)
        }
    }
}
