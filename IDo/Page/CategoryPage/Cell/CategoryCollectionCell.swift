//
//  CategoryColletcionCell.swift
//  IDo
//
//  Created by t2023-m0053 on 2023/10/23.
//

import Foundation
import SnapKit
import UIKit

class CategoryCollectionCell: UICollectionViewCell {
    let categoryImageView = UIImageView()
    let label = UILabel()
      
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
      
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
      
    func setupViews() {
        addSubview(categoryImageView)
        addSubview(label)
          
        categoryImageView.contentMode = .scaleAspectFit
        categoryImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10).offset(70)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(80)
        }
          
        label.textAlignment = .center
        label.snp.makeConstraints { make in
            make.top.equalTo(categoryImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(10)
        }
    }
}
