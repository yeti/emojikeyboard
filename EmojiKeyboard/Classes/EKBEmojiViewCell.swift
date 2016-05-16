//
//  EKBEmojiViewCell.swift
//  GottaGo
//
//  Created by Lee McDole on 1/30/16.
//  Copyright © 2016 Yeti LLC. All rights reserved.
//

import Foundation

public class EKBEmojiViewCell: UICollectionViewCell {
  
  @IBOutlet weak var emojiLabel: UILabel!
  
  public override func awakeFromNib() {
  }
  
  func setEmoji(emoji: String) {
    emojiLabel.text = emoji
  }
  
}