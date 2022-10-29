//
//  PageControl.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/28/22.
//

import UIKit

struct PageControlOptions {
  var underlineHeight: CGFloat
  var underlineColor: UIColor?
  var titleFont: UIFont?
  var titleColor: UIColor?
  var titles: [String]
}

class PageControl: UIControl {
  
  // Properties
  var currentIndex: Int = 0 {
    didSet {
      currentIndex = max(min(titles.count-1, currentIndex), 0)
    }
  }
  
  private var firstRun: Bool = true
  private var underlineHeight: CGFloat
  private var underlineColor: UIColor?
  private var titleFont: UIFont?
  private var titleColor: UIColor?
  private var titles: [String]
  
  // Views
  private var stackView: UIStackView!
  private var underline: UIView!
  
  init(frame: CGRect, options: PageControlOptions) {
    underlineHeight = options.underlineHeight
    underlineColor = options.underlineColor
    titleFont = options.titleFont
    titleColor = options.titleColor
    titles = options.titles
    super.init(frame: frame)
    initView()
  }
  
  // When the view is initialized from a Nib
  required init?(coder: NSCoder) {
    fatalError("\(PageControl.self): init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if firstRun && titles.isEmpty == false {
      stackView.layoutIfNeeded()
      positionUnderline(toIndex: currentIndex)
      firstRun = false
    }
  }
  
  func userDidScroll(toPercent percent: CGFloat) {
    let currentWidth = getWidth(forIndex: currentIndex)
    var toWidth: CGFloat = 0
    
    let currentX = getX(forIndex: currentIndex)
    var toX: CGFloat = 0
    
    // Moving to previous index
    if percent < 0 {
      if currentIndex == 0 { return }
      toWidth = getWidth(forIndex: currentIndex-1)
      toX = getX(forIndex: currentIndex-1)
    } else {
      if currentIndex == titles.count-1 { return }
      toWidth = getWidth(forIndex: currentIndex+1)
      toX = getX(forIndex: currentIndex+1)
    }
    
    // Calculate width
    let deltaWidth = (toWidth - currentWidth) * abs(percent)
    let newWidth = currentWidth + deltaWidth
    
    let deltaX = (toX - currentX) * abs(percent)
    let newX = currentX + deltaX
    
    positionUnderline(toX: newX, width: newWidth)
  }
  
  private func initView() {
    stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .horizontal
    stackView.distribution = .equalSpacing
    stackView.alignment = .center
    addSubview(stackView)
    
    let stackViewConstraints = [
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      stackView.topAnchor.constraint(equalTo: topAnchor),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ]
    NSLayoutConstraint.activate(stackViewConstraints)
    
    underline = UIView()
    underline.translatesAutoresizingMaskIntoConstraints = false
    underline.backgroundColor = underlineColor
    addSubview(underline)
    
    addButtons()
  }
  
  private func addButtons() {
    guard titles.count > 0 else { return }
    
    for (index, title) in titles.enumerated() {
      let button = UIButton(type: .custom)
      button.titleLabel?.font = titleFont
      button.titleLabel?.numberOfLines = 1
      button.setTitle(title, for: .normal)
      button.setTitleColor(titleColor, for: .normal)
      button.addTarget(self, action: #selector(onButtonTap(sender:)), for: .touchUpInside)
      button.tag = index
      stackView.addArrangedSubview(button)
    }
  }
  
  @objc private func onButtonTap(sender: UIButton) {
    let index = sender.tag
    currentIndex = index
    positionUnderline(toIndex: index)
    sendActions(for: .valueChanged)
  }
  
  private func positionUnderline(toIndex index: Int) {
    let width = getWidth(forIndex: index)
    let x = getX(forIndex: index)
    positionUnderline(toX: x, width: width)
  }
  
  private func positionUnderline(toX x: CGFloat, width: CGFloat) {
    underline.frame = CGRect(x: x, y: bounds.height-underlineHeight, width: width, height: underlineHeight)
  }
  
  private func getX(forIndex index: Int) -> CGFloat {
    let x = stackView.arrangedSubviews[index].frame.origin.x
    return x
  }
  
  private func getWidth(forIndex index: Int) -> CGFloat {
    return stackView.arrangedSubviews[index].frame.width
  }
}
