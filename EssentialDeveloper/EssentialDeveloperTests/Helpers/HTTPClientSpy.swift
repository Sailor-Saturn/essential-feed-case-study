import EssentialDeveloper

final class HTTPClientSpy: HTTPClient {
    private struct Task: HTTPClientTask {
        let completion: () -> Void
        
        func cancel() {
            completion()
        }
                   
    }
    
    private var messages = [(
        url: URL,
        completion:  (HTTPClient.Result) -> Void
    )]()
    
    var requestedURLs: [URL] {
        return messages.map { $0.url }
    }
    
    private(set) var cancelledURLs = [URL]()
    
    func get(
        from url: URL,
        completion: @escaping (HTTPClient.Result) -> Void
    ) -> HTTPClientTask {
        messages.append((url, completion))
        
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
    }
    
    func complete(with error: Error, index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(
        withStatusCode code: Int,
        data: Data,
        at index: Int = 0
    ) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
        
        
        messages[index].completion(.success((data, response)))
    }
}
