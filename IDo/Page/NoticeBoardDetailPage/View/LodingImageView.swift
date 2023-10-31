//
//  LodingImageView.swift
//  IDo
//
//  Created by 김도현 on 2023/10/30.
//

import UIKit

class LodingImageView: UIView, DataLoding {
    var errorView: EmptyMessageStackView = EmptyMessageStackView(messageType: .networkError)
    var lodingView: UIActivityIndicatorView = UIActivityIndicatorView()
    var loadedView: UIStackView = {
        let stackview = UIStackView()
        stackview.axis = .horizontal
        stackview.alignment = .fill
        stackview.distribution = .fill
        return stackview
    }()
    var imageView = UIImageView(image: nil)
    var image: UIImage? = nil {
        didSet {
            guard let image else { return }
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
    
    var viewState: ViewState {
        didSet {
            update()
        }
    }
    
    init() {
        loadedView.addArrangedSubview(imageView)
        viewState = .loading
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension LodingImageView {
    func setup() {
        addViews()
        setupAutoLayout()
    }
    func addViews() {
        addSubview(errorView)
        addSubview(lodingView)
        addSubview(loadedView)
    }
    func setupAutoLayout() {
        errorView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(Constant.margin3)
            make.left.right.equalToSuperview()
        }
        
        loadedView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        lodingView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(Constant.margin3)
            make.left.right.equalToSuperview()
        }
    }
}
