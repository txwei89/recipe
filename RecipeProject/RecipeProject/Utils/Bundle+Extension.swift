//
//  Bundle+Extension.swift
//  RecipeProject
//
//  Created by Teh Xiang Wei on 11/04/2021.
//

import Foundation

extension Bundle {
    var serverUrl: String {
        let serverUrl = object(forInfoDictionaryKey: "SERVER_URL") as? String ?? ""
        return "\(serverUrl)"
    }
}
