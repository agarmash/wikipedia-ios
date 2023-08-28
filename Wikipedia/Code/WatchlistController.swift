import Foundation
import WMF
import WKData

protocol WatchlistControllerDelegate: AnyObject {
    func didSuccessfullyWatchTemporarily(_ controller: WatchlistController)
    func didSuccessfullyWatchPermanently(_ controller: WatchlistController)
    func didSuccessfullyUnwatch(_ controller: WatchlistController)
}

/// This controller contains reusable logic for watching, updating expiry, and unwatching a page. It triggers the network service calls, as well as displays the appropriate toasts and action sheets based on the response.
class WatchlistController {
    
    private let service = WKWatchlistService()
    private weak var delegate: WatchlistControllerDelegate?
    private weak var lastPopoverPresentationController: UIPopoverPresentationController?
    private var performAfterLoginBlock: (() -> Void)?
    private let toastCustomTypeName = "watchlist-add-remove-success"
    
    init(delegate: WatchlistControllerDelegate) {
        self.delegate = delegate
        NotificationCenter.default.addObserver(self, selector: #selector(didLogIn), name:WMFAuthenticationManager.didLogInNotification, object: nil)
    }
    
    @objc private func didLogIn() {
        
        // Delay a little bit to allow login view controller dismissal to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.performAfterLoginBlock?()
            self?.performAfterLoginBlock = nil
        }
        
    }
    
    func watch(pageTitle: String, siteURL: URL, expiry: WKWatchlistExpiryType = .never, viewController: UIViewController, authenticationManager: WMFAuthenticationManager, theme: Theme, sender: UIBarButtonItem, sourceView: UIView?, sourceRect: CGRect?) {
        
        guard authenticationManager.isLoggedIn else {
            performAfterLoginBlock = { [weak self] in
                self?.watch(pageTitle: pageTitle, siteURL: siteURL, viewController: viewController, authenticationManager: authenticationManager, theme: theme, sender: sender, sourceView: sourceView, sourceRect: sourceRect)
            }
            viewController.wmf_showLoginViewController(theme: theme)
            return
        }
        
        guard let wkProject = WikimediaProject(siteURL: siteURL)?.wkProject else {
            viewController.showGenericError()
            return
        }
        
        presentChooseExpiryActionSheet(pageTitle: pageTitle, siteURL: siteURL, wkProject: wkProject, viewController: viewController, theme: theme, sender: sender, sourceView: sourceView, sourceRect: sourceRect, authenticationManager: authenticationManager)
    }
    
    private func displayWatchSuccessMessage(pageTitle: String, wkProject: WKProject, siteURL: URL, expiry: WKWatchlistExpiryType, viewController: UIViewController, theme: Theme, sender: UIBarButtonItem, sourceView: UIView?, sourceRect: CGRect?) {
        let statusTitle: String
        let image = expiry == .never ? UIImage(systemName: "star.fill") : UIImage(systemName: "star.leadinghalf.filled")
        switch expiry {
        case .never:
            statusTitle = WMFLocalizedString("watchlist-added-toast-permanently", value: "Added to your Watchlist permanently.", comment: "Title in toast after a user successfully adds an article to their watchlist, with no expiration.")
        case .oneWeek:
            statusTitle = WMFLocalizedString("watchlist-added-toast-one-week", value: "Added to your Watchlist for 1 week.", comment: "Title in toast after a user successfully adds an article to their watchlist, which expires in one week.")
        case .oneMonth:
            statusTitle = WMFLocalizedString("watchlist-added-toast-one-month", value: "Added to your Watchlist for 1 month.", comment: "Title in toast after a user successfully adds an article to their watchlist, which expires in one month.")
        case .threeMonths:
            statusTitle = WMFLocalizedString("watchlist-added-toast-three-months", value: "Added to your Watchlist for 3 months.", comment: "Title in toast after a user successfully adds an article to their watchlist, which expires in three months.")
        case .sixMonths:
            statusTitle = WMFLocalizedString("watchlist-added-toast-six-months", value: "Added to your Watchlist for 6 months.", comment: "Title in toast after a user successfully adds an article to their watchlist, which expires in 6 months.")
        case .oneYear:
            statusTitle = WMFLocalizedString("watchlist-added-toast-one-year", value: "Added to your Watchlist for 1 year.", comment: "Title in toast after a user successfully adds an article to their watchlist, which expires in 1 year.")
        }
        
        let promptTitle = WMFLocalizedString("watchlist-added-toast-view-watchlist", value: "View Watchlist", comment: "Button in toast after a user successfully adds an article to their watchlist. Tapping will take them to their watchlist.")
        
        let navigateToWatchlistBlock: (() -> Void) = {
            guard let linkURL = siteURL.wmf_URL(withTitle: "Special:Watchlist"),
            let userActivity = NSUserActivity.wmf_activity(for: linkURL) else {
                return
            }
            
            NSUserActivity.wmf_navigate(to: userActivity)
        }
        
        WMFAlertManager.sharedInstance.showBottomAlertWithMessage(statusTitle, subtitle: nil, image: image, type: .custom, customTypeName: toastCustomTypeName, dismissPreviousAlerts: true, callback: navigateToWatchlistBlock, buttonTitle: promptTitle, buttonCallBack: navigateToWatchlistBlock)
    }
    
    private func presentChooseExpiryActionSheet(pageTitle: String, siteURL: URL, wkProject: WKProject, viewController: UIViewController, theme: Theme, sender: UIBarButtonItem, sourceView: UIView?, sourceRect: CGRect?, authenticationManager: WMFAuthenticationManager) {
        
        WMFAlertManager.sharedInstance.dismissAllAlerts()
        
        let title = WMFLocalizedString("watchlist-change-expiry-title", value: "Watchlist expiry", comment: "Title of modal that allows a user to change the expiry setting of a page they are watching.")
        let message = WMFLocalizedString("watchlist-change-expiry-subtitle", value: "Choose Watchlist time period", comment: "Subtitle in modal that allows a user to choose the expiry setting of a page they are watching.")
        
        let expiryOptionPermanent = WMFLocalizedString("watchlist-change-expiry-option-permanent", value: "Permanent", comment: "Title of button in expiry change modal that permanently watches a page.")
        
        let expiryOptionOneWeek = WMFLocalizedString("watchlist-change-expiry-option-one-week", value: "1 week", comment: "Title of button in expiry change modal that watches a page for one week.")
        
        let expiryOptionOneMonth = WMFLocalizedString("watchlist-change-expiry-option-one-month", value: "1 month", comment: "Title of button in expiry change modal that watches a page for one month.")
        
        let expiryOptionThreeMonths = WMFLocalizedString("watchlist-change-expiry-option-three-months", value: "3 months", comment: "Title of button in expiry change modal that watches a page for three months.")
        
        let expiryOptionSixMonths = WMFLocalizedString("watchlist-change-expiry-option-six-months", value: "6 months", comment: "Title of button in expiry change modal that watches a page for six months.")
        
        let expiryOptionOneYear = WMFLocalizedString("watchlist-change-expiry-option-one-year", value: "1 year", comment: "Title of button in expiry change modal that watches a page for one year.")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let titles = [expiryOptionPermanent, expiryOptionOneWeek, expiryOptionOneMonth, expiryOptionThreeMonths, expiryOptionSixMonths, expiryOptionOneYear]
        let expirys: [WKWatchlistExpiryType] = [.never, .oneWeek, .oneMonth, .threeMonths, .sixMonths, .oneYear]
        
        for (title, expiry) in zip(titles, expirys) {
            
            let action = UIAlertAction(title: title, style: .default) { [weak self] (action) in
                self?.service.watch(title: pageTitle, project: wkProject, expiry: expiry, completion: { [weak self] result in
                    
                    DispatchQueue.main.async {
                        guard let self else {
                            return
                        }
                        
                        switch result {
                        case .success:
                            if expiry == .never {
                                self.delegate?.didSuccessfullyWatchPermanently(self)
                            } else {
                                self.delegate?.didSuccessfullyWatchTemporarily(self)
                            }
                            self.displayWatchSuccessMessage(pageTitle: pageTitle, wkProject: wkProject, siteURL: siteURL, expiry: expiry, viewController: viewController, theme: theme, sender: sender, sourceView: sourceView, sourceRect: sourceRect)
                        case .failure(let error):
                            self.evaluateServerError(error: error, viewController: viewController, theme: theme, performAfterLoginBlock: { [weak self] in
                                self?.watch(pageTitle: pageTitle, siteURL: siteURL, viewController: viewController, authenticationManager: authenticationManager, theme: theme, sender: sender, sourceView: sourceView, sourceRect: sourceRect)
                            })
                        }
                    }
                    
                })
            }
            
            alertController.addAction(action)
            
        }
        
        let cancelAction = UIAlertAction(title: CommonStrings.cancelActionTitle, style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            lastPopoverPresentationController = popoverController
            calculatePopoverPosition(sender: sender, sourceView: sourceView, sourceRect: sourceRect)
        }
        
        alertController.overrideUserInterfaceStyle = theme.isDark ? .dark : .light
        
        viewController.present(alertController, animated: true)
    }
    
    func unwatch(pageTitle: String, siteURL: URL, viewController: UIViewController, authenticationManager: WMFAuthenticationManager, theme: Theme) {
        
        guard authenticationManager.isLoggedIn else {
            performAfterLoginBlock = { [weak self] in
                self?.unwatch(pageTitle: pageTitle, siteURL: siteURL, viewController: viewController, authenticationManager: authenticationManager, theme: theme)
            }
            viewController.wmf_showLoginViewController(theme: theme)
            return
        }
        
        guard let wkProject = WikimediaProject(siteURL: siteURL)?.wkProject else {
            viewController.showGenericError()
            return
        }
        
        service.unwatch(title: pageTitle, project: wkProject) { [weak self] result in
            
            DispatchQueue.main.async {
                
                guard let self else {
                    return
                }
                
                switch result {
                case .success:
                    let title = WMFLocalizedString("watchlist-removed", value: "Removed from your Watchlist", comment: "Title in toast after a user successfully removes an article from their watchlist.")
                    let image = UIImage(systemName: "star")
                    WMFAlertManager.sharedInstance.showBottomAlertWithMessage(title, subtitle: nil, image: image, type: .custom, customTypeName: self.toastCustomTypeName, dismissPreviousAlerts: true)
                    self.delegate?.didSuccessfullyUnwatch(self)
                case .failure(let error):
                    self.evaluateServerError(error: error, viewController: viewController, theme: theme, performAfterLoginBlock: { [weak self] in
                        self?.unwatch(pageTitle: pageTitle, siteURL: siteURL, viewController: viewController, authenticationManager: authenticationManager, theme: theme)
                    })
                }
            }
        }
    }
    
    private func evaluateServerError(error: Error, viewController: UIViewController, theme: Theme, performAfterLoginBlock: @escaping () -> Void) {
        guard let serviceError = error as? WMF.MediaWikiNetworkService.ServiceError,
           let mediaWikiDisplayError = serviceError.mediaWikiDisplayError,
              mediaWikiDisplayError.code == "notloggedin" else {
                WMFAlertManager.sharedInstance.showErrorAlert(error, sticky: false, dismissPreviousAlerts: true)
                return
        }
        
        self.performAfterLoginBlock = performAfterLoginBlock
        viewController.wmf_showLoginViewController(theme: theme)
    }
    
    func calculatePopoverPosition(sender: UIBarButtonItem, sourceView: UIView?, sourceRect: CGRect?) {
        guard let lastPopoverPresentationController else {
            return
        }
        
        if let sourceView = sourceView,
           let sourceRect = sourceRect {
            lastPopoverPresentationController.sourceView = sourceView
            lastPopoverPresentationController.sourceRect = sourceRect
        } else {
            lastPopoverPresentationController.barButtonItem = sender
        }
    }
    
    static func calculateToolbarFifthButtonSourceRect(toolbarView: UIView, thirdButtonView: UIView, fourthButtonView: UIView) -> CGRect {
        
        let thirdButtonFrame = toolbarView.convert(thirdButtonView.frame, from: thirdButtonView.superview)
        let fourthButtonFrame = toolbarView.convert(fourthButtonView.frame, from: fourthButtonView.superview)
        
        let spacing = fourthButtonFrame.maxX - thirdButtonFrame.maxX
        
        let fifthFrame = CGRect(x: fourthButtonFrame.minX + spacing + 5, y: fourthButtonFrame.minY - 5, width: fourthButtonFrame.width, height: fourthButtonFrame.height)
        return fifthFrame
    }
}
