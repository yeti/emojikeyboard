//
//  EKBEmoji.swift
//  GottaGo
//
//  Created by Lee McDole on 1/31/16.
//  Copyright © 2016 Yeti LLC. All rights reserved.
//

import Foundation

public class EKBEmoji {
  var character: String
  var modifiers: [String]?
  var modifierIndex: Int?
  
  init(character: String, modifiers: [String]? = nil) {
    self.character = character
    self.modifiers = modifiers
  }
  
  func setModifierIndex(index: Int) {
    if index >= 0  &&  index < modifiers?.count {
      modifierIndex = index
    } else {
      modifierIndex = nil
    }
  }
  
  func clearModifier() {
    modifierIndex = nil
  }
  
  func getModifiedString() -> String {
    if let modifierIndex = modifierIndex {
      return character + modifiers![modifierIndex]
    }
    return character
  }
  
  func getModifierIndex() -> Int? {
    return modifierIndex
  }
}
