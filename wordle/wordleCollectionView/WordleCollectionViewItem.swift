//
//  WordleCollectionViewItem.swift
//  wordle
//
//  Created by Thomas Raybould on 4/3/22.
//

import Foundation
import UIKit

class WordleCollectionViewItem {
    
    let letterValue: String?
    let state: WordleCollectionItemState
    
    private init(letterValue: String, state: WordleCollectionItemState){
        self.letterValue = letterValue
        self.state = state
    }
    
    static func getLetterItem(letterValue: String, state: WordleCollectionItemState) -> WordleCollectionViewItem{
        return WordleCollectionViewItem(letterValue: letterValue, state: state)
    }
    
    static func emptyLetterItem() -> WordleCollectionViewItem{
        return getLetterItem(letterValue: "", state: WordleCollectionItemState.empty)
    }
    
    static func getNewEntryItem(letterValue: String) -> WordleCollectionViewItem{
        return getLetterItem(letterValue: letterValue, state: WordleCollectionItemState.newEntry)
    }
    
    
}

enum WordleCollectionItemState{
    case newEntry
    case rightPosition
    case wrongPosition
    case notInWord
    case empty
}
