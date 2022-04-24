//
//  WordleKeyboard.swift
//  wordle
//
//  Created by Thomas Raybould on 4/17/22.
//

import UIKit

class WordleKeyboard: UIView {

    @IBOutlet var container: UIView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
           initSubviews()
       }

       override init(frame: CGRect) {
           super.init(frame: frame)
           initSubviews()
       }

       func initSubviews() {
           let nib = UINib(nibName: "WordleKeyboard", bundle: nil)
           nib.instantiate(withOwner: self, options: nil)
           container.frame = bounds
           addSubview(container)
        
       }

}
