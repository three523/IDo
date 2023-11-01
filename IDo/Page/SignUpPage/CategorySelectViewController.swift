//
//  CategorySelectViewController.swift
//  IDo
//
//  Created by 김도현 on 2023/10/20.
//

import FirebaseAuth
import FirebaseDatabase
import UIKit
final class CategorySelectViewController: UIViewController {
    private let selectedCountLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.medium, weight: .regular)
        label.textColor = UIColor(color: .textStrong)
        label.text = "0개 선택되었습니다. (최대 3개)"
        return label
    }()

    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.setTitleColor(UIColor(color: .white), for: .normal)
        button.backgroundColor = UIColor(color: .contentPrimary)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        return button
    }()

    private let categoryCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = Constant.margin2
        flowLayout.minimumLineSpacing = Constant.margin2
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.allowsMultipleSelection = true
        return collectionView
    }()

    private let categoryData = ["IT•개발", "사진•영상", "음악•악기", "게임•오락", "여행•맛집", "댄스•공연", "동물•식물", "낚시•캠핑", "운동•스포츠"]
    private let email: String
    private let password: String
    private var selectedCategorys: [String] = [] {
        didSet {
            print(selectedCategorys)
            if selectedCategorys.count <= 3 {
                selectedCountLabel.text = "\(selectedCategorys.count)개 선택되었습니다. (최대 3개)"
                nextButton.isEnabled = !selectedCategorys.isEmpty
            }
        }
    }

    init(email: String, password: String) {
        self.email = email
        self.password = password
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let backBarButtonItem = UIBarButtonItem(title: "뒤로가기", style: .plain, target: self, action: nil)
        backBarButtonItem.tintColor = .black
        navigationItem.backBarButtonItem = backBarButtonItem
        setup()
    }
}

private extension CategorySelectViewController {
    func setup() {
        addViews()
        setupAutolayout()
        setupCollectionView()
        setupButton()
    }

    func addViews() {
        view.addSubview(categoryCollectionView)
        view.addSubview(selectedCountLabel)
        view.addSubview(nextButton)
    }

    func setupAutolayout() {
        let safeArea = view.safeAreaLayoutGuide
        categoryCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(safeArea).inset(Constant.margin3)
        }
        nextButton.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(safeArea).inset(Constant.margin3)
        }
        selectedCountLabel.snp.makeConstraints { make in
            make.centerX.equalTo(safeArea)
            make.bottom.equalTo(nextButton.snp.top).offset(-Constant.margin3)
        }
    }

    func setupCollectionView() {
        categoryCollectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
    }

    func setupButton() {
        nextButton.addTarget(self, action: #selector(nextButtonClcik), for: .touchUpInside)
    }

    @objc func nextButtonClcik() {
        let vc = SignUpProfileViewController(email: email, password: password, selectedCategorys: selectedCategorys)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CategorySelectViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else { return UICollectionViewCell() }
        cell.titleLabel.text = categoryData[indexPath.row]
        cell.layer.borderColor = UIColor(color: .black).cgColor
        cell.layer.borderWidth = 1
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCategorys.append(categoryData[indexPath.row])
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let index = selectedCategorys.firstIndex(of: categoryData[indexPath.row]) {
            selectedCategorys.remove(at: index)
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return selectedCategorys.count < 3
    }
}
