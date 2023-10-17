//
//  NoticeBoardDetailViewController.swift
//  IDo
//
//  Created by 김도현 on 2023/10/11.
//

import UIKit
import SnapKit
import FirebaseDatabase

final class NoticeBoardDetailViewController: UIViewController {
    
    private let noticeBoardDetailView: NoticeBoardDetailView = NoticeBoardDetailView()
    private let commentTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = UIColor(color: .backgroundPrimary)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        return tableView
    }()
    private let commentPositionView: UIView = UIView()
    private let addCommentStackView: CommentStackView = CommentStackView()
    private var dummyList: [CommentTest] = []
    private var addCommentViewBottomConstraint: Constraint? = nil
    private var firebaseManager: FirebaseCommentManager!
    private var viewState: ViewState = .loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseManager = FirebaseCommentManager(noticeBoardID: "NoticeBoardID")
        firebaseManager.readCommtents { result in
            switch result {
            case .success(let commentList):
                self.dummyList = commentList
                self.commentTableView.reloadData()
                self.viewState = .loaded
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }

}

private extension NoticeBoardDetailViewController {
    func setup() {
        addViews()
        autoLayoutSetup()
        tableViewSetup()
        addCommentSetup()
    }
    func addViews() {
        view.addSubview(commentPositionView)
        view.addSubview(commentTableView)
        view.addSubview(addCommentStackView)
    }
    func autoLayoutSetup() {
        let safeArea = view.safeAreaLayoutGuide
        
        commentTableView.snp.makeConstraints { make in
            make.top.left.right.equalTo(safeArea).inset(Constant.margin3)
            make.bottom.equalTo(commentPositionView.snp.top).offset(Constant.margin3)
        }
        
        addCommentStackView.snp.makeConstraints { make in
            make.left.right.equalTo(safeArea)
            self.addCommentViewBottomConstraint = make.bottom.equalTo(safeArea).constraint
        }
        
        commentPositionView.snp.makeConstraints { make in
            make.edges.equalTo(addCommentStackView)
        }
        
    }
    func tableViewSetup() {
        commentTableView.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        commentTableView.register(EmptyCountTableViewCell.self, forCellReuseIdentifier: EmptyCountTableViewCell.identifier)
        commentTableView.delegate = self
        commentTableView.dataSource = self
    }
    
    func addCommentSetup() {
        addCommentStackView.commentAddHandler = { [weak self] comment in
            guard let self else { return }
            let commentTest = CommentTest(id: UUID().uuidString, createDate: Date(), content: comment, noticeBoardID: "NoticeBoardID", writeUser: "Tester")
            firebaseManager.addComment(comment: commentTest)
            firebaseManager.readCommtents { result in
                switch result {
                case .success(let commentList):
                    self.dummyList = commentList
                    self.commentTableView.reloadData()
                    self.viewState = .loaded
                case .failure(let error):
                    self.viewState = .error(false)
                    print(error.localizedDescription)
                }
            }
            self.resignFirstResponder()
        }
    }
    
    @objc func keyBoardWillShow(notification: NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        let safeAreaBottomHeight = view.safeAreaInsets.bottom
        self.addCommentViewBottomConstraint?.update(inset: keyboardHeight - safeAreaBottomHeight)
    }

    @objc func keyBoardWillHide(notification: NSNotification) {
        self.addCommentViewBottomConstraint?.update(inset: 0)
    }
}

extension NoticeBoardDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else {
            return dummyList.isEmpty ? 1 : dummyList.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            let headerView = UIView()
            headerView.addSubview(noticeBoardDetailView)
            noticeBoardDetailView.snp.makeConstraints { make in
                make.top.left.right.bottom.equalTo(headerView)
            }
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dummyList.isEmpty {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EmptyCountTableViewCell.identifier, for: indexPath) as? EmptyCountTableViewCell else { return UITableViewCell() }
            cell.viewState = self.viewState
            cell.selectionStyle = .none
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as? CommentTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.contentLabel.text = dummyList[indexPath.row].content
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if dummyList.isEmpty { return nil }
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제", handler: {(action, view, completionHandler) in
            let comment = self.dummyList[indexPath.row]
            self.firebaseManager.deleteComment(comment: comment)
            self.dummyList.remove(at: indexPath.row)
            if self.dummyList.count == 0 {
                self.commentTableView.reloadData()
            } else {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        })
        let updateAction = UIContextualAction(style: .normal, title: "수정", handler: {(action, view, completionHandler) in
            let comment = self.dummyList[indexPath.row]
            let vc = CommentUpdateViewController(comment: comment)
            vc.commentUpdate = { [weak self] comment in
                guard let self else { return }
                self.dummyList[indexPath.row] = comment
                self.firebaseManager.updateComments(comment: comment)
                self.commentTableView.reloadData()
            }
            vc.hidesBottomBarWhenPushed = true
            vc.view.backgroundColor = UIColor(color: .backgroundPrimary)
            self.navigationController?.pushViewController(vc, animated: true)
        })
        updateAction.backgroundColor = UIColor(color: .contentPrimary)
        return UISwipeActionsConfiguration(actions: [deleteAction, updateAction])
    }
    
}
