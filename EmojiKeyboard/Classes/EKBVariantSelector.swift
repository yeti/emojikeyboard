//
//  EKBVariantSelector.swift
//  GottaGo
//
//  Created by Lee McDole on 2/3/16.
//  Copyright © 2016 Yeti LLC. All rights reserved.
//

import Foundation

class EKBVariantSelector: UIView {
  
  // Outlets
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var defaultEmojiLabel: UILabel!
  @IBOutlet weak var variantEmoji1: UILabel!
  @IBOutlet weak var variantEmoji2: UILabel!
  @IBOutlet weak var variantEmoji3: UILabel!
  @IBOutlet weak var variantEmoji4: UILabel!
  @IBOutlet weak var variantEmoji5: UILabel!
  @IBOutlet weak var selectorTab: UIImageView!
  @IBOutlet weak var selectorTabCenterPos: NSLayoutConstraint!
  
  var variantEmojis: [UILabel]!
  var selectedBackgroundColor: UIColor!
  var unselectedBackgroundColor: UIColor!
  var currentEmoji: EKBEmoji?
  var emojiCenterXs: [CGFloat]!
  
  let targetPosOffsetY: CGFloat = 0
  
  let screenSize: CGRect = UIScreen.mainScreen().applicationFrame
  
  class func instanceFromNib() -> EKBVariantSelector {
    let nib = UINib(nibName: "EKBVariantSelector", bundle: NSBundle.mainBundle())
    return nib.instantiateWithOwner(nil, options: nil).first as! EKBVariantSelector
  }
  
  
  internal override func awakeFromNib() {
    variantEmojis = [UILabel]()
    variantEmojis.append(variantEmoji1)
    variantEmojis.append(variantEmoji2)
    variantEmojis.append(variantEmoji3)
    variantEmojis.append(variantEmoji4)
    variantEmojis.append(variantEmoji5)
    
    // Track the center points of the emoji labels so we can align them with the targetPos later
    emojiCenterXs = [CGFloat]()
    emojiCenterXs.append(defaultEmojiLabel.frame.origin.x + defaultEmojiLabel.frame.size.width / 2)
    
    defaultEmojiLabel.layer.cornerRadius = 3.0
    for variantEmoji in variantEmojis {
      // Round the corners
      variantEmoji.layer.cornerRadius = 4.0
      
      // Remember the position of the label
      emojiCenterXs.append(variantEmoji.frame.origin.x + variantEmoji.frame.size.width / 2)
    }
    
    // Container View
    containerView.layer.cornerRadius = 8.0
    containerView.layer.borderWidth = 1.0
    containerView.layer.borderColor = UIColor(red: 212.0/255, green: 212.0/255, blue: 212.0/255, alpha: 1.0).CGColor
    
    // Read selected and unselected colors from the IB elements
    selectedBackgroundColor = defaultEmojiLabel.backgroundColor
    unselectedBackgroundColor = variantEmoji1.backgroundColor
    
    // Initialize color for default emoji
    defaultEmojiLabel.backgroundColor = unselectedBackgroundColor
    
    // Bring the selector tab to the front, on top of our border
    bringSubviewToFront(selectorTab)
    
    // By default, don't display
    hidden = true
  }
  
  func displaySelection(emoji: EKBEmoji, targetPos: CGPoint) {
    currentEmoji = emoji
    defaultEmojiLabel.text = emoji.character
    
    for (index, modifier) in emoji.modifiers!.enumerate() {
      variantEmojis[index].text = emoji.character + modifier
    }
    
    if let index = currentEmoji?.modifierIndex {
      selectEmojiVariant(index)
    } else {
      selectDefaultEmoji()
    }
    
    updatePosition(targetPos)
    
    hidden = false
  }
  
  func hide() {
    hidden = true
    currentEmoji = nil
  }
  
  func updatePosition(targetPos: CGPoint) {
    /**
     * The goal here is to align the selector over the target position (the actual emoji button), 
     * with the following constraints:  
     * - a variant should be directly overhead of the button (not offset by a few pixels)
     * - prefer to center the variant selector over the target position
     * - if the button being pressed is near the edges of the screen, align to a different variant as
     *   necessary in order to keep the selector on screen
     * - ensure that no matter what, the entire selector is on screen
     */

    // Default to the midpoint of the possible emoji variants
    var alignmentIndex = emojiCenterXs.count / 2
    var newPosX = targetPos.x - emojiCenterXs[alignmentIndex]
    var newSelectorTabPosX = emojiCenterXs[alignmentIndex]
    
    // Test if we need to move selector to the right
    while newPosX < 0 {
      // This new position will put the variantSelector off the screen to the left.  Try a lower alignmentIndex
      if alignmentIndex == 0 {
        // We can't currently align this any further to the left, so put it on the edge
        newPosX = 0
        break
      }
      alignmentIndex--
      newPosX = targetPos.x - emojiCenterXs[alignmentIndex]
      newSelectorTabPosX = emojiCenterXs[alignmentIndex]
    }
    
    // Test if we need to move selector to the left
    while (newPosX + containerView.frame.size.width) > screenSize.width {
      if alignmentIndex == emojiCenterXs.count - 1 {
        // We can't currently align this any further to the right, so put it on the edge
        newPosX = screenSize.width - containerView.frame.width
        break
      }
      // This new position will put the variantSelector off the screen to the right.  Try a higher alignmentIndex
      alignmentIndex++
      newPosX = targetPos.x - emojiCenterXs[alignmentIndex]
      newSelectorTabPosX = emojiCenterXs[alignmentIndex]
    }
    
    // Assign the calculated position to the frame
    frame.origin = CGPoint(x: newPosX, y: targetPos.y + targetPosOffsetY)
    
    // Update our selector's position
    selectorTabCenterPos.constant = newSelectorTabPosX
  }
  
  func updateTouchPosition(relativePosition: CGPoint) {
    // Test for the ends being selected
    if relativePosition.x < variantEmojis[0].frame.origin.x {
      selectDefaultEmoji()
    } else if relativePosition.x > variantEmojis.last?.frame.origin.x {
      // Select last emoji
      selectEmojiVariant(variantEmojis.count-1)
    } else {
      // For all others, iterate through and test bounds
      for (index, variantEmoji) in variantEmojis.enumerate() {
        let emojiRightEdge = (variantEmoji.frame.origin.x + variantEmoji.frame.size.width)
        if relativePosition.x > variantEmoji.frame.origin.x  &&  relativePosition.x < emojiRightEdge {
          selectEmojiVariant(index)
        }
      }
    }
  }
  
  private func selectDefaultEmoji() {
    selectEmojiVariant(-1)
    defaultEmojiLabel.backgroundColor = selectedBackgroundColor
    currentEmoji?.clearModifier()
  }
  
  private func selectEmojiVariant(variantIndex: Int) {
    currentEmoji?.setModifierIndex(variantIndex)
    defaultEmojiLabel.backgroundColor = unselectedBackgroundColor
    for (index, variantEmoji) in variantEmojis.enumerate() {
      if index == variantIndex {
        variantEmoji.backgroundColor = selectedBackgroundColor
      } else {
        variantEmoji.backgroundColor = unselectedBackgroundColor
      }
    }
  }
}
