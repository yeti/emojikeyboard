//
//  EKBInputView.swift
//  GottaGo
//
//  Created by Lee McDole on 1/25/16.
//  Copyright © 2016 Yeti LLC. All rights reserved.
//

import Foundation
import UIKit


public protocol EKBInputViewDelegate {
  // Action handler for whenever a button is pressed.  Probably want to send a character to the UIResponder
  func buttonPressed(groupIndex: Int, index: Int)
  
  // Return the number of groups in this keyboard
  func getGroupCount() -> Int
  
  // Return the name of the specified group
  func getGroupName(groupIndex: Int) -> String
  
  // Return the number of items within this group
  func getItemCount(groupIndex: Int) -> Int
  
  // Get the emoji for a specified group and index
  func getEmojiAt(groupIndex: Int, index: Int) -> EKBEmoji?
}


public class EKBInputView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
  
  // UI Outlets
  @IBOutlet weak var collectionView: UICollectionView!
  
  var variantSelector: EKBVariantSelector!
  @IBOutlet weak var groupButton1: UIButton!
  @IBOutlet weak var groupButton2: UIButton!
  @IBOutlet weak var groupButton3: UIButton!
  @IBOutlet weak var groupButton4: UIButton!
  @IBOutlet weak var groupButton5: UIButton!
  @IBOutlet weak var groupButton6: UIButton!
  @IBOutlet weak var groupButton7: UIButton!
  @IBOutlet weak var groupButton8: UIButton!
  @IBOutlet weak var groupButtonsContainer: UIView!
  
  var highlightCircle: UIView!
  let highlightCircleExtraSize = CGFloat(0.0) // size per side, total extra is 2x this! (placeholder in case we want non-zero extra)
  
  var groupButtons: [UIButton]!
  var currentScrollGroup: Int! = 0
  
  
  var ekbInputViewDelegate: EKBInputViewDelegate?
  var currentEmojiSection: Int?
  var currentEmojiIndex: Int?
  
  let edgeOffsetX: CGFloat = 10
  let edgeOffsetY: CGFloat = 6
  
  
  // GroupHeader encapsulates the information we need to maintain our headers
  private struct GroupHeader {
    var label: UILabel
    var minX: CGFloat
    var maxX: CGFloat
  }
  private var groupHeaders = [GroupHeader]()
  
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override func awakeFromNib() {
    collectionView.delegate = self
    collectionView.dataSource = self
    
    autoresizingMask = .None;
    
    let cellNib = UINib(nibName: "EKBEmojiViewCell", bundle: EKBUtils.resourceBundle())
    collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "EKBEmojiViewCell")
    
    variantSelector = EKBVariantSelector.instanceFromNib()
    addSubview(variantSelector)
    variantSelector.hidden = true
    
    groupButtons = [UIButton]()
    groupButtons.append(groupButton1)
    groupButtons.append(groupButton2)
    groupButtons.append(groupButton3)
    groupButtons.append(groupButton4)
    groupButtons.append(groupButton5)
    groupButtons.append(groupButton6)
    groupButtons.append(groupButton7)
    groupButtons.append(groupButton8)
    
    // Initialize group button highlighter
    let buttonSize = groupButton1.frame.size.width
    let highlightSize = buttonSize + highlightCircleExtraSize * 2  // *2 to include extra on both sides
    highlightCircle = UIView(frame: CGRectMake(groupButton1.frame.origin.x - highlightCircleExtraSize,
                                               groupButton1.frame.origin.y - highlightCircleExtraSize,
                                               highlightSize,
                                               highlightSize))
    highlightCircle.layer.cornerRadius = highlightSize / 2.0  // /2 to make it a perfect circle
    highlightCircle.backgroundColor = UIColor.darkGrayColor()
    highlightCircle.alpha = 0.16
    groupButtonsContainer.addSubview(highlightCircle)
    setSelectedButton(0)
  }
  
  
  ///////////////////
  // UIView Overrides
  ///////////////////
  
  override public func layoutMarginsDidChange() {
    
    let groupCount = (ekbInputViewDelegate?.getGroupCount())!
    for var index = 0; index < groupCount; ++index {
      
      // Create UILabel
      let label = UILabel(frame: CGRectMake(0, 0, CGFloat.max, 20))  // CGFloat.max so that we guarantee we only shrink the label
      label.textAlignment = .Left
      label.font = UIFont.systemFontOfSize(13, weight: UIFontWeightMedium)
      label.text = ekbInputViewDelegate!.getGroupName(index)
      label.textColor = UIColor(red: 160.0/255, green: 160.0/255, blue: 160.0/255, alpha: 255.0/255)
      
      // This ensures our UILabel's width fits our text snugly, so the UILabel scrolls out at the correct location.
      label.numberOfLines = 0
      label.sizeToFit()
      
      // Label is now configured.  Calculate its drawing bounds
      let firstItemIndexPath = NSIndexPath(forItem: 0, inSection: index)
      let firstElementAttributes = collectionView.layoutAttributesForItemAtIndexPath(firstItemIndexPath)
      let minX = (firstElementAttributes?.frame.origin.x)! + edgeOffsetX
      
      let lastItemIndexPath = NSIndexPath(forItem: (ekbInputViewDelegate?.getItemCount(index))! - 1, inSection: index)
      let lastElementAttributes = collectionView.layoutAttributesForItemAtIndexPath(lastItemIndexPath)
      let maxX = (lastElementAttributes?.frame.origin.x)! + (lastElementAttributes?.frame.width)! - label.frame.width - edgeOffsetX
      
      // Initialize the bounds to starting position
      var bounds: CGRect = label.bounds
      bounds.origin.x = minX
      bounds.origin.y = edgeOffsetY
      label.bounds = bounds
      
      // Create GroupHeader, add label as subview
      let header = GroupHeader(label: label, minX: minX, maxX: maxX)
      groupHeaders.append(header)
      self.addSubview(label)
    }
    
    // Put all the headers in their proper locations
    updateHeaderOffsets()
  }
  
  
  ////////////////////////////////////////////////
  // UICollectionViewDataSource protocol functions
  ////////////////////////////////////////////////
  
  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return (ekbInputViewDelegate?.getItemCount(section))!
  }
  
  public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return (ekbInputViewDelegate?.getGroupCount())!
  }
  
  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EKBEmojiViewCell", forIndexPath: indexPath) as! EKBEmojiViewCell
    
    let index = indexPath.row
    let groupIndex = indexPath.section
    let emoji = ekbInputViewDelegate?.getEmojiAt(groupIndex, index: index)
    
    cell.setEmoji(emoji!.getModifiedString())
    
    return cell
  }
  
  
  //////////////////////////////////////////////
  // UICollectionViewDelegate protocol functions
  //////////////////////////////////////////////
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
      return CGSizeMake(collectionView.frame.width / 8, collectionView.frame.height / 5)
  }

    
  //////////////////////////////////////////
  // UIScrollViewDelegate protocol functions
  //////////////////////////////////////////
  
  public func scrollViewDidScroll(scrollView: UIScrollView) {
    updateHeaderOffsets()
  }
  
  private func updateHeaderOffsets() {
    let offset = collectionView.contentOffset
    for (index, header) in groupHeaders.enumerate() {
      // Desired position is at offset.x + edgeOffsetX if possible
      var xPos = offset.x + edgeOffsetX
      
      // Clamp to max/min limits
      var clamped = false
      if xPos < header.minX {
        xPos = header.minX
        clamped = true
      } else if xPos > header.maxX {
        xPos = header.maxX
        clamped = true
      }
      
      if !clamped  &&  currentScrollGroup != index {
        // Ensure that the current group is reflected in the buttons at the bottom
        setSelectedButton(index)
      }
      
      // Translate back to screen coordinates
      var frame = header.label.frame
      frame.origin.x = xPos - offset.x
      frame.origin.y = edgeOffsetY
      header.label.frame = frame
    }
  }
  
  
  public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    let touch = touches[touches.startIndex]
    let location: CGPoint = touch.locationInView(collectionView)
    let indexPath = collectionView.indexPathForItemAtPoint(location)
    
    if let indexPath = indexPath {
      currentEmojiSection = indexPath.section
      currentEmojiIndex = indexPath.row
      let emoji = ekbInputViewDelegate?.getEmojiAt(currentEmojiSection!, index: currentEmojiIndex!)
      
      // TODO:  Possibly make the EKBVariantSelector support displaying even when there is no modifiers. For now, only if modifiers.
      
      if emoji?.modifiers?.count > 1 {
        // Calculate the ideal position for the selector to draw (horizontally centered, top of the current indexPath)
        let layoutAttributes = collectionView.layoutAttributesForItemAtIndexPath(indexPath)
        let targetX = (layoutAttributes?.frame.origin.x)!
                      + ((layoutAttributes?.size.width)! / 2)
                      - collectionView.contentOffset.x
        let targetY = (layoutAttributes?.frame.origin.y)!
                      - (layoutAttributes?.size.height)!
        let targetPos = CGPoint(x: targetX, y: targetY)
        
        bringSubviewToFront(variantSelector)
        variantSelector.displaySelection(emoji!, targetPos: targetPos)
      }
    }
  }
  
  override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    let touch = touches[touches.startIndex]
    
    // Pass moves to variantSelector if it's active
    if !variantSelector.hidden {
      variantSelector.updateTouchPosition(touch.locationInView(variantSelector))
    }
  }
  
  override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    if let emojiIndex = currentEmojiIndex, let emojiSection = currentEmojiSection {
      let indexPath = NSIndexPath(forItem: emojiIndex, inSection: emojiSection)
      collectionView.reloadItemsAtIndexPaths([indexPath])
      ekbInputViewDelegate?.buttonPressed(indexPath.section, index: indexPath.row)
      
      // Clear bookkeeping info
      currentEmojiIndex = nil
      currentEmojiSection = nil
      
      // Hide selector
      variantSelector.hide()
    }
  }
  
  func scrollToGroup(index: Int) {
    let indexPath = NSIndexPath(forItem: 0, inSection: index)
    let layoutAttributes = collectionView.layoutAttributesForItemAtIndexPath(indexPath)
    let offsetPosX = layoutAttributes!.frame.origin.x
    
    var contentOffset = collectionView.contentOffset
    contentOffset.x = offsetPosX
    collectionView.contentOffset = contentOffset
  }
  
  func setSelectedButton(selectedIndex: Int) {
    for (index, button) in groupButtons.enumerate() {
      if index == selectedIndex {
        button.selected = true
        button.alpha = 1.0
        setButtonHighlight(index)
      } else {
        button.selected = false
        button.alpha = 0.4
      }
    }
    currentScrollGroup = selectedIndex
  }
  
  func setButtonHighlight(selectedIndex: Int) {
    highlightCircle.frame.origin.x = groupButtons[selectedIndex].frame.origin.x - highlightCircleExtraSize
    highlightCircle.frame.origin.y = groupButtons[selectedIndex].frame.origin.y - highlightCircleExtraSize
  }
  
  // TODO: A less ugly way to map button presses to these functions!
  @IBAction func button1Touched(sender: AnyObject) {
    scrollToGroup(0)
    setSelectedButton(0)
  }
  @IBAction func button2Touched(sender: AnyObject) {
    scrollToGroup(1)
    setSelectedButton(1)
  }
  @IBAction func button3Touched(sender: AnyObject) {
    scrollToGroup(2)
    setSelectedButton(2)
  }
  @IBAction func button4Touched(sender: AnyObject) {
    scrollToGroup(3)
    setSelectedButton(3)
  }
  @IBAction func button5Touched(sender: AnyObject) {
    scrollToGroup(4)
    setSelectedButton(4)
  }
  @IBAction func button6Touched(sender: AnyObject) {
    scrollToGroup(5)
    setSelectedButton(5)
  }
  @IBAction func button7Touched(sender: AnyObject) {
    scrollToGroup(6)
    setSelectedButton(6)
  }
  @IBAction func button8Touched(sender: AnyObject) {
    scrollToGroup(7)
    setSelectedButton(7)
  }
  
}



