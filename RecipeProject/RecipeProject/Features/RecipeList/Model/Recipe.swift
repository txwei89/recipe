//
//  Recipe.swift
//  RecipeProject
//
//  Created by Teh Xiang Wei on 11/04/2021.
//

import Foundation

struct Recipe: Codable {

    var mealName: String?
    var mealImage: String?
    var serveNumber: Int?
    var ingredients: [Ingredients]?
    var directions: [Directions]?
    var adaptedFrom: String?
    
    var asDictionary : [String:Any] {
      let mirror = Mirror(reflecting: self)
      let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
        guard let label = label else { return nil }
        return (label, value)
      }).compactMap { $0 })
      return dict
    }

    enum CodingKeys: String, CodingKey {
        case mealName = "meal_name"
        case mealImage = "meal_image"
        case serveNumber = "serve_number"
        case ingredients = "ingredients"
        case directions = "directions"
        case adaptedFrom = "adapted_from"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        mealName = try? values.decode(String.self, forKey: .mealName)
        mealImage = try? values.decode(String.self, forKey: .mealImage)
        serveNumber = try? values.decode(Int.self, forKey: .serveNumber)
        ingredients = try? values.decode([Ingredients].self, forKey: .ingredients)
        directions = try? values.decode([Directions].self, forKey: .directions)
        adaptedFrom = try? values.decode(String.self, forKey: .adaptedFrom)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(mealName, forKey: .mealName)
        try? container.encode(mealImage, forKey: .mealImage)
        try? container.encode(serveNumber, forKey: .serveNumber)
        try? container.encode(ingredients, forKey: .ingredients)
        try? container.encode(directions, forKey: .directions)
        try? container.encode(adaptedFrom, forKey: .adaptedFrom)
    }
    
}

struct Ingredients: Codable {

    var content: String?
    var remark: String?

    enum CodingKeys: String, CodingKey {
        case content = "content"
        case remark = "remark"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        content = try? values.decode(String.self, forKey: .content)
        remark = try? values.decode(String.self, forKey: .remark)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(content, forKey: .content)
        try? container.encode(remark, forKey: .remark)
    }

}

struct Directions: Codable {

    var content: String?
    var remark: String?

    enum CodingKeys: String, CodingKey {
        case content = "content"
        case remark = "remark"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        content = try? values.decode(String.self, forKey: .content)
        remark = try? values.decode(String.self, forKey: .remark)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(content, forKey: .content)
        try? container.encode(remark, forKey: .remark)
    }

}


struct RecipeXML: Encodable {

    var mealName: String?
    var mealImage: String?
    var serveNumber: Int?
    var ingredients: [IngredientsXML]?
    var directions: [DirectionsXML]?
    var adaptedFrom: String?
    
    var asDictionary : [String:Any] {
      let mirror = Mirror(reflecting: self)
      let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
        guard let label = label else { return nil }
        return (label, value)
      }).compactMap { $0 })
      return dict
    }

    enum CodingKeys: String, CodingKey {
        case mealName = "meal_name"
        case mealImage = "meal_image"
        case serveNumber = "serve_number"
        case ingredients = "ingredients"
        case directions = "directions"
        case adaptedFrom = "adapted_from"
    }
    
}

struct IngredientsXML: Encodable {

    var content: String?
    var remark: String?

    enum CodingKeys: String, CodingKey {
        case content = "content"
        case remark = "remark"
    }

}

struct DirectionsXML: Encodable {

    var content: String?
    var remark: String?

    enum CodingKeys: String, CodingKey {
        case content = "content"
        case remark = "remark"
    }

}
