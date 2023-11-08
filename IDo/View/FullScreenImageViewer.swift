//
//  FullScreenImageViewer.swift
//  IDo
//
//  Created by t2023-m0091 on 11/7/23.
//

import UIKit
// 편집하는 화면을 새로 만들어야 한다 .....
// 이미지 크롭하는 기능을 포함하는 라이브러리 찾아보기

final class FullScreenImageViewer: UIViewController {
    private let imageView = UIImageView()

    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        imageView.frame = view.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissFullScreenImage))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissFullScreenImage() {
        dismiss(animated: true, completion: nil)
    }
}
