import UIKit

public class ToastManager {

    public static let shared = ToastManager()
    private var view: UIView = UIView()
    private var message: String = ""
    private var bottomAnchor: NSLayoutConstraint!
    private var errorHeaders: [ToastView?] = []
    
    private init() {}
    
    func showError(message: String, view: UIView, isDismissButtonEnabled: Bool = true) {
        let errorHeader: ToastView? = ToastView()
        errorHeaders.forEach({
            hideBanner(errorHeader: $0)
        })
        errorHeaders.append(errorHeader)
        self.view = view
        self.message = message
        createBannerWithInitialPosition(errorHeader: errorHeader, isDismissButtonEnabled: isDismissButtonEnabled)
        errorHeader?.onDismiss = { [weak self] in
            DispatchQueue.main.async {
                self?.hideBanner(errorHeader: errorHeader)
            }
        }
    }
    
    private func createBannerWithInitialPosition(errorHeader: ToastView?, isDismissButtonEnabled:
    Bool) {
        guard let errorHeader = errorHeader else { return }
        errorHeader.errorLabel.text = message
        errorHeader.layer.cornerRadius = 5
        errorHeader.layer.masksToBounds = true
        errorHeader.isDismissButtonEnabled = isDismissButtonEnabled
        view.addSubview(errorHeader)
        let guide = view.safeAreaLayoutGuide
        errorHeader.translatesAutoresizingMaskIntoConstraints = false
        bottomAnchor = errorHeader.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: 80)
        bottomAnchor.isActive = true
        errorHeader.trailingAnchor.constraint(lessThanOrEqualTo: guide.trailingAnchor, constant: -10).isActive = true
        errorHeader.leadingAnchor.constraint(greaterThanOrEqualTo: guide.leadingAnchor, constant: 10).isActive = true
        errorHeader.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        errorHeader.heightAnchor.constraint(equalToConstant: errorHeader.viewHeight).isActive = true
        view.layoutIfNeeded()
        animateBannerPresentation()
    }
    
    private func animateBannerPresentation() {
        if KeyboardStateManager.shared.isVisible {
            bottomAnchor.constant = -KeyboardStateManager.shared.keyboardOffset
        } else {
            bottomAnchor.constant = -20
        }
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: { [weak self] in self?.view.layoutIfNeeded() }, completion: nil)
    }
    
    private func hideBanner(errorHeader: ToastView?) {
        UIView.animate(withDuration: 0.5, animations: {
            errorHeader?.alpha = 0
        }) { _ in
            errorHeader?.removeFromSuperview()
        }
    }
    
    func hideBanner() {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.errorHeaders.forEach { view in
                view?.alpha = 0
            }
        }) { [weak self] _ in
            self?.errorHeaders.forEach { view in
                view?.removeFromSuperview()
            }
        }
    }
}
