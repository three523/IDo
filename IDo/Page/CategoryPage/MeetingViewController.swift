//
//  MeetingViewController.swift
//  IDo
//
//  Created by t2023-m0053 on 2023/10/11.
//

import Foundation
import UIKit

class MeetingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    func setup() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .done, target: self, action: #selector(setBtnTap))
    }

    @objc
    func setBtnTap() {
        print("setBtnTap")
    }
}
