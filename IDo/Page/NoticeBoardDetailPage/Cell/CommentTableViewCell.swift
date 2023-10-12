//
//  CommentTableViewCell.swift
//  IDo
//
//  Created by 김도현 on 2023/10/12.
//

import UIKit
import SnapKit

class CommentTableViewCell: UITableViewCell, Reusable {
    
    let userInfoStackView: HorizentalImageTitleView = HorizentalImageTitleView()
    let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.small, weight: .regular)
        label.text = "텍스트 입니다"
        label.numberOfLines = 1
        return label
    }()
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.small, weight: .regular)
        label.text = "10/06 13: 56"
        label.numberOfLines = 1
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

private extension CommentTableViewCell {
    func setup() {
        addViews()
        autoLayoutSetup()
        userInfoStackViewSetup()
    }
    func addViews() {
        contentView.addSubview(userInfoStackView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(dateLabel)
    }
    func autoLayoutSetup() {
        userInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(Constant.margin2)
            make.left.right.equalTo(contentView)
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(userInfoStackView.snp.bottom).offset(Constant.margin2)
            make.left.right.equalTo(contentView)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(Constant.margin2)
            make.left.right.equalTo(contentView)
            make.bottom.equalTo(contentView).inset(Constant.margin2)
        }
    }
    func userInfoStackViewSetup() {
        userInfoStackView.imageView.backgroundColor = UIColor(color: .contentPrimary)
        userInfoStackView.image = UIImage(systemName: "person.fill")
        userInfoStackView.imageSize = 30
        userInfoStackView.imageType = .circle
        userInfoStackView.imageViewContentMargin = 4
        userInfoStackView.spacing = 8
    }
}
