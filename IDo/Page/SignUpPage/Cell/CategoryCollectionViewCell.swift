import UIKit

final class CategoryCollectionViewCell: UICollectionViewCell, Reusable {
    let categoryImageView = UIImageView()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.medium, weight: .regular)
        label.textColor = UIColor(color: .textStrong)
        return label
    }()

    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? UIColor(color: .contentPrimary) : UIColor(color: .backgroundPrimary)
            titleLabel.textColor = isSelected ? UIColor(color: .white) : UIColor(color: .textStrong)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension CategoryCollectionViewCell {
    func setup() {
        addViews()
        setupAutolayout()
    }

    func addViews() {
        contentView.addSubview(categoryImageView)
        contentView.addSubview(titleLabel)
    }

    func setupAutolayout() {
        categoryImageView.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.centerY.equalTo(contentView).offset(-20)
            make.width.height.equalTo(80)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryImageView.snp.bottom).offset(10)
            make.centerX.equalTo(contentView)
        }
    }
}
