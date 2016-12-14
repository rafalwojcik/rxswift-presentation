import Foundation

struct GithubUser {
    let username: String

    static func parseJSON(json: Any) throws -> [GithubUser] {
        guard
            let validJSON = json as? [String: Any],
            let jsonUserArray = validJSON["items"] as? [[String: Any]]
        else {
            throw AppError.parsingError
        }
        var users = [GithubUser]()
        for user in jsonUserArray {
            guard let login = user["login"] as? String else { throw AppError.parsingError }
            users.append(GithubUser(username: login))
        }
        return users
    }
}
