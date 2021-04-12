//
//  DirectionTableViewController.swift
//  RecipeProject
//
//  Created by Teh Xiang Wei on 12/04/2021.
//

import UIKit

class DirectionTableViewController: UITableViewController {

    private var directionList: Array<Directions> = []
    var idx: Int = 0
    var idxDirection: Int = 0
    private let cellIdentifier = "cellIdentifier"
    private let editDirectiondentifier = "editDirection"
    private var selectedDirection: Directions?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.makeUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.retrieveData()
        super.viewDidAppear(animated)
    }
    
    private func retrieveData() {
        let jsonString = Constant.getRecipe()
        let jsonData = Data(jsonString.utf8)
        do {
            let decodedRecipes = try JSONDecoder().decode([Recipe].self, from: jsonData)
            let recipe = decodedRecipes[self.idx]
            if let directionList = recipe.directions {
                self.directionList = directionList
                self.tableView.reloadData()
            }
        } catch {
            return
        }
    }

    @IBAction func onAddClicked(_ sender: Any) {
        let directionXMLToSave = DirectionsXML(content: "[Content here]", remark: "[Remark here]")
        let jsonString = Constant.getRecipe()
        let jsonData = Data(jsonString.utf8)
        do {
            var decodedRecipes = try JSONDecoder().decode([Recipe].self, from: jsonData)
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(directionXMLToSave)
            let directionToSave = try JSONDecoder().decode(Directions.self, from: jsonData)
            
            self.tableView.beginUpdates()
            self.directionList.append(directionToSave)
            let indexPath = IndexPath.init(row: self.directionList.count-1, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
            
            decodedRecipes[self.idx].directions = self.directionList
            let encodedJsonData = try jsonEncoder.encode(decodedRecipes)
            let encodedJsonStringg = String(data: encodedJsonData, encoding: .utf8) ?? ""
            Constant.setRecipe(encodedJsonStringg)
        } catch {
            return
        }
    }
    
    @objc func onEditClicked(_ sender: Any) {
        self.tableView.beginUpdates()
        self.tableView.isEditing = !self.tableView.isEditing
        if self.tableView.isEditing {
            self.changeEditBtnTitle(to: "Done")
        } else {
            self.changeEditBtnTitle(to: "Edit")
        }
        self.tableView.endUpdates()
    }
    
    func changeEditBtnTitle(to title: String) {
        let item = self.navigationItem.rightBarButtonItems?.first
        let button = item?.customView as! UIButton
        button.setTitle(title, for: .normal)
    }
    
    func makeUI() {
        var rightButtonItems : [UIBarButtonItem] = []
        
        let btnRight = UIButton(type: .custom)
        btnRight.frame = CGRect(x: 0, y: 0, width: 45, height: 30)
        btnRight.setTitle("Edit", for: .normal)
        btnRight.setTitleColor(.systemBlue, for: .normal)
        btnRight.addTarget(self, action: #selector(onEditClicked(_ :)), for: .touchUpInside)
        let btnItemRight = UIBarButtonItem.init(customView: btnRight)
        rightButtonItems.append(btnItemRight)
        
        let btnRight1 = UIButton(type: .custom)
        btnRight1.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        btnRight1.setTitle("+", for: .normal)
        btnRight1.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btnRight1.setTitleColor(.systemBlue, for: .normal)
        btnRight1.addTarget(self, action: #selector(onAddClicked(_ :)), for: .touchUpInside)
        let btnItemRight1 = UIBarButtonItem.init(customView: btnRight1)
        rightButtonItems.append(btnItemRight1)
        
        self.navigationItem.rightBarButtonItems = rightButtonItems
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.directionList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = self.directionList[indexPath.row].content
        cell.textLabel?.numberOfLines = 0
        
        cell.detailTextLabel?.text = self.directionList[indexPath.row].remark
        cell.detailTextLabel?.numberOfLines = 0
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)

            let jsonString = Constant.getRecipe()
            let jsonData = Data(jsonString.utf8)
            do {
                var decodedRecipes = try JSONDecoder().decode([Recipe].self, from: jsonData)
                let jsonEncoder = JSONEncoder()
                
                self.tableView.beginUpdates()
                self.directionList.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
                
                decodedRecipes[self.idx].directions = self.directionList
                let encodedJsonData = try jsonEncoder.encode(decodedRecipes)
                let encodedJsonStringg = String(data: encodedJsonData, encoding: .utf8) ?? ""
                Constant.setRecipe(encodedJsonStringg)
            } catch {
                return
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedDirection = self.directionList[indexPath.row]
        self.idxDirection = indexPath.row
        self.performSegue(withIdentifier: self.editDirectiondentifier, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.editDirectiondentifier,
           let nextViewController = segue.destination as? EditViewController {
            nextViewController.title = "Direction"
            nextViewController.direction = self.selectedDirection
            nextViewController.idxIngredient = self.idxDirection
            nextViewController.idx = self.idx
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        
        let jsonString = Constant.getRecipe()
        let jsonData = Data(jsonString.utf8)
        do {
            var decodedRecipes = try JSONDecoder().decode([Recipe].self, from: jsonData)
            let jsonEncoder = JSONEncoder()
            
            let rowToMove = self.directionList[fromIndexPath.row]
            self.directionList.remove(at: fromIndexPath.row)
            self.directionList.insert(rowToMove, at: to.row)
            
            decodedRecipes[self.idx].directions = self.directionList
            let encodedJsonData = try jsonEncoder.encode(decodedRecipes)
            let encodedJsonStringg = String(data: encodedJsonData, encoding: .utf8) ?? ""
            Constant.setRecipe(encodedJsonStringg)
        } catch {
            return
        }
        
    }

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
