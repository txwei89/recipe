//
//  ClickableAnimView.swift
//  RecipeProject
//
//  Created by Teh Xiang Wei on 11/04/2021.
//

import UIKit
import IBAnimatable

class ClickableAnimView: AnimatableView {
    
    let tapGesture = UITapGestureRecognizer()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.initialize()
    }
    
    func initialize() {
        self.addGestureRecognizer(tapGesture)
    }
}
