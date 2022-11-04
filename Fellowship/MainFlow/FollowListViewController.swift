//
//  FollowListViewController.swift
//  Fellowship
//
//  Created by Hardik Patel on 11/1/22.
//

import UIKit
import PromiseKit

protocol FollowListViewControllerDelegate: AnyObject {
  func didScroll(_ scrollView: UIScrollView)
  func didEndDragging(_ scrollView: UIScrollView)
  func didEndDecelerating(_ scrollView: UIScrollView)
}

class FollowListViewController: UIViewController {
  
  private struct Constants {
    static let CellReuseIdentifier: String = "TwitterUserCell"
  }
  
  private let followSearchService: FollowSearchService
  private let userID: String
  private let followList: FollowList
  
  private var users: [TwitterUser] = []
  private var tableView: UITableView!
  
  weak var delegate: FollowListViewControllerDelegate?
  
  var insetTop: CGFloat = 0 {
    didSet {
      tableView.contentInset.top = insetTop
      tableView.contentOffset.y = -insetTop
    }
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("This class does not support NSCoder")
  }
  
  init(
    followSearchService: FollowSearchService,
    userID: String, followList: FollowList
  ) {
    self.followSearchService = followSearchService
    self.userID = userID
    self.followList = followList
    super.init(nibName: nil, bundle: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    loadFollowList()
  }
  
  private func setupTableView() {
    tableView = UITableView()
    view.addSubview(tableView)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    
    let tableViewCon = [
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
    ]
    NSLayoutConstraint.activate(tableViewCon)
    
    tableView.backgroundColor = .clear
    tableView.showsVerticalScrollIndicator = false
    
    tableView.register(
      UITableViewCell.self,
      forCellReuseIdentifier: Constants.CellReuseIdentifier
    )
    
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 100
    
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  private func loadFollowList() {
    var promise: Promise<TwitterUserList>
    switch followList {
    case .following:
      promise = followSearchService.getFollowing(forUser: userID)
    case .followers:
      promise = followSearchService.getFollowers(forUser: userID)
    }
    
    firstly {
      promise
    }.done { userList in
      self.users = userList.users
      self.tableView.reloadData()
    }.catch { error in
      print(error)
    }
  }
}

extension FollowListViewController: UITableViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    delegate?.didScroll(scrollView)
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate { delegate?.didEndDragging(scrollView) }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    delegate?.didEndDecelerating(scrollView)
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

extension FollowListViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: Constants.CellReuseIdentifier, for: indexPath
    )
    let user = users[indexPath.row]
    var configuration = cell.defaultContentConfiguration()
    configuration.text = user.name
    configuration.secondaryText = user.username
    cell.contentConfiguration = configuration
    return cell
  }
}

extension FollowListViewController {
  
  func adjustContentOffset(_ contentOffset: CGPoint) {
    tableView.bounds.origin = contentOffset
  }
}
