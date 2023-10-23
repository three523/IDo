//
//  CategoryViewController.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/11.
//

import SnapKit
import UIKit

class CategoryViewController: UICollectionViewController {
    let categoryData = ["IT•개발", "사진•영상", "음악•악기", "게임•오락", "여행•맛집", "댄스•공연", "동물•식물", "낚시•캠핑", "운동•스포츠"]
    let categoryImage = UIImage(systemName: "pencil.circle")

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 150)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        super.init(collectionViewLayout: layout)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(CategoryCollectionCell.self, forCellWithReuseIdentifier: "Cell")
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryData.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CategoryCollectionCell else {
            fatalError()
        }
        cell.label.text = categoryData[indexPath.row]
        cell.categoryImageView.image = categoryImage
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCategory = categoryData[indexPath.row]

        let meetingVC = MeetingViewController()
        TemporaryManager.shared.categoryData = selectedCategory

        navigationController?.pushViewController(meetingVC, animated: true)
    }
}
