//
//  CommentStackView.swift
//  IDo
//
//  Created by 김도현 on 2023/10/12.
//

import UIKit

class CommentStackView: UIStackView {
    
    private let lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        return view
    }()
    let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person"))
        imageView.clipsToBounds = true
        imageView.tintColor = .systemGray6
        imageView.backgroundColor = .systemGray3
        return imageView
    }()
    private let commentTextView: UITextView = {
        let textView = UITextView()
        textView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        textView.font = .bodyFont(.small, weight: .regular)
        textView.backgroundColor = UIColor(color: .backgroundSecondary)
        textView.layer.cornerRadius = 5
        textView.textColor = UIColor(color: .placeholder)
        textView.showsVerticalScrollIndicator = false
        textView.isScrollEnabled = false
        return textView
    }()
    private let sendButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "paperplane"), for: .normal)
        button.tintColor = .systemGray5
        return button
    }()
    private let textViewPlaceHolder = "댓글을 입력해주세요"
    var commentAddHandler: ((String) -> Void)?
    
    private let margin: CGFloat = 12
    private let imageSize: CGFloat = 30

    override init(frame: CGRect) {
        super.init(frame: frame)
        stackViewSetup()
        addViews()
        configureView()
        configureAutoLayout()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CommentStackView {
    private func stackViewSetup() {
        axis = .horizontal
        alignment = .center
        distribution = .fill
        spacing = 12
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        backgroundColor = .white
    }
    
    private func addViews() {
        addSubview(lineView)
        addArrangedSubview(profileImageView)
        addArrangedSubview(commentTextView)
        addArrangedSubview(sendButton)
    }
    
    private func configureView() {
        profileImageView.layer.cornerRadius = imageSize / 2
        
        commentTextView.delegate = self
        commentTextView.text = textViewPlaceHolder
        
        sendButton.addTarget(self, action: #selector(sendButtonClick), for: .touchUpInside)
    }
    
    @objc private func sendButtonClick() {
        guard let textComment = commentTextView.text else { return }
        commentAddHandler?(textComment)
        commentTextView.text = ""
        commentTextView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = imageSize
            }
        }
    }
    
    private func configureAutoLayout() {
        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(equalTo: topAnchor),
            lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1),
            
            profileImageView.heightAnchor.constraint(equalToConstant: imageSize),
            profileImageView.widthAnchor.constraint(equalToConstant: imageSize),
            
            commentTextView.topAnchor.constraint(equalTo: topAnchor, constant: margin),
            commentTextView.heightAnchor.constraint(equalToConstant: imageSize),
            commentTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin),
                          
            sendButton.heightAnchor.constraint(equalToConstant: imageSize),
            sendButton.widthAnchor.constraint(equalToConstant: imageSize),
        ])
    }
}

extension CommentStackView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            
            if estimatedSize.height < imageSize - 5 {
                textView.isScrollEnabled = false
            } else if textView.numLines > 4 {
                textView.isScrollEnabled = true
            } else {
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                }
            }
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceHolder {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .systemGray4
        }
    }
}

extension UITextView {
    var numLines: Int {
        guard let font else { return 1 }
        return Int(self.contentSize.height / (font.lineHeight))
    }
}
