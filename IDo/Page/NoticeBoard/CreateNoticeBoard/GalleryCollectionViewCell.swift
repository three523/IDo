//
//  GalleryCollectionViewCell.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/12.
//

import UIKit
import SnapKit

class GalleryCollectionViewCell: UICollectionViewCell {
    
    // Cell 식별자
    static let identifier = "GalleryCollectionViewCell"
    
    weak var removeCellDelegate: RemoveDelegate?
    
    let createNoticeBoardImagePicker = CreateNoticeBoardImagePicker()
    var indexPath: IndexPath!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubView()
        autoLayout()
        
        createNoticeBoardImagePicker.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        createNoticeBoardImagePicker.galleryImageView.image = nil
    }
    
    private func addSubView() {
        contentView.addSubview(createNoticeBoardImagePicker)
    }
    
    // Cell 객체 autoLayout
    private func autoLayout() {

        createNoticeBoardImagePicker.snp.makeConstraints { make in
            make.width.equalTo(contentView.snp.width)
            make.height.equalTo(contentView.snp.height)
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension GalleryCollectionViewCell: ImagePickerDelegate {
    func clickDeleteButton() {
        removeCellDelegate?.removeCell(indexPath)
    }
}
