//
//  Constant.swift
//  RecipeProject
//
//  Created by Teh Xiang Wei on 11/04/2021.
//

import Foundation

struct Constant {
    static let recipe = "recipe"
    
    static func keyExists(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    static func setRecipe(_ jsonString: String) {
        UserDefaults.standard.setValue(jsonString, forKey: self.recipe)
        UserDefaults.standard.synchronize()
    }
    
    static func getRecipe() -> String {
        let value = UserDefaults.standard.string(forKey: self.recipe)
        return value ?? ""
    }
}
