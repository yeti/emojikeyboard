//
//  EKBUtils.swift
//  Pods
//
//  Created by Lee McDole on 5/16/16.
//
//

import Foundation

class EKBUtils {

  class func resourceBundle() -> NSBundle? {
    let podBundle = NSBundle(forClass: EKBUtils.self)// NSBundle.mainBundle()
    if let bundleURL = podBundle.URLForResource("EmojiKeyboard", withExtension: "bundle") {
      if let bundle = NSBundle(URL: bundleURL) {
        return bundle
      } else {
        print("Failed to create bundle \(bundleURL)")
      }
    } else {
      print("Failed to load bundle EmojiKeybaord")
    }

    return nil
  }

}