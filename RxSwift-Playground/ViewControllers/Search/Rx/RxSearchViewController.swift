import UIKit
import RxSwift
import RxCocoa

class RxSearchViewController: UIViewController {
    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.becomeFirstResponder()

        let searchUserSignal = self.searchField.rx.text.unwrap().throttle(0.3, scheduler: MainScheduler.instance).distinctUntilChanged().flatMapLatest({
            GithubAPI.shared.rx.searchUser(username: $0).retry(3).catchErrorJustReturn([])
        }).shareReplay(1)

        searchUserSignal.bindTo(tableView.rx.items(cellIdentifier: "SimpleCell")) { _, model, cell in
            cell.textLabel?.text = model.username
        } >>> disposeBag
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
 
Can we do more?
 
And one more thing

*/
