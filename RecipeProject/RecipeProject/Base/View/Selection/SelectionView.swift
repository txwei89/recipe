//
//  SelectionView.swift
//  RecipeProject
//
//  Created by Teh Xiang Wei on 11/04/2021.
//

import UIKit

@IBDesignable
class SelectionView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var tapView: ClickableAnimView!
    @IBOutlet weak var textfield: UITextField!
    
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
        guard let customView = UINib(resource: R.nib.selectionView).instantiate(withOwner: self, options: nil).first as? UIView else { return }
        customView.frame = bounds

        customView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(customView)
        self.view = customView

        self.bindView()
    }
    
    private func bindView() {
        self.tapView.tapGesture.rx.event.bind(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.textfield.becomeFirstResponder()
        }).disposed(by: rx.disposeBag)
    }
}
