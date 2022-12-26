import UIKit

class CarouselNotificationCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    func configure(imagePath : String) {
        self.setImage(imagePath: imagePath)
    }
    
    private func setImage(imagePath: String){
        guard let url = URL(string: imagePath) else {
            print("Something went wrong with: ", imagePath)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if error == nil {
                guard let unwrappedData = data, let image = UIImage(data: unwrappedData) else { return }
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        })
        task.resume()
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
