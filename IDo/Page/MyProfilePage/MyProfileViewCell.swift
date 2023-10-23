
import SnapKit
import UIKit

class WriteMeTableViewCell: UITableViewCell {
    let write: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.medium , weight: .semibold)
        return label
    }()
    let write2: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.small, weight: .regular)
        return label
    }()
    
    let writeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .black
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(write)
        contentView.addSubview(write2)
        contentView.addSubview(writeImageView)
        
        write.snp.makeConstraints { make in
            make.leading.equalTo(writeImageView.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(10)
        }
        write2.snp.makeConstraints { make in
            make.top.equalTo(write.snp.bottom).offset(2)
            make.leading.equalTo(writeImageView.snp.trailing).offset(10)
        }
        
        writeImageView.snp.makeConstraints { make in
            
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
            make.width.height.equalTo(40)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
