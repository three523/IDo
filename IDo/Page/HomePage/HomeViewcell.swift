
import SnapKit
import UIKit

class HomeViewcell: UITableViewCell {
    let clubname1: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.medium , weight: .semibold)
        return label
    }()
    let clubname2: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.small, weight: .regular)
        return label
    }()
    let clubname3: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.small, weight: .regular)
        label.textColor = UIColor(color: .text2)
        return label
    }()
    let clubView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .black
        imageView.layer.cornerRadius = 28
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(clubname1)
        contentView.addSubview(clubname2)
        contentView.addSubview(clubname3)
        contentView.addSubview(clubView)
        
        clubname1.snp.makeConstraints { make in
            make.leading.equalTo(clubView.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(10)
        }
        clubname2.snp.makeConstraints { make in
            make.top.equalTo(clubname1.snp.bottom).offset(2)
            make.leading.equalTo(clubView.snp.trailing).offset(10)
        }
        clubname3.snp.makeConstraints { make in
            make.top.equalTo(clubname2.snp.bottom).offset(2)
            make.leading.equalTo(clubView.snp.trailing).offset(10)
        }
        clubView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.equalToSuperview().offset(0)
            make.width.height.equalTo(60)
            make.centerY.equalToSuperview().inset(10)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
