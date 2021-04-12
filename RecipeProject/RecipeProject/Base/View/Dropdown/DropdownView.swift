//
//  DropdownView.swift
//  RecipeProject
//
//  Created by Teh Xiang Wei on 11/04/2021.
//

import UIKit
import RxCocoa
import RxSwift

@IBDesignable
class DropdownView: UIView {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var imgDropdown: UIImageView!
    
    var picker = UIPickerView()
    var selectedRow: Int = 0
    let doneAction: BehaviorRelay<Int> = .init(value: -1)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override func prepareForInterfaceBuilder() {
        self.commonInit()
    }
    
    func commonInit() {
        guard let customView = UINib(resource: R.nib.dropdownView).instantiate(withOwner: self, options: nil).first as? UIView else { return }
        customView.frame = bounds

        customView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(customView)
        self.view = customView
        self.backgroundColor = .clear
        
        self.bindView()
    }
    
    private func bindView() {
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        let cancelBtn = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancel))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.done))
        toolBar.setItems([cancelBtn, spaceButton, doneBtn], animated: false)
        
        self.textField.inputAccessoryView = toolBar
        self.textField.inputView = self.picker
        
        self.btn.rx.tap
            .throttle(RxTimeInterval.seconds(Int(0.3)), scheduler: MainScheduler.instance).bind { [weak self] in
            guard let `self` = self else { return }
                self.textField.becomeFirstResponder()
        }.disposed(by: rx.disposeBag)
    }
    
    @objc private func cancel() {
        self.view.endEditing(true)
    }
    
    @objc private func done() {
        self.view.endEditing(true)
        self.doneAction.accept(self.selectedRow)
    }
}
