//
//  NoticeBoardDetailViewController.swift
//  IDo
//
//  Created by 김도현 on 2023/10/11.
//

import UIKit

final class NoticeBoardDetailViewController: UIViewController {
    
    private let noticeBoardView: NoticeBoardView = NoticeBoardView()
    private let commentTableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

private extension NoticeBoardDetailViewController {
    func addViews() {
        view.addSubview(noticeBoardView)
    }
}
