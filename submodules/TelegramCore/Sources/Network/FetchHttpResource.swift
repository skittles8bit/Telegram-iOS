import Foundation
import Postbox
import SwiftSignalKit
import MtProtoKit

public func fetchHttpResource(url: String) -> Signal<MediaResourceDataFetchResult, MediaResourceDataFetchError> {
    guard
        let urlString = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
        let url = URL(string: urlString)
    else {
        return .never()
    }
    
    return Signal { subscriber in
        let disposable = MTHttpRequestOperation.data(forHttpUrl: url)!.start(next: { next in
            if let response = next as? MTHttpResponse {
                let fetchResult: MediaResourceDataFetchResult = .dataPart(resourceOffset: 0, data: response.data, range: 0 ..< Int64(response.data.count), complete: true)
                subscriber.putNext(fetchResult)
            } else {
                subscriber.putError(.generic)
            }
            subscriber.putCompletion()
        }, error: { _ in
            subscriber.putError(.generic)
            subscriber.putCompletion()
        }, completed: {
            subscriber.putCompletion()
        })
        
        return ActionDisposable {
            disposable?.dispose()
        }
    }
}
