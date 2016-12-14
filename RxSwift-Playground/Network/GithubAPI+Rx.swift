import Foundation
import RxSwift

extension GithubAPI: ReactiveCompatible {}

extension Reactive where Base: GithubAPI {
    func searchUser(username: String) -> Observable<[GithubUser]> {
        return Observable.create({ observer -> Disposable in
            let request = self.base.makeRequest(endpoint: .searchUser(username: username)).validate(statusCode: [200]).responseJSON { response in
                switch response.result {
                case .success (let json):
                    do {
                        let users = try GithubUser.parseJSON(json: json)
                        observer.onNext(users)
                        observer.onCompleted()
                    } catch {
                        observer.onError(error)
                    }
                case .failure(let error):
                    observer.onError(error)
                }
            }
            request.resume()
            return Disposables.create {
                request.cancel()
            }
        })
    }
}
