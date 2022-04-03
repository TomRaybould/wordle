//
//  WordleCollectionViewItem.swift
//  wordle
//
//  Created by Thomas Raybould on 4/3/22.
//

import Foundation
import UIKit

class WordleCollectionViewItem {
    
    let letterValue: String
    let state: WordleCollectionItemState
    
    init(letterValue: String, state: WordleCollectionItemState){
        self.letterValue = letterValue
        self.state = state
    }
    
}

enum WordleCollectionItemState{
    case rightPosition
    case wrongPosition
    case notInWord
}
