//
//  NavigationBar.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/11/05.
//

import UIKit

extension UINavigationController {

    func setNavigationBackButton(title: String) {
        let backBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        backBarButtonItem.tintColor = .black
        self.navigationBar.topItem?.backBarButtonItem = backBarButtonItem
    }

    func setNavigationTitle(title: String) {
        guard let visibleViewController = self.visibleViewController else { return }
        visibleViewController.navigationItem.title = title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.bodyFont(.medium, weight: .regular),
            .foregroundColor: UIColor.black
        ]
        self.navigationBar.titleTextAttributes = titleAttributes
    }

    func setNavigationCategoryTitle() {
        guard let visibleViewController = self.visibleViewController else { return }
        let titleLabel = UILabel()
        titleLabel.text = TemporaryManager.shared.categoryData ?? ""
        titleLabel.font = UIFont.bodyFont(.medium, weight: .regular)
        titleLabel.textAlignment = .center
        
        visibleViewController.navigationItem.titleView = titleLabel
    }
}
