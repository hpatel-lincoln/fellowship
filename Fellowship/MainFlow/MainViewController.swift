//
//  MainViewController.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/28/22.
//

import UIKit
import PromiseKit

enum MainFollowList: String, CaseIterable {
  case following = "Following"
  case followers = "Followers"
}

class MainViewController: UIViewController {
  
  struct Constants {
    static let StandardMargin: CGFloat = 8
    static let ProfileImageViewHeight: CGFloat = 80
    static let PageControlHeight: CGFloat = 40
    static let UnderlineHeight: CGFloat = 2
  }
  
  private let userSession: UserSession
  private let httpClient: HttpClient
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("This class does not support NSCoder")
  }
  
  init(userSession: UserSession, httpClient: HttpClient) {
    self.userSession = userSession
    self.httpClient = httpClient
    super.init(nibName: nil, bundle: nil)
  }
  
  private var viewControllers: [UIViewController] = []
  private let titles: [String] = MainFollowList.allCases.map { $0.rawValue }
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemBackground
    setupHeadingView()
    setupPageControl()
    setupScrollView()
    addChildViewControllers()
    
    nameLabel.font = .preferredFont(forTextStyle: .headline)
    nameLabel.text = userSession.currentUser?.name
    
    usernameLabel.font = .preferredFont(forTextStyle: .caption1)
    usernameLabel.text = userSession.currentUser?.username
    
    loadProfileImage()
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    profileImageView.layer.cornerRadius = profileImageView.bounds.height/2
    profileImageView.clipsToBounds = true
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
                                     titleColor: nil,
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
  
  private func addChildViewControllers() {
    for list in MainFollowList.allCases {
      let viewController = createViewController(withList: list)
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
  
  private func createViewController(withList list: MainFollowList) -> UIViewController {
    let viewController = UIViewController()
    viewController.view.backgroundColor = .systemBackground
    return viewController
  }
  
  @objc
  private func onCurrentIndexChange() {
    let currentIndex = CGFloat(pageControl.currentIndex)
    let pageWidth = scrollView.bounds.width
    let offsetX = currentIndex * pageWidth
    scrollView.contentOffset.x = offsetX
  }
  
  private func loadProfileImage() {
    profileImageView.image = UIImage(systemName: "person.circle")
    guard
      let profileImageURL = userSession.currentUser?.profileImageURL
    else {
      return
    }
    
    let request = URLRequest(url: profileImageURL)
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
