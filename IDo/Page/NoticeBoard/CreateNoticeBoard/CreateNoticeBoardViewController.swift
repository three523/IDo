//
//  CreateNoticeBoardViewController.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/11.
//

import UIKit

protocol RemoveDelegate: AnyObject {
    func removeCell(_ indexPath: IndexPath)
}

class CreateNoticeBoardViewController: UIViewController {
    
    var selectedImages: [UIImage] = []
    
    private let createNoticeBoardView = CreateNoticeBoardView()
    
    private var isTitleTextViewEdited = false
    private var isContentTextViewEdited = false
    
    private var isEditingMode = false
    
    private var editingTitleText: String?
    private var editingContentText: String?
    
    private var editingMemoIndex: Int?
    
    var firebaseManager: FirebaseManager
    private let club: Club
    
    init(club: Club, firebaseManager: FirebaseManager) {
        self.club = club
        self.firebaseManager = firebaseManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = createNoticeBoardView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationControllerSet()
        navigationBarButtonAction()
        
        buttonAction()
        
        createNoticeBoardView.titleTextView.delegate = self
        createNoticeBoardView.contentTextView.delegate = self
        
        createNoticeBoardView.galleryCollectionView.delegate = self
        createNoticeBoardView.galleryCollectionView.dataSource = self
        
        navigationController?.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.createNoticeBoardView.titleTextView.resignFirstResponder()
        self.createNoticeBoardView.contentTextView.resignFirstResponder()
    }
    
}

// MARK: - NavigationBar 관련 extension
private extension CreateNoticeBoardViewController {
    
    func navigationControllerSet() {
        self.title = "게시판 작성"
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
            let finishButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(finishButtonTappedEdit))
            self.navigationItem.rightBarButtonItem = finishButton
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor(color: .main)
        }
        
        // 처음 작성 할 때
        else {
            // 제목 textView
            self.createNoticeBoardView.titleTextView.text = "제목을 입력하세요."
            self.createNoticeBoardView.titleTextView.textColor = UIColor(color: .placeholder)
            self.createNoticeBoardView.titleTextView.resignFirstResponder()
            
            // 내용 textView
            self.createNoticeBoardView.contentTextView.text = "내용을 입력하세요."
            self.createNoticeBoardView.contentTextView.textColor = UIColor(color: .placeholder)
            self.createNoticeBoardView.contentTextView.resignFirstResponder()
            
            // 네비게이션 바 오른쪽 버튼 커스텀 -> 완료
            let finishButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(finishButtonTappedNew))
            self.navigationItem.rightBarButtonItem = finishButton
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor(color: .main)
        }
        self.navigationItem.rightBarButtonItem?.isEnabled = isTitleTextViewEdited && isContentTextViewEdited
    }
    
    // 새로운 메모 작성
    @objc func finishButtonTappedNew() {
        
        if isTitleTextViewEdited && isContentTextViewEdited {
            
            guard let newTitleText = createNoticeBoardView.titleTextView.text else { return }
            guard let newContentText = createNoticeBoardView.contentTextView.text else { return }
            
            // 메모 추가 코드 필요
            firebaseManager.createNoticeBoard(title: newTitleText, content: newContentText, clubID: club.id)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    // 메모 내용 수정
    @objc func finishButtonTappedEdit() {
        
        if let updateTitle = createNoticeBoardView.titleTextView.text, !updateTitle.isEmpty,
           let updateContent = createNoticeBoardView.contentTextView.text, !updateContent.isEmpty,
           let index = editingMemoIndex {
            
            // 해당 인덱스의 메모 수정 코드 필요
            firebaseManager.updateNoticeBoard(at: index, title: updateTitle, content: updateContent)
            
            // 수정된 메모 내용을 업데이트하고 해당 셀만 리로드
            (self.navigationController?.viewControllers.first as? NoticeBoardView)?.noticeBoardTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
        
        // 수정 모드 종료
        isEditingMode = false
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - TextView 관련
extension CreateNoticeBoardViewController: UITextViewDelegate {
    
    // 초기 호출
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        // 제목 textView
        if textView == createNoticeBoardView.titleTextView {
            if createNoticeBoardView.titleTextView.textColor == UIColor(color: .placeholder) {
                
                createNoticeBoardView.titleTextView.text = nil
                createNoticeBoardView.titleTextView.textColor = UIColor.black
            }
        }
        
        // 내용 textView
        if textView == createNoticeBoardView.contentTextView {
            if createNoticeBoardView.contentTextView.textColor == UIColor(color: .placeholder) {
                
                createNoticeBoardView.contentTextView.text = nil
                createNoticeBoardView.contentTextView.textColor = UIColor.black
            }
        }
    }
    
    // 입력 시 호출
    func textViewDidChange(_ textView: UITextView) {
        
        // 제목 textView에 내용이 있는 경우
        if createNoticeBoardView.titleTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).count != 0, createNoticeBoardView.titleTextView.textColor == UIColor.black {
            isTitleTextViewEdited = true
        }
        
        // 내용 textView에 내용이 있는 경우
        if createNoticeBoardView.contentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).count != 0, createNoticeBoardView.contentTextView.textColor == UIColor.black{
            isContentTextViewEdited = true
        }
        
        // 제목과 내용이 모두 있으면 "완료" 버튼 활성화
        self.navigationItem.rightBarButtonItem?.isEnabled = isTitleTextViewEdited && isContentTextViewEdited
    }
    
    // 입력 종료 시 호출
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if createNoticeBoardView.titleTextView.text.isEmpty {
            createNoticeBoardView.titleTextView.text =  "제목을 입력하세요."
            createNoticeBoardView.titleTextView.textColor = UIColor(color: .placeholder)
        }
        
        if createNoticeBoardView.contentTextView.text.isEmpty {
            createNoticeBoardView.contentTextView.text =  "내용을 입력하세요."
            createNoticeBoardView.contentTextView.textColor = UIColor(color: .placeholder)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let chagedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        if textView == createNoticeBoardView.titleTextView {
            createNoticeBoardView.titleCountLabel.text = "(\(chagedText.count)/15)"
            return chagedText.count <= 15
        }
        
        if textView == createNoticeBoardView.contentTextView {
            createNoticeBoardView.contentCountLabel.text = "(\(chagedText.count)/500)"
            return chagedText.count <= 499
        }
        return true
    }
}

// MARK: - addPictureButton 관련
private extension CreateNoticeBoardViewController {
    
    func buttonAction() {
        createNoticeBoardView.addPictureButton.addTarget(self, action: #selector(addPicture), for: .touchUpInside)
    }
    
    @objc func addPicture() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
}

extension CreateNoticeBoardViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
//            if let cell = createNoticeBoardView.galleryCollectionView.visibleCells.first as? GalleryCollectionViewCell {
//                cell.createNoticeBoardImagePicker.galleryImageView.image = image
//            }
            selectedImages.append(image)
            // 업데이트된 이미지 배열로 컬렉션 뷰를 새로고침
            createNoticeBoardView.galleryCollectionView.reloadData()
            
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - 사진 CollectionView 관련
extension CreateNoticeBoardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCollectionViewCell.identifier, for: indexPath) as? GalleryCollectionViewCell else { return UICollectionViewCell() }
        cell.createNoticeBoardImagePicker.galleryImageView.image = selectedImages[indexPath.row]
        cell.removeCellDelegate = self
        cell.indexPath = indexPath
        return cell
    }
    
    
}

extension CreateNoticeBoardViewController: UICollectionViewDelegateFlowLayout {
    
    // CollectionView Cell의 사이즈
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 8)/5, height: (collectionView.bounds.width - 8)/5)
    }
    
    // 수평
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    // 수직
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}

// MARK: - Navigation 관련
extension CreateNoticeBoardViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        isEditingMode = false
    }
}

extension CreateNoticeBoardViewController: RemoveDelegate {
    func removeCell(_ indexPath: IndexPath) {
        createNoticeBoardView.galleryCollectionView.performBatchUpdates {
            selectedImages.remove(at: indexPath.row)
            createNoticeBoardView.galleryCollectionView.deleteItems(at: [indexPath])
        } completion: { (_) in
            self.createNoticeBoardView.galleryCollectionView.reloadData()
        }
    }
}
