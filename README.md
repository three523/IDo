<br>

# 👍🏻iDo

### **취미 공유를 위한 커뮤니티 앱**
<br>

## 목차
- [📆 프로젝트 기간](#-프로젝트-기간)
- [⭐️ 프로젝트 소개](#️-프로젝트-소개)
- [📚 구현 기능](#-구현-기능)
- [👩🏻‍💻 Contributors](#-contributors)
- [🛠️ Tech Stack](️#-tech-stack)
- [🏹 사용한 라이브러리](#-사용한-라이브러리)
- [❓ 라이브러리 사용 이유](️#-라이브러리-사용-이유)
- [🔫 트러블 슈팅](#-트러블-슈팅)
 	- [UI 업데이트](#UI-업데이트)
  	- [이미지 비율 및 다운로드 속도](#이미지-비율-및-다운로드-속도)
  	- [기기 별 레이아웃 조정](#기기-별-레이아웃-조정)

<br>

## 📆 프로젝트 기간

2023년 10월 10일 ~ 2023년 11월 17일 (6주)

<br>

## ⭐️ 프로젝트 소개

### 프로젝트 목표
팀원들간의 협업을 잘 해보기 <br>

<br>

## 📚 나의 구현 기능
    
0. **공통**
    - [x] 이미지 캐싱 작업
    - [x] 이미지 리사이징 작업
    - [x] 페어 프로그래밍 도입
    
   <br>
1. **홈 페이지**
    - [x] 가입한 모임 목록 표시
    
    <br>   
2. **모임 페이지**
    - [x] 가입 멤버 목록
    - [x] 모임장 표시
    
    <br>

3. **게시글 페이지**
    - [x] 제목, 내용, 이미지, 작성 시간 표시
    - [x] 게시글 추가/삭제/수정 기능
    - [x] 댓글 추가/삭제/수정 기능
    - [x] 프로필 이미지 클릭 시, 해당 유저 프로필 확인
    - [x] 게시글 신고하기
    - [x] 댓글 신고하기
    
    <br>
    
<br>

## 👩🏻‍💻 Contributors

| [홍준영](https://github.com/wnsdud0721) | [김도현](https://github.com/jingni1115) | [강지훈](https://github.com/KangJiHun1028) | [한동연](https://github.com/Direchan) | [이애라](https://github.com/aera11) |
| :----------------------------------: | :---------------------------------------: | :-----------------------------------: | :-----------------------------------: | :------------------------------------: |
|               ☀️ 리더                 |                ️🌙 부리더                    |               🛠️ 개발자                 |                🛠️ 개발자                |                🛠️ 개발자                   |
|       게시글 목록/게시글 생성 및 수정       |                 게시글 상세/댓글            |                 회원가입                 |               모임 생성/수정              |                 홈 화면                    |
|              회원탈퇴                 |                 이미지 캐싱                  |                 로그아웃                  |            이미지 유효성 검사 기능          |                마이 프로필 화면            |
|              신고기능                 |                 신고기능                    |                 카테고리                  |               이미지 편집                |                상단 로고 추가              |

<br>

## 🛠️ Tech Stack

<br>

<img src="https://img.shields.io/badge/Xcode-147EFB?style=for-the-badge&logo=Xcode&logoColor=white"/></a>
<img src="https://img.shields.io/badge/Swift-F05138?style=for-the-badge&logo=Swift&logoColor=white"/></a>
<img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=Firebase&logoColor=white"/></a>

<br>
<div align="left">

## 🏹 사용한 라이브러리

1. [Firebase](https://github.com/firebase/firebase-ios-sdk)
2. [SnapKit](https://github.com/SnapKit/SnapKit)
3. [Tabman](https://github.com/uias/Tabman)
4. [TOCropViewController](https://github.com/TimOliver/TOCropViewController)

<br>

## ❓ 라이브러리 사용 이유
   
1. ***Firebase*** <br>
    로그인 및 회원가입 진행 시 `유저의 데이터를 가져오고 비교하기 위해` Authentication에 데이터 동기화를 위해서 사용 <br>
    모임/게시글/댓글 등 `각각 콘텐츠의 CRUD 기능을 위한 데이터를 활용하기 위해` Realtime에 데이터 동기화를 위해서 사용 <br>
    콘텐츠, 유저와 관련된 `이미지를 관리하고 캐싱하기 위해` Storage에 이미지 저장을 위해서 사용 <br>
   
2. ***SnapKit*** <br>
    `코드 기반 UI 작업의 효율성`을 높이기 위해서 사용
    `Auto Layout`을 쉽게 설정하기 위해 사용
   
3. ***Tabman*** <br>
    `상단 탭바 추가`를 위해 사용
   
4. ***TOCropViewController*** <br>
    `이미지 비율을 3:2로 편집`을 쉽게 하기 위해 사용
 
<br>

## 🔫 트러블 슈팅

### UI 업데이트

#### 데이터가 처리되기 전에, 화면 전환이 끝나서 원하는 결과가 보여지지 않음
- 원인 : 데이터 처리가 완료되는 시점을 알 수 없음, 순차적으로 진행이 되게 하는 로직이 없음
- 해결 : 데이터 처리 함수에 `completion` 을 추가해서 데이터 처리가 완료된 시점에 화면 전환이 이루어지게 함
  ```swift
  func createNoticeBoard(title: String, content: String, completion: @escaping (Bool) -> Void) {
      let ref = Database.database().reference().child("noticeBoards").child(club.id)
      let newNoticeBoardID = ref.childByAutoId().key ?? ""
      .
		  .
		  .
      self.uploadImages(noticeBoardID: newNoticeBoardID, imageList: self.newSelectedImage) { success, imageURLs in
          if success {
              .
						  .  
						  .
                  completion(success)
              }
          } else {
              completion(false)
          }
      }
  }
  ```
  ```swift
  // 사용 예시
  // 새로운 메모 작성
  @objc func finishButtonTappedNew() {
      navigationItem.rightBarButtonItem?.isEnabled = false
        
      if isTitleTextViewEdited, isContentTextViewEdited {
          guard let newTitleText = createNoticeBoardView.titleTextView.text else { return }
          guard let newContentText = createNoticeBoardView.contentTextView.text else { return }
            
          firebaseManager.createNoticeBoard(title: newTitleText, content: newContentText) { success in
              if success {
                  self.navigationController?.popViewController(animated: true)
                  print("게시판 생성 성공")
              }
              else {
                  self.navigationItem.rightBarButtonItem?.isEnabled = true
                  print("게시판 생성 실패")
              }
          }
      }
      else {
          navigationItem.rightBarButtonItem?.isEnabled = true
      }
  }
  ```

### 이미지 비율 및 다운로드 속도

#### 이미지 다운로드 속도가 느림
- 원인 : 사용자가 보는 이미지에 비해 매우 큰 사이즈의 이미지를 저장하고 불러오기 때문, Firebase Storage는 따로 캐싱작업을 해주지 않음
- 해결 : compressionQuality 를 사용하여 이미지를 압축하여 저장, storage에 metadata에 있는 md5hash값과 로컬에 있는 이미지 데이터를 md5hash로 변환하여 비교하여 다를 경우 서버에서 이미지를 가져와 캐싱된 이미지를 변경함
  ```swift
  if let image = profileImageButton.image(for: .normal) {
      imageData = image.jpegData(compressionQuality: 0.5) // 이미지 품질
  }
  ```
  ```swift
  extension Data {
      var md5Hash: String {
          let hash = Insecure.MD5.hash(data: self)
          return Data(hash).base64EncodedString()
      }
  }
  ```
  ```swift
  //사용 예시
  if let localDataHash = cacheImage.pngData()?.md5Hash,
     let storageDataHash = metadata?.md5Hash,
     localDataHash == storageDataHash {
     return
  }
  ```

<br>

### 기기 별 레이아웃 조정

#### 기기에 따라서 컴포넌트의 레이아웃이 깨짐
- 원인 : 기기 별로 화면의 크기가 다름, 오토레이아웃을 정확한 수치로 지정
  ```swift
  // 높이를 수치로 설정
  meetingDescriptionTextView.snp.makeConstraints { make in
      make.top.equalTo(countMeetingNameLabel.snp.bottom).offset(Constant.margin4)
      make.centerX.equalTo(scrollView)
      make.left.right.equalTo(scrollView).inset(Constant.margin4)
      make.height.equalTo(160)
  }
  ```
  <p align="left">
    <img src="https://github.com/FiveI-s/IDo/assets/92636626/d9135f68-20a0-4331-952b-54a5f982f91c" alt="iPhone 15 Pro" width="300" style="margin-right: 16px;"/>
    <img src="https://github.com/FiveI-s/IDo/assets/92636626/98d5f79d-9815-4e93-84b3-2cf743ccb8c4" alt="iPhone SE" width="300"/>
  </p>
- 해결 : lessThanOrEqualTo과 greaterThanOrEqualTo 이용해서 레이아웃 설정
   ```swift
  // 높이의 최대, 최소 지정
  meetingDescriptionTextView.snp.makeConstraints { make in
      make.top.equalTo(countMeetingNameLabel.snp.bottom).offset(Constant.margin4)
      make.centerX.equalTo(scrollView)
      make.left.right.equalTo(scrollView).inset(Constant.margin4)
      make.height.lessThanOrEqualTo(160)
      make.height.greaterThanOrEqualTo(100)
  }
  ```
  <p align="left">
    <img src="https://github.com/FiveI-s/IDo/assets/92636626/6cf738d2-4ebf-444d-a112-d20624a3983a" alt="iPhone 15 Pro" width="300" style="margin-right: 16px;"/>
    <img src="https://github.com/FiveI-s/IDo/assets/92636626/f2a9bf79-1efe-4fe6-aba4-dca2dfe237aa" alt="iPhone SE" width="300"/>
  </p>

<br>
