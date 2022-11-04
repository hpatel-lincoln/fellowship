//
//  MainViewController.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/28/22.
//

import UIKit
import PromiseKit

enum FollowList: String, CaseIterable {
  case following = "Following"
  case followers = "Followers"
}

class MainViewController: UIViewController {
  
  struct Constants {
    static let StandardMargin: CGFloat = 8
    static let ProfileImageViewHeight: CGFloat = 80
    static let PageControlHeight: CGFloat = 40
    static let UnderlineHeight: CGFloat = 3
  }
  
  private let userSession: UserSession
  private let httpClient: HttpClient
  private let factory: MainFlowViewControllerFactory
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("This class does not support NSCoder")
  }
  
  init(userSession: UserSession, httpClient: HttpClient, factory: MainFlowViewControllerFactory) {
    self.userSession = userSession
    self.httpClient = httpClient
    self.factory = factory
    super.init(nibName: nil, bundle: nil)
  }
  
  private var viewControllers: [FollowListViewController] = []
  private let titles: [String] = FollowList.allCases.map { $0.rawValue }
  private var maxHeadingTopOffset: CGFloat {
    headingView.bounds.height - Constants.PageControlHeight
  }
  
  private var headingView: UIView!
  private var headingViewTop = NSLayoutConstraint()
  private var profileImageView: UIImageView!
  private var nameLabel: UILabel!
  private var usernameLabel: UILabel!
  
  private var pageControl: PageControl!
  
  private var scrollView: UIScrollView!
  private var stackView: UIStackView!
  
  private var shouldUpdateLayout = true
  private var checkScrollPosition: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    
    setupHeadingView()
    setupPageControl()
    setupScrollView()
    setupPlaceholderView()
    
    nameLabel.font = .preferredFont(forTextStyle: .headline)
    nameLabel.text = userSession.currentUser?.name
    
    usernameLabel.font = .preferredFont(forTextStyle: .caption1)
    usernameLabel.text = userSession.currentUser?.username
    
    if let imageURL = userSession.currentUser?.profileImageURL {
      loadProfileImage(at: imageURL)
    }
    
    if let userID = userSession.currentUser?.id {
      addFollowListViewControllers(for: userID)
    }
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    updateProfileImageViewLayout()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if shouldUpdateLayout {
      addBottomBorder(to: headingView)
      for viewController in viewControllers {
        viewController.insetTop = maxHeadingTopOffset
      }
      shouldUpdateLayout = false
    }
  }
  
  private func setupHeadingView() {
    headingView = UIView()
    view.addSubview(headingView)
    headingView.translatesAutoresizingMaskIntoConstraints = false
    headingViewTop = headingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
    let headingViewCon = [
      headingViewTop,
      headingView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      headingView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
    ]
    NSLayoutConstraint.activate(headingViewCon)
    
    profileImageView = UIImageView()
    headingView.addSubview(profileImageView)
    profileImageView.translatesAutoresizingMaskIntoConstraints = false
    let profileImageViewCon = [
      profileImageView.topAnchor.constraint(equalTo: headingView.topAnchor,
                                            constant: Constants.StandardMargin*2),
      profileImageView.heightAnchor.constraint(equalToConstant: Constants.ProfileImageViewHeight),
      profileImageView.centerXAnchor.constraint(equalTo: headingView.centerXAnchor),
      profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor)
    ]
    NSLayoutConstraint.activate(profileImageViewCon)
    
    nameLabel = UILabel()
    headingView.addSubview(nameLabel)
    nameLabel.translatesAutoresizingMaskIntoConstraints = false
    let nameLabelCon = [
      nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor,
                                     constant: Constants.StandardMargin),
      nameLabel.centerXAnchor.constraint(equalTo: headingView.centerXAnchor)
    ]
    NSLayoutConstraint.activate(nameLabelCon)
    
    usernameLabel = UILabel()
    headingView.addSubview(usernameLabel)
    usernameLabel.translatesAutoresizingMaskIntoConstraints = false
    let usernameLabelCon = [
      usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,
                                         constant: Constants.StandardMargin*0.5),
      usernameLabel.centerXAnchor.constraint(equalTo: headingView.centerXAnchor)
    ]
    NSLayoutConstraint.activate(usernameLabelCon)
  }
  
  private func setupPageControl() {
    let options = PageControlOptions(underlineHeight: Constants.UnderlineHeight,
                                     underlineColor: view.tintColor,
                                     titleFont: UIFont.preferredFont(forTextStyle: .headline),
                                     titleColor: UIColor.label,
                                     titles: titles)
    
    pageControl = PageControl(frame: .zero, options: options)
    headingView.addSubview(pageControl)
    pageControl.translatesAutoresizingMaskIntoConstraints = false
    pageControl.addTarget(self, action: #selector(onCurrentIndexChange), for: .valueChanged)
    
    let pageControlCon = [
      pageControl.centerXAnchor.constraint(equalTo: headingView.centerXAnchor),
      pageControl.widthAnchor.constraint(equalTo: headingView.widthAnchor, multiplier: 0.6),
      pageControl.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor,
                                       constant: Constants.StandardMargin*2),
      pageControl.bottomAnchor.constraint(equalTo: headingView.bottomAnchor),
      pageControl.heightAnchor.constraint(equalToConstant: Constants.PageControlHeight)
    ]
    NSLayoutConstraint.activate(pageControlCon)
  }
  
  private func setupScrollView() {
    scrollView = UIScrollView()
    view.addSubview(scrollView)
    view.sendSubviewToBack(scrollView)
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.bounces = false
    scrollView.isPagingEnabled = true
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.delegate = self
    
    let scrollViewCon = [
      scrollView.frameLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                       constant: Constants.PageControlHeight),
      scrollView.frameLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      scrollView.frameLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ]
    NSLayoutConstraint.activate(scrollViewCon)
    
    stackView = UIStackView()
    scrollView.addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .horizontal
    stackView.alignment = .fill
    stackView.distribution = .fill
    let stackViewCon = [
      stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
      stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
      stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
      stackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
    ]
    NSLayoutConstraint.activate(stackViewCon)
  }
  
  private func setupPlaceholderView() {
    let placeholderView = UIView()
    placeholderView.backgroundColor = .systemBackground
    view.addSubview(placeholderView)
    placeholderView.translatesAutoresizingMaskIntoConstraints = false
    let placeholderViewCon = [
      placeholderView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      placeholderView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      placeholderView.topAnchor.constraint(equalTo: view.topAnchor),
      placeholderView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
    ]
    NSLayoutConstraint.activate(placeholderViewCon)
  }
  
  private func addFollowListViewControllers(for userID: String) {
    for list in FollowList.allCases {
      let viewController = createViewController(withList: list, for: userID)
      viewControllers.append(viewController)
      
      addChild(viewController)
      stackView.addArrangedSubview(viewController.view)
      let childViewControllerCon = [
        viewController.view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        viewController.view.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
      ]
      NSLayoutConstraint.activate(childViewControllerCon)
      viewController.didMove(toParent: self)
    }
  }
  
  private func createViewController(withList list: FollowList, for userID: String) -> FollowListViewController {
    let viewController = factory.makeFollowListViewController(
      userID: userID, followList: list
    )
    viewController.delegate = self
    return viewController
  }
  
  @objc
  private func onCurrentIndexChange() {
    let currentIndex = CGFloat(pageControl.currentIndex)
    let pageWidth = scrollView.bounds.width
    let offsetX = currentIndex * pageWidth
    scrollView.contentOffset.x = offsetX
  }
  
  private func loadProfileImage(at imageURL: URL) {
    profileImageView.image = UIImage(systemName: "person.circle")
    let request = URLRequest(url: imageURL)
    firstly {
      httpClient.perform(request: request)
    }.done { [weak self] data in
      guard
        let self = self,
        let image = UIImage(data: data)
      else {
        return
      }
      self.profileImageView.image = image
    }.catch { error in
      print(error)
    }
  }
  
  private func updateProfileImageViewLayout() {
    profileImageView.layer.cornerRadius = profileImageView.bounds.height/2
    profileImageView.clipsToBounds = true
  }
  
  private func addBottomBorder(to view: UIView) {
    let border = CALayer()
    border.frame = CGRect(x: view.bounds.minX,
                          y: view.bounds.maxY,
                          width: view.bounds.width,
                          height: 0.5)
    border.backgroundColor = UIColor.systemGray2.cgColor
    view.layer.addSublayer(border)
  }
}

extension MainViewController: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let pageWidth = scrollView.bounds.width
    guard pageWidth > 0 else {
      return
    }
    
    let currentOffsetX = scrollView.contentOffset.x
    let currentIndex = max(0, Int(round(currentOffsetX/pageWidth)))
    let currentPageX = CGFloat(currentIndex) * pageWidth
    let percent = (currentOffsetX - currentPageX)/pageWidth

    pageControl.currentIndex = currentIndex
    pageControl.userDidScroll(toPercent: percent)
  }
}

extension MainViewController: FollowListViewControllerDelegate {
  
  func didScroll(_ scrollView: UIScrollView) {
    let offsetY = scrollView.contentOffset.y
    var trueOffsetY = scrollView.contentInset.top + offsetY
    trueOffsetY = max(0, min(maxHeadingTopOffset, trueOffsetY))
    headingViewTop.constant = -trueOffsetY
    if trueOffsetY < maxHeadingTopOffset {
      checkScrollPosition = true
      let offset = CGPoint(x: 0, y: offsetY)
      adjustContentOffset(offset)
    }
  }
  
  func didEndDragging(_ scrollView: UIScrollView) {
    guard checkScrollPosition == true else { return }
    let offsetY = scrollView.contentOffset.y
    let trueOffsetY = scrollView.contentInset.top + offsetY
    if trueOffsetY >= maxHeadingTopOffset {
      checkScrollPosition = false
      let offset = CGPoint(x: 0, y: 0)
      adjustContentOffset(offset)
    }
  }
  
  func didEndDecelerating(_ scrollView: UIScrollView) {
    guard checkScrollPosition == true else { return }
    let offsetY = scrollView.contentOffset.y
    let trueOffsetY = scrollView.contentInset.top + offsetY
    if trueOffsetY >= maxHeadingTopOffset {
      checkScrollPosition = false
      let offset = CGPoint(x: 0, y: 0)
      adjustContentOffset(offset)
    }
  }
  
  private func adjustContentOffset(_ contentOffset: CGPoint) {
    for (index, viewController) in viewControllers.enumerated() {
      if index == pageControl.currentIndex { continue }
      viewController.adjustContentOffset(contentOffset)
    }
  }
}
