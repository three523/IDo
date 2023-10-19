//
//  CommentTableViewCell.swift
//  IDo
//
//  Created by 김도현 on 2023/10/12.
//

import UIKit
import SnapKit

class CommentTableViewCell: UITableViewCell, Reusable {
    
    let writeInfoView: WriterStackView = WriterStackView()
    var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.small, weight: .regular)
        label.text = "텍스트 입니다"
        label.numberOfLines = 1
        return label
    }()
    var moreButtonTapHandler: () -> Void = {}
    var updateEnable: Bool = false {
        didSet {
            writeInfoView.moreImageView.isHidden = !updateEnable
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CommentTableViewCell {
    func setDate(dateText: String) {
        writeInfoView.writerTimeLabel.text = dateText
    }
}

private extension CommentTableViewCell {
    func setup() {
        addViews()
        autoLayoutSetup()
        writeStackViewSetup()
    }
    func addViews() {
        contentView.addSubview(writeInfoView)
        contentView.addSubview(contentLabel)
    }
    func autoLayoutSetup() {
        writeInfoView.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(Constant.margin2)
            make.left.right.equalTo(contentView)
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(writeInfoView.snp.bottom).offset(Constant.margin2)
            make.left.right.equalTo(contentView)
            make.bottom.equalTo(contentView).inset(Constant.margin2)
        }
    }
    func writeStackViewSetup() {
        writeInfoView.moreButtonTapHandler = { [weak self] in
            guard let self else { return }
            self.moreButtonTapHandler()
        }
    }
}
