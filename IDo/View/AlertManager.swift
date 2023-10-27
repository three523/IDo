//
//  AlertManager.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/14.
//

import UIKit

class AlertManager {
    // 정적 메서드로 구현 -> 인스턴스화 시키지 않아도 사용 가능
    static func showAlert(on viewController: UIViewController, title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static func showUpdateAlert(on viewController: UIViewController, title: String? = nil, message: String? = nil, updateHandler: ((UIAlertAction) -> Void)? = nil, deleteHandler: ((UIAlertAction) -> Void)? = nil, cancelHandelr: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let updateAction = UIAlertAction(title: "수정", style: .default, handler: updateHandler)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive, handler: deleteHandler)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: cancelHandelr)
        alertController.addAction(updateAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
}

