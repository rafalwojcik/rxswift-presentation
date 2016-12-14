import UIKit
import RxSwift
import RxCocoa

class RxSearchViewController: UIViewController {
    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    var users: Variable<[GithubUser]> = Variable([])
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.becomeFirstResponder()

        self.searchField.rx.text.unwrap().throttle(1.0, scheduler: MainScheduler.instance).distinctUntilChanged().flatMapLatest({
            GithubAPI.shared.rx.searchUser(username: $0).retry(3).catchErrorJustReturn([])
        }).shareReplay(1).bindTo(users) >>> disposeBag

        users.asObservable().subscribe(onNext: { _ in
            self.tableView.reloadData()
        }) >>> disposeBag
    }
}

extension RxSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleCell", for: indexPath)
        if let user = users.value[safe: indexPath.row] {
            cell.textLabel?.text = user.username
        }
        return cell
    }
}

/*

You can in 3 lines:
[] Get text from textfield
[] Pass it to API request only if text changed and with throttle
[] make API request
[] retry it up to 3 times when something goes wrong
[] start with empty result
[] and return something on error
[] also share results in how many places you want
 
*/
