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
   private var _attributes: [BaseAttributeInfo: Characteristic<BaseAttributeInfo>]
   
   init(named: String) {
      
      self._name = named
      self._modifiers = [CharacteristicInfo: [Modifier]]()
      self._attributes = [BaseAttributeInfo: Characteristic]()
      
      let info = SimpleAttributeInfo(name: "foo", description: "foo")
      _attributes[info] = Characteristic(named: info, for: self)
   }

   func modifiers(for info: CharacteristicInfo) -> [Modifier]? {
      return _modifiers[info]
   }
   
   func attribute(_ info: BaseAttributeInfo) -> Characteristic<BaseAttributeInfo> {
      guard let attribute = _attributes[info] else {
         let info = SimpleAttributeInfo(name: info.name, description: info.description, group: info.group, initialValue: info.initialValue)
         return Characteristic(named: info, for: self, with: info.initialValue)
      }
      
      return attribute
   }
   
   var name: String {
      return _name
   }

   static func ==(lhs: Shadowrunner, rhs: Shadowrunner) -> Bool {
      return lhs.name == rhs.name
   }
}
