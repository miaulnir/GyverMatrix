//
//  InfoViewController.swift
//  GyverMatrix
//
//  Created by zuzex on 06.12.2022.
//

import UIKit

class InfoViewController: UIViewController {
    
    private lazy var infoTextView: UITextView = {
        let textView = UITextView(frame: self.view.frame)
        textView.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        textView.textColor = .black
        textView.isEditable = false
        textView.isSelectable = true
        textView.text = Constants.shared.infoDescription
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(infoTextView)
        
    }

}
