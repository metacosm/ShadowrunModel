//
//  Shadowrunner.swift
//  ShadowrunModel
//
//  Created by Christophe Laprun on 07/03/2017.
//  Copyright © 2017 Christophe Laprun. All rights reserved.
//

import Foundation

struct Modifier {
   init(value: DicePool) {
      self.init(name: "modifier", value: value)
   }

   init(name: String, value: DicePool) {
      self.name = name
      self.modifier = value
   }

   let name: String
   var modifier: DicePool
   var modifierAsString: String {
      get {
         return modifier > 0 ? "+\(modifier)" : "\(modifier)"
      }
   }
}

struct Shadowrunner: Equatable {
   private var _realName: String?
   private let _name: String
   private var _modifiers: [CharacteristicInfo: [Modifier]]
   private var _attributes: [AttributeInfo: Characteristic]
   private var _skills: [SkillInfo: Characteristic]
   private var _characteristics: [CharacteristicInfo: Characteristic]

   init(named: String) {

      self._name = named
      self._modifiers = [CharacteristicInfo: [Modifier]]()
      self._attributes = [AttributeInfo: Characteristic]()
      self._skills = [SkillInfo: Characteristic]()
      self._characteristics = [CharacteristicInfo: Characteristic]()
   }

   func modifiers(for info: CharacteristicInfo) -> [Modifier]? {
      return _modifiers[info]
   }

   func attribute(_ info: AttributeInfo) -> Characteristic {
      guard let attribute = _attributes[info] else {
         return Characteristic(named: info, for: self, with: info.initialValue)
      }

      return attribute
   }

   var characteristics: [Characteristic] {
      return getNonNullCharacteristics(from: _characteristics)
   }

   private func getNonNullCharacteristics<T:CharacteristicInfo>(from characteristics: [T: Characteristic]) -> [Characteristic] {
      return characteristics.map {
         $0.value
      }.filter {
         $0.modifiedValue > 0
      }.sorted()
   }


   var attributes: [Characteristic] {
      return getNonNullCharacteristics(from: _attributes)
   }

   var attributesCount: Int {
      return attributes.count
   }

   var skills: [Characteristic] {
      return getNonNullCharacteristics(from: _skills)
   }

   var skillsCount: Int {
      return skills.count
   }

   mutating func setCharacteristic(_ info: CharacteristicInfo, at value: DicePool) {
      let characteristic = Characteristic(named: info, for: self, with: value)
      _characteristics[info] = characteristic
      if (info is AttributeInfo) {
         _attributes[info as! AttributeInfo] = characteristic
      } else if (info is SkillInfo) {
         _skills[info as! SkillInfo] = characteristic
      }
   }

   func dicePool(for info: CharacteristicInfo) -> DicePool {
      guard let characteristic = _characteristics[info] else {
         return Characteristic(named: info, for: self, with: info.initialValue).dicePool
      }

      return characteristic.dicePool
   }

   func characteristic(_ info: CharacteristicInfo) -> Characteristic {
      guard let characteristic = _characteristics[info] else {
         return Characteristic(named: info, for: self, with: info.initialValue)
      }
      return characteristic
   }

   mutating func setModifier(for info: CharacteristicInfo?, at modifier: Modifier) {
      guard let info = info else {
         return
      }

      if var currentModifiers = _modifiers[info] {
         currentModifiers.append(modifier)
         _modifiers[info] = currentModifiers
      } else {
         _modifiers[info] = [modifier]
      }
   }

   var name: String {
      return _name
   }

   static func ==(lhs: Shadowrunner, rhs: Shadowrunner) -> Bool {
      return lhs.name == rhs.name
   }

}
