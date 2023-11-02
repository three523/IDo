import UIKit

final class CategoryCollectionViewCell: UICollectionViewCell, Reusable {
    static let identifier = "CategoryCollectionViewCell"

    let categoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.3
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.medium, weight: .regular)
        label.textColor = UIColor(color: .textStrong)
        label.textAlignment = .center
        label.alpha = 0.3
        return label
    }()

    override var isSelected: Bool {
        didSet {
            categoryImageView.alpha = isSelected ? 1.0 : 0.3
            titleLabel.alpha = isSelected ? 1.0 : 0.3
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
