//
//  ViewController.swift
//  RecipeProject
//
//  Created by Teh Xiang Wei on 11/04/2021.
//

import UIKit
import RxCocoa
import RxSwift
import Kingfisher

class ViewController: UIViewController, XMLParserDelegate {
    
    @IBOutlet weak var dropdown: DropdownView!
    @IBOutlet weak var imgMeal: UIImageView!
    @IBOutlet weak var vwDesc: UIStackView!
    @IBOutlet weak var btnNext: ClickableAnimView!
    @IBOutlet weak var lblNext: UILabel! {
        didSet {
            self.lblNext.text = "Go to recipe"
        }
    }
    @IBOutlet weak var lblServe: UILabel!
    @IBOutlet weak var lblAdaptedFrom: UILabel!
    
    lazy var viewModel: RecipeListVM = RecipeListVM()
    private let trigger = PublishSubject<Void>()
    private let isSelectionClicked: BehaviorRelay<Bool> = .init(value: false)
    private let tfPlaceholder = "Please select"
    private let showDetailIdentifier = "showDetail"
    private let addRecipeIdentifier = "addRecipe"
    private let notAvailable = "N/A"
    private var selectedRecipe: Recipe?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.        
        self.bindViewModel()
        self.makeUI()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showDetailIdentifier {
            if let nextViewController = segue.destination as? DetailTableViewController {
                nextViewController.recipe = self.selectedRecipe
                nextViewController.idx = self.dropdown.selectedRow
            }
        } else if segue.identifier == addRecipeIdentifier {
            if let nextViewController = segue.destination as? AddRecipeViewController {
                nextViewController.title = "Add Recipe"
            }
        }
    }
    
    func bindViewModel() {
        let trigger = Observable.of(Observable.just(()), self.trigger).merge()
        let input = RecipeListVM.Input(firstTrigger: trigger)
        let output = self.viewModel.transform(input: input)
        
        output.recipeList.bind(to: self.dropdown.picker.rx.itemTitles) { [weak self] (row, item) in
            guard let `self` = self else { return "" }
            return item.mealName
        }.disposed(by: self.rx.disposeBag)
        
        self.dropdown.picker.rx.itemSelected.subscribe(onNext: {
            [weak self] row, _ in
            guard let `self` = self else { return }
            
            self.dropdown.selectedRow = row
            
        }).disposed(by: self.rx.disposeBag)
        
        self.dropdown.doneAction.skip(1).subscribe(onNext: { [weak self] row in
            guard let `self` = self else { return }
            
            self.isSelectionClicked.accept(true)
            self.selectedRecipe = self.viewModel.recipeList.value[row]
            self.dropdown.textField.text = self.selectedRecipe?.mealName
            self.lblServe.text = "\(self.selectedRecipe?.serveNumber ?? 0)"
            self.lblAdaptedFrom.text = self.selectedRecipe?.adaptedFrom?.isEmpty ?? true ? self.notAvailable : self.selectedRecipe?.adaptedFrom
            
            let imageUrl = self.selectedRecipe?.mealImage
            if let url = URL(string: imageUrl ?? "") {
                let processorFront = DownsamplingImageProcessor(size: self.imgMeal.bounds.size) |> RoundCornerImageProcessor(cornerRadius: 0)
                self.imgMeal.kf.indicatorType = .activity
                self.imgMeal.kf.setImage(
                    with: url,
                    options: [
                        .processor(processorFront),
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(1)),
                        .cacheOriginalImage
                    ], completionHandler:
                        {
                            result in
                            
                            switch result {
                            case .success(let value):
                                print("Task done for: \(value.source.url?.absoluteString ?? "")")
                                
                            case .failure(let error):
                                print("Job failed: \(error.localizedDescription)")
                            }
                        })
            }
            
        }).disposed(by: self.rx.disposeBag)
        
        self.isSelectionClicked.subscribe(onNext: { [weak self] clicked in
            guard let `self` = self else { return }

            if clicked {
                self.vwDesc.isHidden = false
                self.btnNext.alpha = 1.0
            } else {
                self.vwDesc.isHidden = true
                self.btnNext.alpha = 0.5
            }

        }).disposed(by: rx.disposeBag)
        
        self.isSelectionClicked.bind(to: self.btnNext.rx.isUserInteractionEnabled).disposed(by: self.rx.disposeBag)
        
        self.btnNext.tapGesture.rx.event.bind(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            
            self.performSegue(withIdentifier: self.showDetailIdentifier, sender: nil)
            
        }).disposed(by: self.rx.disposeBag)
    }
    
    func makeUI() {
        self.dropdown.textField.placeholder = tfPlaceholder
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
    }
    
    @objc func addTapped() {
        self.performSegue(withIdentifier: self.addRecipeIdentifier, sender: nil)
    }
    
    
}
