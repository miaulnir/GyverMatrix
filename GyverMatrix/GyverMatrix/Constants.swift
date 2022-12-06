//
//  Constants.swift
//  GyverMatrix
//
//  Created by zuzex on 06.12.2022.
//

import Foundation

final class Constants {
    
    static var shared = Constants()
    
    var infoDescription: String {
        self.load(by: "commands_info")
    }
    
    private func load(by topic: String) -> String {
        guard
            let url = Bundle.main.url(forResource: topic, withExtension: "csv"),
            let infoString = try? String(contentsOf: url)
        else { return "none" }
        
        return infoString
    }
}
