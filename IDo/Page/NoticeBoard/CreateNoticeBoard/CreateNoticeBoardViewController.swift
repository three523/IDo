//
//  CreateNoticeBoardViewController.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/11.
//

import UIKit

class CreateNoticeBoardViewController: UIViewController {
    
    private let createNoticeBoardView = CreateNoticeBoardView()
    
    private var isTitleTextViewEdited = false
    private var isContentTextViewEdited = false
    
    private var isEditingMode = false
    
    private var editingTitleText: String?
    private var editingContentText: String?
    
    private var editingMemoIndex: Int?
    
    override func loadView() {
        view = createNoticeBoardView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationControllerSet()
        navigationBarButtonAction()
        
        createNoticeBoardView.titleTextView.delegate = self
        createNoticeBoardView.contentTextView.delegate = self
        
        navigationController?.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.createNoticeBoardView.titleTextView.resignFirstResponder()
        self.createNoticeBoardView.contentTextView.resignFirstResponder()
    }
    
}

private extension CreateNoticeBoardViewController {
    
    func navigationControllerSet() {
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.view.tintColor = UIColor(named: "MainColor")
    }
    
    func navigationBarButtonAction() {
        
        // 수정 할 때
        if isEditingMode {
            if let editingTitleText = editingTitleText, let editingContentText = editingContentText {
                
                // 제목 textView
                createNoticeBoardView.titleTextView.text = editingTitleText
                createNoticeBoardView.titleTextView.textColor = UIColor.black
                
                // 내용 textView
                createNoticeBoardView.contentTextView.text = editingContentText
                createNoticeBoardView.contentTextView.textColor = UIColor.black
            }
            
            // 네비게이션 바 오른쪽 버튼 커스텀 -> 완료
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(finishButtonTappedEdit))
        }
        
        // 처음 작성 할 때
        else {
            DispatchQueue.main.async {
                
                // 제목 textView
                self.createNoticeBoardView.titleTextView.text = "제목을 입력하세요."
                self.createNoticeBoardView.titleTextView.textColor = UIColor(color: .placeholder)
                self.createNoticeBoardView.titleTextView.resignFirstResponder()
                
                // 내용 textView
                self.createNoticeBoardView.contentTextView.text = "내용을 입력하세요."
                self.createNoticeBoardView.contentTextView.textColor = UIColor(color: .placeholder)
                self.createNoticeBoardView.contentTextView.resignFirstResponder()
            }
            
            // 네비게이션 바 오른쪽 버튼 커스텀 -> 완료
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(finishButtonTappedNew))
        }
    }
    
    // 새로운 메모 작성
    @objc func finishButtonTappedNew() {
        navigationController?.popViewController(animated: true)
        if isTitleTextViewEdited && isContentTextViewEdited {
            let newTitleText = createNoticeBoardView.titleTextView.text
            let newContentText = createNoticeBoardView.contentTextView.text
            
            // 메모 추가 코드 필요
        }
    }
    
    // 메모 내용 수정
    @objc func finishButtonTappedEdit() {
        navigationController?.popViewController(animated: true)
        
        if let updatedTitle = createNoticeBoardView.titleTextView.text, !updatedTitle.isEmpty, let updatedContent = createNoticeBoardView.contentTextView.text, !updatedContent.isEmpty,
           let index = editingMemoIndex {
            
            // 해당 인덱스의 메모 수정 코드 필요
            
            // 수정된 메모 내용을 업데이트하고 해당 셀만 리로드
            (self.navigationController?.viewControllers.first as? NoticeBoardView)?.noticeBoardTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
        
        // 수정 모드 종료
        isEditingMode = false
    }
}

extension CreateNoticeBoardViewController: UITextViewDelegate {
    
    // 초기 호출
    func textViewDidBeginEditing(_ textView: UITextView) {
        if createNoticeBoardView.titleTextView.textColor == UIColor(color: .placeholder), createNoticeBoardView.contentTextView.textColor == UIColor(color: .placeholder) {
            
            // 제목 textView
            createNoticeBoardView.titleTextView.text = nil
            createNoticeBoardView.titleTextView.textColor = UIColor.black
            
            // 내용 textView
            createNoticeBoardView.contentTextView.text = nil
            createNoticeBoardView.contentTextView.textColor = UIColor.black
        }
    }
    
    // 입력 시 호출
    func textViewDidChange(_ textView: UITextView) {
        isTitleTextViewEdited = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        isContentTextViewEdited = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // 입력 종료 시 호출
    func textViewDidEndEditing(_ textView: UITextView) {
        if createNoticeBoardView.titleTextView.text.isEmpty {
            createNoticeBoardView.titleTextView.text =  "제목을 입력하세요."
            createNoticeBoardView.titleTextView.textColor = UIColor(color: .placeholder)
        }
        
        else if createNoticeBoardView.contentTextView.text.isEmpty {
            createNoticeBoardView.contentTextView.text =  "내용을 입력하세요."
            createNoticeBoardView.contentTextView.textColor = UIColor(color: .placeholder)
        }
    }
}

extension CreateNoticeBoardViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        isEditingMode = false
    }
}


