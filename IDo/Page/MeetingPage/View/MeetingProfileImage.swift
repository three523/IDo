import UIKit

class MeetingProfileImageButton: UIButton {
    
    var profileImageChanged: Bool = false
    
    // 서브뷰로 레이블이랑 아이콘 따서 넣고 테두리 선 그어서 코드로 구현
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        self.setImage(UIImage(named: "MeetingProfileImage"), for: .normal)
        self.imageView?.contentMode = .scaleToFill
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 24
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//    override func layoutSubviews() {
//            super.layoutSubviews()
////            self.layer.cornerRadius = self.frame.size.width / 2
//            self.clipsToBounds = true
//        }
    
    // 이미지 선택
    func openImagePicker(in viewController: UIViewController) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = viewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.sourceType = .photoLibrary
        viewController.present(imagePicker, animated: true, completion: nil)
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
        func resizedAndRoundedImage() -> UIImage? {
            var imageWidth = UIScreen.main.bounds.width-40
            let desiredAspectRatio: CGFloat = 3.0 / 4.0
            var imageHeight = imageWidth * desiredAspectRatio
            
            let targetSize = CGSize(width: imageWidth, height: imageHeight)
            let cornerRadius: CGFloat = 24.0

            UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
            
            let rect = CGRect(origin: CGPoint.zero, size: targetSize)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            path.addClip()
            
            self.draw(in: rect)

            let resultImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return resultImage
        }
}
