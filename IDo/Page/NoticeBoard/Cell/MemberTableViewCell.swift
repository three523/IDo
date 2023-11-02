//
//  MemberTableViewCell.swift
//  IDo
//
//  Created by 김도현 on 2023/11/01.
//

import UIKit

final class MemberTableViewCell: UITableViewCell, Reusable {

    let profileImage: BasicImageView = {
        let imageView = BasicImageView(image: UIImage(systemName: "person"))
        imageView.contentMargin = 4
        imageView.backgroundColor = UIColor(color: .backgroundPrimary)
        imageView.tintColor = UIColor(color: .white)
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.large, weight: .medium)
        label.textColor = UIColor(color: .textStrong)
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.large, weight: .regular)
        label.textColor = UIColor(color: .textStrong)
        return label
    }()
    
    var imageSize: CGFloat = 30

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addViews()
        setupAutoLayout()
    }
    
    private func addViews() {
        contentView.addSubview(profileImage)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
    }
    
    private func setupAutoLayout() {
        profileImage.snp.makeConstraints { make in
            make.left.centerY.equalTo(contentView)
            make.width.height.equalTo(imageSize)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(Constant.margin1)
            make.left.equalTo(profileImage.snp.right).offset(Constant.margin2)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).inset(Constant.margin1)
            make.left.equalTo(profileImage.snp.right).offset(Constant.margin2)
        }
    }

}
