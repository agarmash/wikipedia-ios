import Foundation
import WMF
import WKData

final class WatchlistFetcher: Fetcher, WatchlistFetching {

    func fetchWatchlist(siteURL: URL, completion: @escaping (Result<WKData.WatchlistAPIResponse, Error>) -> Void) {
        let params = [
            "action": "query",
            "list": "watchlist",
            "wllimit": "500",
            "wlallrev": "1",
            "wlprop": "ids|title|flags|comment|parsedcomment|timestamp|sizes|user|loginfo",
            "errorsuselocal": "1",
            "errorformat": "html",
            "format": "json",
            "formatversion": "2"
        ]
        
        performDecodableMediaWikiAPIGET(for: siteURL, with: params, completionHandler: completion)
    }
}
