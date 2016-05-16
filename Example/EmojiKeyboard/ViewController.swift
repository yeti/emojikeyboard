//
//  ViewController.swift
//  EmojiKeyboard
//
//  Created by Lee McDole on 05/13/2016.
//  Copyright (c) 2016 Lee McDole. All rights reserved.
//

import UIKit
import EmojiKeyboard

class ViewController: UIViewController, UITextFieldDelegate, EKBDelegate {

  @IBOutlet weak var emojiTextField: UITextField!

  var emojiKeyboard: EKB!

  override func viewDidLoad() {
    super.viewDidLoad()

    // setup emoji text input
    emojiKeyboard = EKB()
    emojiKeyboard.ekbDelegate = self
    emojiTextField.delegate = self
    emojiTextField.inputView = emojiKeyboard.ekbInputView
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: EKBDelegate delegate functions
  func ekbButtonPressed(string: String) {

  }

}

