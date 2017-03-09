//
//  Characteristic.swift
//  ShadowrunModel
//
//  Created by Christophe Laprun on 07/03/2017.
//  Copyright © 2017 Christophe Laprun. All rights reserved.
//

import Foundation

public typealias DicePool = UInt


struct Characteristic: Comparable, CustomDebugStringConvertible {
   private let _character: Shadowrunner
   private let _info: CharacteristicInfo
   private var _value: DicePool?

   init(named info: CharacteristicInfo, for character: Shadowrunner, with value: DicePool = 0) {
      self.init(named: info, for: character)
      _value = value
   }

   init(named info: CharacteristicInfo, for character: Shadowrunner) {
      _info = info
      _character = character
      _value = nil
   }

   var info: CharacteristicInfo {
      return _info
   }

   var character: Shadowrunner {
      return _character
   }

   private var value: DicePool? {
      return _value
   }

   var baseValue: DicePool {
      get {
         return info.baseValue(for: character, with: value)
      }
      set {
      }
   }

   var modifiedValue: DicePool {
      return info.modifiedValue(for: character, with: value)
   }

   var dicePool: DicePool {
      return info.dicePool(for: character, with: value)
   }

   var modifiers: [Modifier]? {
      return character.modifiers(for: info)
   }

   static func <(lhs: Characteristic, rhs: Characteristic) -> Bool {
      let lInfo = lhs.info
      let rInfo = rhs.info
      if (lInfo == rInfo) {
         return lhs.modifiedValue < rhs.modifiedValue
      } else {
         return lInfo < rInfo
      }
   }

   static func ==(lhs: Characteristic, rhs: Characteristic) -> Bool {
      return lhs.info == rhs.info && lhs.modifiedValue == rhs.modifiedValue
   }

   var debugDescription: String {
      return "\(info.debugDescription): \(modifiedValue)"
   }
}

struct CharacteristicGroup: Comparable {
   private let _order: Int
   private let _name: String
   private static var groups: [Int: CharacteristicGroup] = [:]

   static let physical = CharacteristicGroup(order: 1, name: "Physical")
   static let mental = CharacteristicGroup(order: 2, name: "Mental")
   static let derived = CharacteristicGroup(order: 3, name: "Derived")
   static let magic = CharacteristicGroup(order: 4, name: "Magic")
   static let matrix = CharacteristicGroup(order: 5, name: "Matrix")
   static let special = CharacteristicGroup(order: 6, name: "Special")

   init(order: Int, name: String) {
      _order = order
      _name = name
      let existing = CharacteristicGroup.groups[order]
      if existing == nil {
         CharacteristicGroup.groups[order] = self
      }
   }

   var name: String {
      get {
         return _name
      }
   }

   var order: Int {
      get {
         return _order
      }
   }

   static func <(lhs: CharacteristicGroup, rhs: CharacteristicGroup) -> Bool {
      return lhs._order < rhs._order
   }

   static func ==(lhs: CharacteristicGroup, rhs: CharacteristicGroup) -> Bool {
      return lhs._order == rhs._order
   }

}


class CharacteristicInfo: Hashable, CustomDebugStringConvertible, Comparable {

   enum CharacteristicType {
      case attribute, skill
   }

   private let _name: String
   private let _description: String
   private let _group: CharacteristicGroup

   init(name: String, description: String, group: CharacteristicGroup = .physical) {
      _name = name
      _description = description
      _group = group
   }

   var initialValue: DicePool {
      return 0
   }

   var name: String {
      return _name
   }

   var description: String {
      return _description
   }

   var group: CharacteristicGroup {
      return _group
   }

   var type: CharacteristicType {
      return .attribute
   }

   public var hashValue: Int {
      return _name.hashValue
   }

   var debugDescription: String {
      return "\(name)"
   }

   static func <(lhs: CharacteristicInfo, rhs: CharacteristicInfo) -> Bool {
      let equal = lhs.group == rhs.group
      if (equal) {
         return lhs.name < rhs.name
      } else {
         return lhs.group < rhs.group
      }
   }

   static func ==(lhs: CharacteristicInfo, rhs: CharacteristicInfo) -> Bool {
      return lhs.group == rhs.group && lhs.name == rhs.name
   }

   func baseValue(for character: Shadowrunner, with value: DicePool?) -> DicePool {
      return value ?? 0
   }


   func modifiedValue(for character: Shadowrunner, with value: DicePool?) -> DicePool {
      let baseValue = self.baseValue(for: character, with: value)

      guard let modifiers = character.modifiers(for: self) else {
         return baseValue
      }

      let result = modifiers.reduce(baseValue, { result, modifier in result + modifier.modifier })
      return result
   }

   func dicePool(for character: Shadowrunner, with value: DicePool?) -> DicePool {
      return modifiedValue(for: character, with: value)
   }
}

class AttributeInfo: CharacteristicInfo {
   var isDerived: Bool {
      return false
   }
}

class SimpleAttributeInfo: AttributeInfo {
   private let _initialValue: DicePool

   init(name: String, description: String, group: CharacteristicGroup = .physical, initialValue: DicePool = 0) {
      _initialValue = initialValue
      super.init(name: name, description: description, group: group)
   }

   override var initialValue: DicePool {
      return _initialValue
   }
}

class DerivedAttributeInfo: AttributeInfo {
   private let _first: AttributeInfo
   private let _second: AttributeInfo

   init(name: String, description: String, group: CharacteristicGroup = .physical, first: AttributeInfo, second: AttributeInfo) {
      _first = first
      _second = second

      super.init(name: name, description: description, group: group)
   }

   override var isDerived: Bool {
      return true
   }

   override var initialValue: DicePool {
      return first.initialValue + second.initialValue
   }

   var first: AttributeInfo {
      return _first
   }

   var second: AttributeInfo {
      return _second
   }

   override func baseValue(for character: Shadowrunner, with value: DicePool?) -> DicePool {
      return character.attribute(first).baseValue + character.attribute(second).baseValue
   }

   override func modifiedValue(for character: Shadowrunner, with value: DicePool?) -> DicePool {
      return character.attribute(first).modifiedValue + character.attribute(second).modifiedValue
   }
}

class SkillInfo: CharacteristicInfo {
   private let _attribute: AttributeInfo
   private let _canDefault: Bool

   init(name: String, description: String, group: CharacteristicGroup = .physical, linkedAttribute: AttributeInfo, canDefault: Bool = true) {
      _attribute = linkedAttribute
      _canDefault = canDefault
      super.init(name: name, description: description, group: group)
   }

   var linkedAttribute: AttributeInfo {
      return _attribute
   }

   var canDefault: Bool {
      return _canDefault
   }

   override var type: CharacteristicInfo.CharacteristicType {
      return .skill
   }

   override func dicePool(for character: Shadowrunner, with value: DicePool?) -> DicePool {
      return modifiedValue(for: character, with: value) + character.attribute(linkedAttribute).dicePool
   }

}
