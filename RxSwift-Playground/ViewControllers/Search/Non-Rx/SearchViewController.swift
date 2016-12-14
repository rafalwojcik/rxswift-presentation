import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var users: [GithubUser] = [] {
        didSet { self.tableView.reloadData() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.becomeFirstResponder()
        searchField.delegate = self
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        GithubAPI.shared.searchUser(username: searchText, completionHandler: { [unowned self] result in
            switch result {
                case .success(let users):
                    self.users = users
                case .failure(let error): print(error) // do something on error
            }
        }).resume()
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleCell", for: indexPath)
        if let user = users[safe: indexPath.row] {
            cell.textLabel?.text = user.username
        }
        return cell
    }
}
