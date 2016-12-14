import Foundation
import Alamofire

enum AppError: Error {
    case parsingError
}

class GithubAPI {
    enum Endpoint {
        case searchUser(username: String)

        var path: String {
            switch self {
                case .searchUser: return "/search/users"
            }
        }

        var parameters: Parameters {
            switch self {
                case .searchUser(let username): return [ "q": "\(username) in:login", "per_page": "50" ]
            }
        }
    }

    static let shared: GithubAPI = GithubAPI()
    let baseURL = "https://api.github.com"

    func makeRequest(endpoint: Endpoint) -> DataRequest {
        return Alamofire.request("\(self.baseURL)\(endpoint.path)", method: .get, parameters: appendCredentialsToParameters(parameters: endpoint.parameters))
    }

    func appendCredentialsToParameters(parameters: Parameters) -> Parameters {
        var parametersWithCredentials = parameters
        parametersWithCredentials["client_id"] = GithubCredentials.clientID
        parametersWithCredentials["client_secret"] = GithubCredentials.clientSecret
        return parametersWithCredentials
    }

    func searchUser(username: String, completionHandler: @escaping (Result<[GithubUser]>) -> Void) -> DataRequest {
        return makeRequest(endpoint: .searchUser(username: username)).validate(statusCode: [200]).responseJSON { response in
            switch response.result {
                case .success (let json):
                    do {
                        let users = try GithubUser.parseJSON(json: json)
                        completionHandler(Result.success(users))
                    } catch {
                        completionHandler(Result.failure(error))
                    }
                case .failure(let error): completionHandler(Result.failure(error))
            }
        }
    }
}
