//
//  WordleKeyboardItem.swift
//  wordle
//
//  Created by Thomas Raybould on 8/13/22.
//

import Foundation

class WordleKeyboardItem {
    
    let letterValue: String?
    let state: WordleKeyboardItemState
    
    private init(letterValue: String, state: WordleKeyboardItemState){
        self.letterValue = letterValue
        self.state = state
    }
    
    static func createKeyboardItem(letterValue: String, state: WordleKeyboardItemState) -> WordleKeyboardItem{
        return WordleKeyboardItem(letterValue: letterValue, state: state)
    }

    enum WordleKeyboardItemState{
        case unusedLetter
        case wrongPosition
        case notInWord
        case correctPosition
    }

}
