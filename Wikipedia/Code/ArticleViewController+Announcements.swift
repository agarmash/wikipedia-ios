import WMF
import CocoaLumberjackSwift

extension ArticleViewController {
    
    func showAnnouncementIfNeeded() {
        guard (isInValidSurveyCampaignAndArticleList && userHasSeenSurveyPrompt) || !isInValidSurveyCampaignAndArticleList else {
            return
        }
        let predicate = NSPredicate(format: "placement == 'article' && isVisible == YES")
        let contentGroups = dataStore.viewContext.orderedGroups(of: .announcement, with: predicate)
        let currentDate = Date()
        
        // get the first content group with a valid date
        let contentGroup = contentGroups?.first(where: { (group) -> Bool in
            guard group.contentType == .announcement,
                  let announcement = group.contentPreview as? WMFAnnouncement,
                  let startDate = announcement.startTime,
                  let endDate = announcement.endTime
                  else {
                return false
            }
            
            return (startDate...endDate).contains(currentDate)
        })
        
        guard
            !isBeingPresentedAsPeek,
            let contentGroupURL = contentGroup?.url,
            let announcement = contentGroup?.contentPreview as? WMFAnnouncement,
            let actionURL = announcement.actionURL
        else {
            return
        }
        
        let dismiss = {
            // re-fetch since time has elapsed
            let contentGroup = self.dataStore.viewContext.contentGroup(for: contentGroupURL)
            contentGroup?.markDismissed()
            contentGroup?.updateVisibilityForUserIsLogged(in: self.session.isAuthenticated)
            do {
                try self.dataStore.viewContext.save()
            } catch let saveError {
                DDLogError("Error saving after marking article announcement as dismissed: \(saveError)")
            }
        }
        
        guard !articleURL.isThankYouDonationURL else {
            dismiss()
            return
        }

        // Dummy
        let text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

        if let url  = URL(string:"donate.wikimedia.org") {
            let positiveAction = WKAsset.WKActionPositive(title: "positive", url: url)
            let negativeAction = WKAsset.WKActionNegative(title: "negative")

            let object = WKAsset(textHtml: text, footerHtml: "Footer notes", actionPositive: positiveAction, actionNegative: negativeAction, currencyCode: "USD")
            // Dummy end

            wmf_showFundraisingAnnouncement(theme: theme, object: object)
        }

//        wmf_showAnnouncementPanel(announcement: announcement, primaryButtonTapHandler: { (sender) in
//            self.navigate(to: actionURL, useSafari: false)
//            // dismiss handler is called
//        }, secondaryButtonTapHandler: { (sender) in
//            // dismiss handler is called
//        }, footerLinkAction: { (url) in
//             self.navigate(to: url, useSafari: true)
//            // intentionally don't dismiss
//        }, traceableDismissHandler: { _ in
//            dismiss()
//        }, theme: theme)
    }
}
