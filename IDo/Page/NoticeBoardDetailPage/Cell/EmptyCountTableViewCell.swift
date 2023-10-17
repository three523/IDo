//
//  EmptyCountTableViewCell.swift
//  IDo
//
//  Created by 김도현 on 2023/10/13.
//

import UIKit

protocol DataLoding {
    var errorView: EmptyMessageStackView { get }
    var lodingView: UIActivityIndicatorView { get }
    var loadedView: UIView { get }
    var viewState: ViewState { get set }
    
    func update()
}

extension DataLoding where Self: UIView {
    func update() {
        DispatchQueue.main.async {
            switch self.viewState {
            case .loading:
                self.lodingView.startAnimating()
                self.lodingView.isHidden = false
                self.errorView.isHidden = true
                self.loadedView.isHidden = true
            case .loaded:
                self.lodingView.stopAnimating()
                self.lodingView.isHidden = true
                self.errorView.isHidden = true
                self.loadedView.isHidden = false
            case .error(let isConnectedToInternet):
                self.lodingView.stopAnimating()
                self.lodingView.isHidden = true
                self.errorView.isHidden = false
                self.loadedView.isHidden = true
            }
        }
    }
}

class EmptyCountTableViewCell: UITableViewCell, Reusable, DataLoding {
    
    
    var errorView: EmptyMessageStackView = {
        let emptyView = EmptyMessageStackView()
        emptyView.setImage(image: UIImage(systemName: "bubble.right.fill"))
        emptyView.titleLabel.text = "인터넷 연결이 불안정 합니다"
        emptyView.descriptionLabel.text = "인터넷 연결 후 다시시도 해주세요"
        return emptyView
    }()
    var lodingView: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
    var loadedView: UIView = UIView()
    var viewState: ViewState = .loading {
        didSet {
            update()
        }
    }
    private let emptyMessageView: EmptyMessageStackView = {
        let view = EmptyMessageStackView(imageSize: 60, image: UIImage(systemName: "bubble.right.fill"))
        view.titleLabel.text = "댓글이 없습니다."
        view.descriptionLabel.text = "댓글을 작성해주세요"
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setMessage(image: UIImage?, imageSize: CGFloat = 60, title: String?, description: String?) {
        emptyMessageView.setImage(image: image)
        emptyMessageView.imageSize = imageSize
        emptyMessageView.titleLabel.text = title
        emptyMessageView.descriptionLabel.text = description
    }
    
}

private extension EmptyCountTableViewCell {
    func setup() {
        addViews()
        autoLayoutSetup()
    }
    func addViews() {
        contentView.addSubview(errorView)
        contentView.addSubview(lodingView)
        contentView.addSubview(loadedView)
        loadedView.addSubview(emptyMessageView)
    }
    func autoLayoutSetup() {
        emptyMessageView.snp.makeConstraints { make in
            make.top.bottom.equalTo(loadedView).inset(Constant.margin3)
            make.left.right.equalTo(loadedView)
        }
        errorView.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView).inset(Constant.margin3)
            make.left.right.equalTo(contentView)
        }
        
        loadedView.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView).inset(Constant.margin3)
            make.left.right.equalTo(contentView)
        }
        
        lodingView.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView).inset(Constant.margin3)
            make.left.right.equalTo(contentView)
        }
    }
}
