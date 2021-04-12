//
//  EditViewController.swift
//  RecipeProject
//
//  Created by Teh Xiang Wei on 12/04/2021.
//

import UIKit

class EditViewController: UIViewController {
    
    @IBOutlet weak var tvContent: UITextView! {
        didSet {
            let toolBar = UIToolbar()
            toolBar.barStyle = UIBarStyle.default
            toolBar.isTranslucent = true
            toolBar.sizeToFit()
            let cancelBtn = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancel))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneContent))
            toolBar.setItems([cancelBtn, spaceButton, doneBtn], animated: false)
            self.tvContent.inputAccessoryView = toolBar
        }
    }
    @IBOutlet weak var tvRemark: UITextView! {
        didSet {
            let toolBar = UIToolbar()
            toolBar.barStyle = UIBarStyle.default
            toolBar.isTranslucent = true
            toolBar.sizeToFit()
            let cancelBtn = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancel))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneRemark))
            toolBar.setItems([cancelBtn, spaceButton, doneBtn], animated: false)
            self.tvRemark.inputAccessoryView = toolBar
        }
    }
    
    var ingredient: Ingredients?
    var direction: Directions?
    var idx: Int = 0
    var idxIngredient: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let ingredient = ingredient {
            self.tvContent.text = ingredient.content
            self.tvRemark.text = ingredient.remark
        } else if let direction = direction {
            self.tvContent.text = direction.content
            self.tvRemark.text = direction.remark
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tvContent.becomeFirstResponder()
        super.viewDidAppear(animated)
    }
    
    @IBAction func onSaveClicked(_ sender: Any) {
        
        if self.title == "Ingredient" {
            let ingredientXMLToSave = IngredientsXML(content: self.tvContent.text, remark: self.tvRemark.text)
            let jsonString = Constant.getRecipe()
            let jsonData = Data(jsonString.utf8)
            do {
                var decodedRecipes = try JSONDecoder().decode([Recipe].self, from: jsonData)
                let recipe = decodedRecipes[self.idx]
                if var ingredientList = recipe.ingredients {
                    let jsonEncoder = JSONEncoder()
                    let jsonData = try jsonEncoder.encode(ingredientXMLToSave)
                    let ingredientToAdd = try JSONDecoder().decode(Ingredients.self, from: jsonData)
                    ingredientList[self.idxIngredient] = ingredientToAdd
                    decodedRecipes[self.idx].ingredients = ingredientList
                }
                let jsonEncoder = JSONEncoder()
                let encodedJsonData = try jsonEncoder.encode(decodedRecipes)
                let encodedJsonStringg = String(data: encodedJsonData, encoding: .utf8) ?? ""
                Constant.setRecipe(encodedJsonStringg)
                self.navigationController?.popViewController(animated: true)
            } catch {
                return
            }
        } else if self.title == "Direction" {
            let ingredientXMLToSave = IngredientsXML(content: self.tvContent.text, remark: self.tvRemark.text)
            let jsonString = Constant.getRecipe()
            let jsonData = Data(jsonString.utf8)
            do {
                var decodedRecipes = try JSONDecoder().decode([Recipe].self, from: jsonData)
                let recipe = decodedRecipes[self.idx]
                if var directionList = recipe.directions {
                    let jsonEncoder = JSONEncoder()
                    let jsonData = try jsonEncoder.encode(ingredientXMLToSave)
                    let ingredientToAdd = try JSONDecoder().decode(Directions.self, from: jsonData)
                    directionList[self.idxIngredient] = ingredientToAdd
                    decodedRecipes[self.idx].directions = directionList
                }
                let jsonEncoder = JSONEncoder()
                let encodedJsonData = try jsonEncoder.encode(decodedRecipes)
                let encodedJsonStringg = String(data: encodedJsonData, encoding: .utf8) ?? ""
                Constant.setRecipe(encodedJsonStringg)
                self.navigationController?.popViewController(animated: true)
            } catch {
                return
            }
        }

    }

    @objc private func cancel() {
        self.view.endEditing(true)
    }
    
    @objc private func doneContent() {
        self.view.endEditing(true)
    }
    
    @objc private func doneRemark() {
        self.view.endEditing(true)
    }
    
}
