//
//  RecipeListVM.swift
//  RecipeProject
//
//  Created by Teh Xiang Wei on 11/04/2021.
//

import Foundation
import RxCocoa
import RxSwift

class RecipeListVM: BaseViewModel, ViewModelType {
    
    let fileName = "recipetypes"
    let fileType = "xml"
    
    let recipeList: BehaviorRelay<[Recipe]> = .init(value: [])
    let recipeXmlList: BehaviorRelay<[RecipeXML]> = .init(value: [])
    var recipes = Array<RecipeXML>()
    var elementName: String = String()
    var mealName = String()
    var mealImage = String()
    var serveNumber = String()
    var ingredients = Array<IngredientsXML>()
    var directions = Array<DirectionsXML>()
    var adaptedFrom = String()
    var content = String()
    var remark = String()
        
    struct Input {
        let firstTrigger: Observable<Void>
    }
    
    struct Output {
        let recipeList: BehaviorRelay<[Recipe]>
    }
    
    func transform(input: RecipeListVM.Input) -> RecipeListVM.Output {
        
        recipeXmlList.subscribe(onNext: { [weak self] list in
            guard let `self` = self else { return }
            do {
                let jsonEncoder = JSONEncoder()
                let jsonData = try jsonEncoder.encode(list)
                let jsonString = String(data: jsonData, encoding: .utf8)
                
                if list.count > 0, let jsonString = jsonString {
                    Constant.setRecipe(jsonString)
//                    let checkSavedRecipe = Constant.getRecipe()
//                    print("jsonString: ", checkSavedRecipe)
                    
                    let jsonObj = try JSONSerialization.jsonObject(with: jsonData, options: [])
                    let jsonDataPretty = try JSONSerialization.data(withJSONObject: jsonObj, options: [.prettyPrinted])
                    print("*****JSON PRETTY PRINTED:*****")
                    print("\n")
                    print(String(data: jsonDataPretty, encoding: .utf8)!)
                    print("\n")
                    print("*****END OF PRETTY PRINTED*****")
                    
                    let decodedRecipes = try JSONDecoder().decode([Recipe].self, from: jsonData)
                    self.recipeList.accept(decodedRecipes)
                    
                }
                
            } catch {
                return
            }

        }).disposed(by: rx.disposeBag)
        
        input.firstTrigger.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            
            self.requestRecipeList()
            
        }).disposed(by: rx.disposeBag)
        
        return Output(recipeList: self.recipeList)
    }
}

//MARK: - Network
extension RecipeListVM: XMLParserDelegate {
    
    func requestRecipeList() {
        
        if Constant.keyExists(key: Constant.recipe) {
            let jsonString = Constant.getRecipe()
            do {
                let jsonData = Data(jsonString.utf8)
                let jsonObj = try JSONSerialization.jsonObject(with: jsonData, options: [])
                let jsonDataPretty = try JSONSerialization.data(withJSONObject: jsonObj, options: [.prettyPrinted])
                print("*****keyExists PRINTED:*****")
                print("\n")
                print(String(data: jsonDataPretty, encoding: .utf8)!)
                print("\n")
                print("*****END OF PRETTY PRINTED*****")
                
                let decodedRecipes = try JSONDecoder().decode([Recipe].self, from: jsonData)
                self.recipeList.accept(decodedRecipes)
                                
            } catch {
                return
            }
        } else {
            if let path = Bundle.main.url(forResource: fileName, withExtension: fileType) {
                if let parser = XMLParser(contentsOf: path) {
                    parser.delegate = self
                    parser.parse()
                }
            }
        }
        
    }
    
    // 1
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

        if elementName == Constant.recipe {
            mealName = String()
            mealImage = String()
            serveNumber = String()
            ingredients = Array<IngredientsXML>()
            directions = Array<DirectionsXML>()
            adaptedFrom = String()
        } else if elementName == Recipe.CodingKeys.ingredients.rawValue || elementName == Recipe.CodingKeys.directions.rawValue {
            content = String()
            remark = String()
        }

        self.elementName = elementName
    }

    // 2
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == Constant.recipe {
            
            let recipe = RecipeXML(mealName: mealName,
                                mealImage: mealImage,
                                serveNumber: Int(serveNumber),
                                ingredients: ingredients,
                                directions: directions,
                                adaptedFrom: adaptedFrom)
            recipes.append(recipe)
            
        } else if elementName == Recipe.CodingKeys.ingredients.rawValue {
            
            var ingredient = IngredientsXML()
            if !content.isEmpty {
                ingredient.content = content
            }
            if !remark.isEmpty {
                ingredient.remark = remark
            }
            ingredients.append(ingredient)
            
        } else if elementName == Recipe.CodingKeys.directions.rawValue {
            
            var direction = DirectionsXML()
            if !content.isEmpty {
                direction.content = content
            }
            if !remark.isEmpty {
                direction.remark = remark
            }
            directions.append(direction)
            
        }
        
        self.recipeXmlList.accept(recipes)
        
    }

    // 3
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if !data.isEmpty {
            if self.elementName == Recipe.CodingKeys.mealName.rawValue {
                mealName += data
            } else if self.elementName == Recipe.CodingKeys.mealImage.rawValue {
                mealImage += data
            } else if self.elementName == Recipe.CodingKeys.serveNumber.rawValue {
                serveNumber += data
            } else if self.elementName == Recipe.CodingKeys.adaptedFrom.rawValue {
                adaptedFrom += data
            } else if self.elementName == Ingredients.CodingKeys.content.rawValue {
                content += data
            } else if self.elementName == Ingredients.CodingKeys.remark.rawValue {
                remark += data
            } else if self.elementName == Directions.CodingKeys.content.rawValue {
                content += data
            } else if self.elementName == Directions.CodingKeys.remark.rawValue {
                remark += data
            }
        }
    }
    
}
