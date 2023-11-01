//
//  NoticeMeetingController.swift
//  IDo
//
//  Created by t2023-m0053 on 2023/10/12.
//

import FirebaseAuth
import FirebaseDatabase
import Pageboy
import Tabman
import SnapKit
import UIKit

class NoticeMeetingController: TabmanViewController {
    private var viewControllers: [UIViewController] = []
    private var tempView: UIView!
    private let firebaseManager = FirebaseManager()
    private var club: Club
    private var currentUser: User
    private var isJoin: Bool
    private let fbUserDatabaseManager: FirebaseUserDatabaseManager
    private let clubImage: UIImage
    private let HomeVC: NoticeHomeController

    init(club: Club, currentUser: User, isJoin: Bool, clubImage: UIImage) {
        self.club = club
        self.currentUser = currentUser
        self.isJoin = isJoin
        self.clubImage = clubImage
        self.fbUserDatabaseManager = FirebaseUserDatabaseManager(refPath: ["Users", currentUser.uid])
        self.HomeVC = NoticeHomeController(club: club, isJoin: isJoin, fbUserDatabaseManager: fbUserDatabaseManager, clubImage: clubImage)
        super.init(nibName: nil, bundle: nil)
        fbUserDatabaseManager.readData()
        HomeVC.signUpButtonUpdate = { [weak self] in
            self?.isJoin = true
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tempView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        view.addSubview(tempView)
        tempView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(30)
        }

        TemporaryManager.shared.meetingIndex = TemporaryManager.shared.meetingIndex
        TemporaryManager.shared.categoryData = TemporaryManager.shared.categoryData

        let titleVC = NoticeBoardViewController(club: club, firebaseManager: firebaseManager)

        viewControllers.append(HomeVC)
        viewControllers.append(titleVC)

        bounces = false
        dataSource = self

        let bar = TMBar.ButtonBar()
        bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
        
        // 탭 바의 배경 색상 설정
        bar.backgroundView.style = .flat(color: .white)
        
        // 탭 아이템의 글자 색상 설정
        bar.buttons.customize { (button) in
            
            // 비활성화된 탭의 색상
            button.tintColor = UIColor(color: .contentDisable)
            
            // 활성화된 탭의 색상
            button.selectedTintColor = UIColor(color: .main)
        }
        
        // 선택된 탭 아래에 나타나는 인디케이터의 색상 설정
        bar.indicator.tintColor = UIColor(color: .main)
        
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
        if index == 1 {
            if !isJoin {
                showAlert()
                return nil
            } else {
                let createButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(moveCreateVC)) // 게시글 수정 페이지
                navigationItem.rightBarButtonItem = createButton
            }
        } else {
            let updateButton = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(moveUpdateVC))
            navigationItem.rightBarButtonItem = updateButton // 모임 수정 페이지
        }
        return viewControllers[index]
    }

    func showAlert() {
        let alertController = UIAlertController(title: "알림", message: "모임에 가입한 회원만 이용 가능합니다.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    @objc func moveCreateVC() {
        let createNoticeBoardVC = CreateNoticeBoardViewController(club: club, firebaseManager: firebaseManager)
        
        // 네비게이션 백 버튼의 이름 설정
        let backBarButtonItem = UIBarButtonItem(title: "뒤로가기", style: .plain, target: self, action: nil)
        backBarButtonItem.tintColor = .black
        navigationItem.backBarButtonItem = backBarButtonItem
        
        navigationController?.pushViewController(createNoticeBoardVC, animated: true)
    }

    @objc func moveUpdateVC() {
        let updateNoticeBoardVC = MeetingManageViewController(club: club, clubImage: clubImage)
        updateNoticeBoardVC.updateHandler = { [weak self] club, data in
            self?.HomeVC.update(club: club, imageData: data)
        }
        // 데이터 전달
//        updateNoticeBoardVC.meetingTitle =  TemporaryManager.shared.meetingTitle[selectedIndex] // meetingmanageviewcontroller 가 이 속성이 있는데 이걸 인스턴스화 해서 meetingtitle 속성을 가지고 있음
//        TemporaryManager.shared.meetingDescription = TemporaryManager.shared.meetingDate[selectedIndex]
//        updateNoticeBoardVC.meetingImageURL = TemporaryManager.shared.meetingImageUrls[selectedIndex]
        TemporaryManager.shared.selectedMeetingId = club.id

        // 네비게이션 백 버튼의 이름 설정
        let backBarButtonItem = UIBarButtonItem(title: "뒤로가기", style: .plain, target: self, action: nil)
        backBarButtonItem.tintColor = .black
        navigationItem.backBarButtonItem = backBarButtonItem
        
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
