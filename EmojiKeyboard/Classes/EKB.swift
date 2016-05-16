//
//  EmojiKeyboard.swift
//  GottaGo
//
//  Created by Lee McDole on 1/30/16.
//  Copyright © 2016 Yeti LLC. All rights reserved.
//

import Foundation


public protocol EKBDelegate {
  func ekbButtonPressed(string: String)
}

public class EKB: NSObject, NSXMLParserDelegate, EKBInputViewDelegate {
  
  // Views
  public var ekbInputView: EKBInputView?
  
  // Emojis
  var emojiGroups: [EKBEmojiGroup]
  var currentEmojiGroup: EKBEmojiGroup?
  var modifiers = [String]()
  
  private let screenSize:CGRect = UIScreen.mainScreen().bounds
  public var ekbDelegate: EKBDelegate?
  
  
  ///////////////////////////
  // Initialization functions
  ///////////////////////////
  
  public override init() {
    emojiGroups = [EKBEmojiGroup]()
    currentEmojiGroup = nil
    
    super.init()
    
    processEmojiFile()
    
    // Setup Emoji Keyboard
    ekbInputView = UINib(nibName: "EKBInputView", bundle: EKBUtils.resourceBundle()).instantiateWithOwner(nil, options: nil)[0] as? EKBInputView
    ekbInputView!.ekbInputViewDelegate = self
    
    // Set our height
    ekbInputView?.autoresizingMask = .None
    ekbInputView?.frame = CGRectMake(0, 0, 0, 260)
  }
  
  private func processEmojiFile() {
    let filename = "EmojiList"
    var parser: NSXMLParser?
    if let bundle = EKBUtils.resourceBundle() {
      let path = bundle.pathForResource(filename, ofType: "xml")
      if let path = path {
        parser = NSXMLParser(contentsOfURL: NSURL(fileURLWithPath: path))
      }
    } else {
      print("Failed to find emoji list file")
    }
    
    if let parser = parser {
      // Let's parse that xml!
      parser.delegate = self
      if !parser.parse() {
        let parseError = parser.parserError!
        print("Error parsing emoji list: \(parseError)")
      }
      
      if currentEmojiGroup != nil {
        print("XML appeared malformed, an unclosed EmojiGroup was found")
      }
    }
  }
  
  func printEmojiListInfo() {
    var emojiCount = 0
    for group in emojiGroups {
      emojiCount += group.emojis.count
    }
    
    print("Finished parsing EmojiList.  Found \(emojiGroups.count) groups containing \(emojiCount) emojis")
    print("Group Name  Emoji Count")
    var modifiableCount = 0
    for group in emojiGroups {
      print("\(group.name)  \(group.emojis.count)")
      for emoji in group.emojis {
        if emoji.modifiers != nil {
          modifiableCount++
        }
      }
    }
    print("Total with modifiers: \(modifiableCount)")
  }
  
  
  /////////////////////////////////////////
  // NSXMLParserDelegate protocol functions
  /////////////////////////////////////////
  
  @objc public func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?,
    qualifiedName qName: String?, attributes attributeDict: [String : String])
  {
    if elementName == "EmojiModifier" {
      loadEmojiModifier(elementName, attributeDict: attributeDict)
    } else if elementName == "EmojiGroup" {
      if currentEmojiGroup != nil {
        print("Unexpected new EmojiGroup found while parsing EmojiGroup")
      }
      currentEmojiGroup = EKBEmojiGroup(name: attributeDict["name"]!)
    } else if elementName == "Emoji" {
      loadEmoji(elementName, attributeDict: attributeDict)
    }
  }
  
  @objc public func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?,
    qualifiedName qName: String?)
  {
    if elementName == "EmojiGroup" {
      if currentEmojiGroup == nil {
        print("Unexpected end of EmojiGroup found")
      }
      emojiGroups.append(currentEmojiGroup!)
      currentEmojiGroup = nil
    }
  }
  
  
  ///////////////////////////////
  // XML Parsing Helper Functions
  ///////////////////////////////
  
  private func loadEmojiModifier(elementName: String, attributeDict: [String : String]) {
    let unicode = attributeDict["unicode"]
    let emoji = attributeDict["emoji"]
    
    verifyUnicodeEmojiMatch(unicode!, emoji: emoji!)
    
    let newEmojiModifier = String(emoji!)
    modifiers.append(newEmojiModifier)
  }
  
  private func loadEmoji(elementName: String, attributeDict: [String : String]) {
    let unicode = attributeDict["unicode"]
    let emoji = attributeDict["emoji"]
    
    // Check if this emoji is even supported
    let minVersion = attributeDict["minversion"] ?? ""
    if !versionCheck(minVersion) {
      return
    }
    
    verifyUnicodeEmojiMatch(unicode!, emoji: emoji!)
    
    // Check if modifications are supported
    var modifiable = false
    let modifiableVersion = attributeDict["modifiableversion"] ?? "false"
    if modifiableVersion != "false" {
      // Might be modifiable.  Check version
      if versionCheck(modifiableVersion) {
        modifiable = true
      }
    }
    
    let newEmoji = EKBEmoji(character: emoji!, modifiers: (modifiable) ? modifiers : nil)
    currentEmojiGroup!.appendEmoji(newEmoji)
  }
  
  private func versionCheck(minVersion: String) -> Bool {
    var versionReqs: [Int] = minVersion.characters.split{$0 == "."}.map(String.init).map{Int($0)!}  // Clean this up?
    
    while versionReqs.count < 3 {
      // Turn "8" and "8.0" into "8.0.0", for example
      versionReqs.append(0)
    }
    
    let os = NSProcessInfo().operatingSystemVersion
    
    // TODO: Maybe a more functional approach to solving this problem:
    
    // Check major version
    if versionReqs[0] < os.majorVersion {
      return true
    } else if versionReqs[0] > os.majorVersion {
      return false
    }
    // Major version == requirement, must dig deeper
    
    // Check minor version
    if versionReqs[1] < os.minorVersion {
      return true
    } else if versionReqs[1] > os.minorVersion {
      return false
    }
    // Minor version == requirement, must dig deeper
    
    // Check patch version
    if versionReqs[2] < os.patchVersion {
      return true
    } else if versionReqs[2] > os.patchVersion {
      return false
    }
    // Major, Minor, and Patch version == requirement.  We're good!
    return true
  }
  
  private func verifyUnicodeEmojiMatch(unicode: String, emoji: String) -> Bool {
    // Verify that the displayed emoji and the unicode value match
    let unicodeStrings = unicode.characters.split{$0 == " "}.map(String.init)
    
    var unicodeCharacters = [Character]()
    for string in unicodeStrings {
      // Convert unicodeStrings -> Ints -> UnicodeScalars -> Characters
      let unicodeInt = Int(string, radix: 16)
      unicodeCharacters.append(Character(UnicodeScalar(unicodeInt!)))
    }
    
    let unicodeEmoji = String(unicodeCharacters)
    
    if unicodeEmoji != emoji {
      print("Mismatched unicode and emoji values: \(unicode) \(emoji)")
      return false
    }
    return true
  }
  
  
  //////////////////////////////////////////
  // EKBInputViewDelegate protocol functions
  //////////////////////////////////////////
  
  // Action handler for whenever a button is pressed.  Probably want to send a character to the UIResponder
  public func buttonPressed(groupIndex: Int, index: Int) {
    let emoji: String = emojiGroups[groupIndex].emojis[index].getModifiedString()
    ekbDelegate?.ekbButtonPressed(emoji)
  }
  
  // Return the number of groups in this keyboard
  public func getGroupCount() -> Int {
    return emojiGroups.count
  }
  
  // Return the name of the specified group
  public func getGroupName(groupIndex: Int) -> String {
    if groupIndex >= 0  &&  groupIndex < emojiGroups.count {
      return emojiGroups[groupIndex].name
    }
    return ""
  }
  
  // Return the number of items within this group
  public func getItemCount(groupIndex: Int) -> Int {
    if groupIndex >= 0  &&  groupIndex < emojiGroups.count {
      return emojiGroups[groupIndex].emojis.count
    }
    return 0
  }
  
  // Get the emoji for a specified group and index
  public func getEmojiAt(groupIndex: Int, index: Int) -> EKBEmoji? {
    if groupIndex >= 0  &&  groupIndex < emojiGroups.count {
      if index >= 0  &&  index < emojiGroups[groupIndex].emojis.count {
        return emojiGroups[groupIndex].emojis[index]
      }
    }
    return nil
  }
}



