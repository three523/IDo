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
    private let addCommentStackView: CommentStackView = CommentStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

}

private extension NoticeBoardDetailViewController {
    func setup() {
        addViews()
        autoLayoutSetup()
        tableViewSetup()
    }
    func addViews() {
        view.addSubview(noticeBoardView)
        view.addSubview(commentTableView)
        view.addSubview(addCommentStackView)
    }
    func autoLayoutSetup() {
        let safeArea = view.safeAreaLayoutGuide
        noticeBoardView.snp.makeConstraints { make in
            make.top.left.right.equalTo(safeArea).inset(Constant.margin3)
        }
        commentTableView.snp.makeConstraints { make in
            make.top.equalTo(noticeBoardView.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(Constant.margin3)
            make.bottom.equalTo(addCommentStackView.snp.top).inset(Constant.margin1)
        }
        addCommentStackView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
    }
    func tableViewSetup() {
        commentTableView.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        commentTableView.delegate = self
        commentTableView.dataSource = self
    }
}

extension NoticeBoardDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as? CommentTableViewCell else { return UITableViewCell() }
        return cell
    }
    
}
