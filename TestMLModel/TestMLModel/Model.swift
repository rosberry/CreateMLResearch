//
//  Model.swift
//  TextMLModel
//
//  Created by Evgeny Schwarzkopf on 05.05.2022.
//

import Foundation

struct ClassifierResultModel {
    let identifier: String
    let confidence: Int

    var description: String {
        return "This is \(identifier) with \(confidence)% confidence"
    }
}
