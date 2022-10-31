//
//  UIStoryboard+Extensions.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/31/22.
//

import UIKit

extension UIStoryboard {
  convenience init(storyboard: Storyboard) {
    self.init(name: storyboard.rawValue, bundle: nil)
  }
}
