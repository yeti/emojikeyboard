//
//  EKBEmojiGroup.swift
//  GottaGo
//
//  Created by Lee McDole on 1/31/16.
//  Copyright © 2016 Yeti LLC. All rights reserved.
//

import Foundation

class EKBEmojiGroup {
  var name: String!
  var emojis: [EKBEmoji]
  
  init(name: String) {
    emojis = [EKBEmoji]()
    self.name = name
  }
  
  func appendEmoji(newEmoji: EKBEmoji) {
    emojis.append(newEmoji)
  }
}