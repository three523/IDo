import UIKit

class MeetingProfileImageButton: UIButton {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        self.setImage(UIImage(named: "MeetingProfileImage"), for: .normal)
        self.imageView?.contentMode = .scaleAspectFill
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
            super.layoutSubviews()
//            self.layer.cornerRadius = self.frame.size.width / 2
            self.clipsToBounds = true
        }
    
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
            let targetSize = CGSize(width: 360, height: 240)
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
