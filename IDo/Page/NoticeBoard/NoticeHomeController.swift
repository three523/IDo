//
//  NoticeHomeController.swift
//  IDo
//
//  Created by t2023-m0053 on 2023/10/12.
//

import SnapKit
import UIKit

class NoticeHomeController: UIViewController {
    lazy var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "MeetingProfileImage")
        return imageView
    }()
    
    lazy var label: UILabel = {
        var label = UILabel()
        label.font = .headFont(.xSmall, weight: .bold)
        label.text = "[B.R.P] 보라매 런앤플레이"
        return label
    }()
    
    lazy var textLabel: UILabel = {
        var textLabel = UILabel()
        textLabel.font = .bodyFont(.medium, weight: .regular)
        textLabel.numberOfLines = 0
        textLabel.text = "안녕하세요. 설명입니다. "
        return textLabel
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.scrollsToTop = true
        return scrollView
    }()
    
    private let scrollStackViewContainer: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.spacing = 25
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        view.addSubview(scrollView)
        scrollView.addSubview(scrollStackViewContainer)
        view.addSubview(imageView)
            
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.layoutMarginsGuide.snp.top).offset(40)
            make.centerX.equalTo(view)
        }
            
        scrollStackViewContainer.snp.makeConstraints { make in
            make.leading.equalTo(scrollView.contentLayoutGuide.snp.leading)
            make.trailing.equalTo(scrollView.contentLayoutGuide.snp.trailing)
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
        }
            
        scrollView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(view.layoutMarginsGuide.snp.top)
            make.bottom.equalTo(view.layoutMarginsGuide.snp.bottom)
        }
            
        configureContainerView()
    }
    
    private func configureContainerView() {
        scrollStackViewContainer.addArrangedSubview(label)
        scrollStackViewContainer.addArrangedSubview(textLabel)
    }
}
