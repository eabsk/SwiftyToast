import UIKit

class ToastView: UIView {
    
    @IBOutlet weak var labelTrailingConstraints: NSLayoutConstraint!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton! {
        didSet {
            dismissButton.layer.cornerRadius = dismissButton.bounds.height / 2
        }
    }
    
    var isDismissButtonEnabled: Bool = true {
        didSet {
            dismissButton.isHidden = !isDismissButtonEnabled
            labelTrailingConstraints.constant = isDismissButtonEnabled ? 50 : 10
            labelTrailingConstraints.isActive = true
        }
    }
    
    var onDismiss: (() -> Void)?
    
    // MARK: Properties
    var viewHeight: CGFloat {
        let textString = (errorLabel.text ?? "") as NSString
        let textAttributes: [NSAttributedString.Key: Any] = [.font: errorLabel.font ?? .systemFont(ofSize: 16)]
        let estimatedTextHeight = textString.boundingRect(with: CGSize(width: 320, height: 2_000),
                                                          options: .usesLineFragmentOrigin, attributes: textAttributes, context: nil).height
        let height = estimatedTextHeight + 20
        return height
    }
    
    // MARK: Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.module.loadNibNamed("ToastView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
    }
    
    @IBAction func dismissButtonAction(_ sender: Any) {
        onDismiss?()
    }
}
