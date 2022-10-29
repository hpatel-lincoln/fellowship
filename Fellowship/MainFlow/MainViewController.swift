//
//  MainViewController.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/28/22.
//

import UIKit

enum FollowList: String, CaseIterable {
  case following = "Following"
  case followers = "Followers"
}

class MainViewController: UIViewController {
  
  struct Constants {
    static let UnderlineHeight: CGFloat = 2
    static let HeadingViewHeight: CGFloat = 188
    static let PageControlHeight: CGFloat = 40
    static let StandardMargin: CGFloat = 8
  }
  
  private var viewControllers: [UIViewController] = []
  private let titles: [String] = FollowList.allCases.map { $0.rawValue }
  private var maxHeadingTopOffset: CGFloat {
    Constants.HeadingViewHeight - Constants.PageControlHeight
  }
  
  private var headingView: UIView!
  private var headingViewTop = NSLayoutConstraint()
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
  }
  
  private func setupHeadingView() {
    headingView = UIView()
    view.addSubview(headingView)
    headingView.translatesAutoresizingMaskIntoConstraints = false
    headingViewTop = headingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
    
    let headingViewCon = [
      headingViewTop,
      headingView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      headingView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      headingView.heightAnchor.constraint(equalToConstant: Constants.HeadingViewHeight)
    ]
    NSLayoutConstraint.activate(headingViewCon)
  }
  
  private func setupPageControl() {
    let options = PageControlOptions(underlineHeight: Constants.UnderlineHeight,
                                     underlineColor: view.tintColor,
                                     titleFont: UIFont.preferredFont(forTextStyle: .headline),
                                     titleColor: view.tintColor,
                                     titles: titles)
    
    pageControl = PageControl(frame: .zero, options: options)
    headingView.addSubview(pageControl)
    pageControl.translatesAutoresizingMaskIntoConstraints = false
    pageControl.addTarget(self, action: #selector(onCurrentIndexChange), for: .valueChanged)
    
    let pageControlCon = [
      pageControl.centerXAnchor.constraint(equalTo: headingView.centerXAnchor),
      pageControl.widthAnchor.constraint(equalTo: headingView.widthAnchor, multiplier: 0.6),
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
    for list in FollowList.allCases {
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
  
  private func createViewController(withList list: FollowList) -> UIViewController {
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
