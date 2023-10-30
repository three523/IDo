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
    let categoryImage = [UIImage(named: "develop"), UIImage(named: "photo"), UIImage(named: "music"), UIImage(named: "game"), UIImage(named: "travel"), UIImage(named: "dance"), UIImage(named: "animal"), UIImage(named: "fishing"), UIImage(named: "exercise")]
    

    init() {
        let layout = UICollectionViewCompositionalLayout { (_: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            // 아이템 크기
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 3), heightDimension: .absolute(150))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            // 그룹 크기
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(150))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
            group.interItemSpacing = .fixed(10) // 아이템 간 간격

            // 섹션
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 10 // 그룹 간 간격
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10) // 섹션의 인셋

            return section
        }

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
        cell.categoryImageView.image = categoryImage[indexPath.row]
        return cell
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        collectionView.collectionViewLayout.invalidateLayout()
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedCategory = categoryData[indexPath.row]
        let meetingsData = MeetingsData(category: selectedCategory)
        let meetingVC = MeetingViewController(meetingsData: meetingsData)
        TemporaryManager.shared.categoryData = selectedCategory
        
        
        navigationController?.pushViewController(meetingVC, animated: true)
    }
}
