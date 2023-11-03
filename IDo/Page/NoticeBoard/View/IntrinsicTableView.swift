//
//  File.swift
//  IDo
//
//  Created by 김도현 on 2023/11/02.
//

import UIKit

final class IntrinsicTableView: UITableView {

    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }

}
