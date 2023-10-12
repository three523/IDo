//
//  NoticeBoardDetailViewController.swift
//  IDo
//
//  Created by 김도현 on 2023/10/11.
//

import UIKit
import SnapKit

final class NoticeBoardDetailViewController: UIViewController {
    
    private let scrollView: UIScrollView = UIScrollView()
    private lazy var contentStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            noticeBoardDetailView,
            commentTableView,
        ])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 12
        return stackView
    }()
    private let noticeBoardDetailView: NoticeBoardDetailView = NoticeBoardDetailView()
    private let commentTableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.isScrollEnabled = false
        return tableView
    }()
    private let commentPositionView: UIView = UIView()
    private let addCommentStackView: CommentStackView = CommentStackView()
    private let emptyMessageView: EmptyMessageStackView = {
        let emptyView = EmptyMessageStackView(image: UIImage(systemName: "bubble.right.fill"))
        emptyView.titleLabel.text = "댓글이 없습니다."
        emptyView.descriptionLabel.text = "댓글을 작성해주세요"
        return emptyView
    }()
    private var containerView: UIView = UIView()
    private let dummyList: [Int] = [1,2,3,4,5,6,7,8,9]
    private var tableViewHeightConstraint: Constraint? = nil
    private var addCommentViewBottomConstraint: Constraint? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let tableViewHeight = commentTableView.intrinsicContentSize.height
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: tableViewHeight)
        tableViewHeightConstraint?.update(offset: tableViewHeight)
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
        updateView()
    }
    func addViews() {
        view.addSubview(containerView)
        view.addSubview(commentPositionView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        containerView.addSubview(emptyMessageView)
        view.addSubview(addCommentStackView)
    }
    func autoLayoutSetup() {
        let safeArea = view.safeAreaLayoutGuide
        let contentLayout = scrollView.contentLayoutGuide
        scrollView.snp.makeConstraints { make in
            make.top.left.right.equalTo(safeArea).inset(Constant.margin3)
            make.bottom.equalTo(commentPositionView.snp.top)
        }
        
        commentTableView.snp.makeConstraints { make in
            tableViewHeightConstraint = make.height.equalTo(0).constraint
        }
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(noticeBoardDetailView.snp.bottom)
            make.left.right.bottom.equalTo(safeArea).inset(Constant.margin3)
        }
        
        emptyMessageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        contentStackView.snp.makeConstraints { make in
            make.top.left.right.equalTo(contentLayout)
            make.width.equalTo(Constant.screenWidth - (Constant.margin3 * 2))
        }
        
//        videoDecriptionStackView.topAnchor.constraint(equalTo: contentLayout.topAnchor, constant: 8),
//        videoDecriptionStackView.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor),
//        videoDecriptionStackView.trailingAnchor.constraint(equalTo: contentLayout.trailingAnchor),
//        videoDecriptionStackView.widthAnchor.constraint(equalTo: videoWebView.widthAnchor),
        
//        commentTableView.topAnchor.constraint(equalTo: videoDecriptionStackView.bottomAnchor, constant: margin),
//        commentTableView.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor),
//        commentTableView.trailingAnchor.constraint(equalTo: contentLayout.trailingAnchor),
//        commentTableView.bottomAnchor.constraint(equalTo: contentLayout.bottomAnchor),
//        tableViewheight!,
//        noticeBoardDetailView.snp.makeConstraints { make in
//            make.top.left.right.equalTo(safeArea).inset(Constant.margin3)
//        }
//        commentTableView.snp.makeConstraints { make in
//            make.top.equalTo(noticeBoardDetailView.snp.bottom).offset(32)
//            make.left.right.equalToSuperview().inset(Constant.margin3)
//            make.bottom.equalTo(addCommentStackView.snp.top).inset(Constant.margin1)
//        }
        addCommentStackView.snp.makeConstraints { make in
            make.left.right.equalTo(safeArea)
            self.addCommentViewBottomConstraint = make.bottom.equalTo(safeArea).constraint
        }
        
        commentPositionView.snp.makeConstraints { make in
            make.edges.equalTo(addCommentStackView)
        }
//        emptyMessageView.snp.makeConstraints { make in
//            make.top.equalTo(noticeBoardDetailView.snp.bottom).offset(Constant.margin3)
//            make.left.right.bottom.equalTo(safeArea)
//        }
    }
    func tableViewSetup() {
        commentTableView.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        commentTableView.delegate = self
        commentTableView.dataSource = self
    }
    func updateView() {
        let isCommentEmpty = dummyList.isEmpty
        emptyMessageView.isHidden = !isCommentEmpty
        commentTableView.isHidden = isCommentEmpty
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as? CommentTableViewCell else { return UITableViewCell() }
        return cell
    }
    
}
