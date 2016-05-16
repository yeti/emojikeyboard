//
//  EKBCollectionView.swift
//  GottaGo
//
//  Created by Lee McDole on 2/3/16.
//  Copyright © 2016 Yeti LLC. All rights reserved.
//

import Foundation


/** 
 * EKBCollectionView extends UICollectionView so that we can pass touch events to the nextResponder,
 * which in our case is the EKBInputView.  This enables EKBInputView to properly display and update the
 * EKBVariantSelector and it's selected variant as the user moves their touch around the screen.
 * We also take this opportunity to disable scrolling when touches are moving around.
 */
class EKBCollectionView: UICollectionView {
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)
    self.scrollEnabled = false
    nextResponder()?.touchesBegan(touches, withEvent: event)
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesMoved(touches, withEvent: event)
    nextResponder()?.touchesMoved(touches, withEvent: event)
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesEnded(touches, withEvent: event)
    self.scrollEnabled = true
    nextResponder()?.touchesEnded(touches, withEvent: event)
  }  
}
