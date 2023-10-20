//
//  NoticeMeetingController.swift
//  IDo
//
//  Created by t2023-m0053 on 2023/10/12.
//

import FirebaseDatabase
import FirebaseAuth
import Pageboy
import Tabman
import UIKit

class NoticeMeetingController: TabmanViewController {
    private var viewControllers: [UIViewController] = []
    private var tempView: UIView!
<<<<<<< HEAD

=======
    private var club: Club
    private var currentUser: User
    private var isJoin: Bool
    private let fbUserDatabaseManager: FirebaseUserDatabaseManager
    
    init(club: Club, currentUser: User, isJoin: Bool) {
        self.club = club
        self.currentUser = currentUser
        self.isJoin = isJoin
        self.fbUserDatabaseManager = FirebaseUserDatabaseManager(refPath: ["Users",currentUser.uid])
        super.init(nibName: nil, bundle: nil)
        fbUserDatabaseManager.readData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
>>>>>>> 995bb5b7cebe16c8b57666fafff150199f6b4dfb
    override func viewDidLoad() {
        super.viewDidLoad()

        tempView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        view.addSubview(tempView)
        tempView.snp.makeConstraints { make in
            make.top.equalTo(100)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(30)
        }
        
        let HomeVC = NoticeHomeController(club: club, isJoin: isJoin, fbUserDatabaseManager: fbUserDatabaseManager)
        TemporaryManager.shared.meetingIndex = TemporaryManager.shared.meetingIndex
        TemporaryManager.shared.categoryData = TemporaryManager.shared.categoryData

        let titleVC = NoticeBoardViewController()

        viewControllers.append(HomeVC)
        viewControllers.append(titleVC)

        bounces = false
        dataSource = self

        let bar = TMBar.ButtonBar()
        bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
        bar.backgroundView.style = .flat(color: .white)

        addBar(bar, dataSource: self, at: .custom(view: tempView!, layout: nil))
    }
}

extension NoticeMeetingController: PageboyViewControllerDataSource, TMBarDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }

    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController?
    {
//        print("###", index)
        if index == 1 {
            let createButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(moveCreateVC)) // 게시글 수정 페이지
            navigationItem.rightBarButtonItem = createButton
        } else {
            let updateButton = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(moveUpdateVC))
            navigationItem.rightBarButtonItem = updateButton // 모임 수정 페이지
        }
        return viewControllers[index]
    }

    @objc func moveCreateVC() {
        let createNoticeBoardVC = CreateNoticeBoardViewController()
        navigationController?.pushViewController(createNoticeBoardVC, animated: true)
    }

    @objc func moveUpdateVC() {
        guard let selectedIndex = TemporaryManager.shared.meetingIndex else { return }
        let updateNoticeBoardVC = MeetingManageViewController()
        // 데이터 전달
        updateNoticeBoardVC.meetingTitle = TemporaryManager.shared.meetingTitle[selectedIndex]
        TemporaryManager.shared.meetingDescription = TemporaryManager.shared.meetingDate[selectedIndex]
        updateNoticeBoardVC.meetingImageURL = TemporaryManager.shared.meetingImageUrls[selectedIndex]

        navigationController?.pushViewController(updateNoticeBoardVC, animated: true) // 모임 수정 페이지
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        // return nil
        return .at(index: 0)
    }

    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
//        print("###", index)
        switch index {
        case 0:
            return TMBarItem(title: "홈")
        case 1:
            return TMBarItem(title: "게시판")
        default:
            let title = "Page \(index)"
            return TMBarItem(title: title)
        }
    }
}
